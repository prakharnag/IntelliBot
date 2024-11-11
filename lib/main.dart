
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:openai_dart/openai/chat_completion_example.dart';
import 'package:openai_dart/openai/image_generation.dart';
import 'package:openai_dart/openai/embeddings_example.dart';
import 'package:openai_dart/gemini/chat_completion_example.dart';
import 'package:openai_dart/gemini/embeddings_example.dart';
import 'package:openai_dart/stability/image.dart';
import 'package:flutter/services.dart'; 
import 'package:image_picker/image_picker.dart';
import 'package:openai_dart/customer_support/customer_service_view.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.amber),
        useMaterial3: true,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final TextEditingController _controller = TextEditingController();
  String _output = "";
  String selectedOption = "Generate Text";          // Default selected option
  bool _isLoading = false;                          // Loading state
  bool _isImage = false;                            // Flag to check if the output is an image URL
  bool _isGemini = false;         
  bool _isOpenAI= false;                            // Flag to check if GeminiAI is selected
  bool _isStabilityAI = false;                      // Flag to check if StabilityAI is selected
  bool _showGeminiImage = false;
  Uint8List _imageBytes = Uint8List(0);             // Store image bytes
  List<Map<String, dynamic>> _searchHistory = [];   // List to store history
  List<Map<String, dynamic>> _chatMessages = [];

  XFile? _image;
  final ImagePicker _picker = ImagePicker();

 
 @override
  void initState() {
    super.initState();
    _loadSearchHistory();
  }

  Future<void> _loadSearchHistory() async {
    final prefs = await SharedPreferences.getInstance();
    List<String>? historyList;

    if (_isGemini) {
      historyList = prefs.getStringList('geminiSearchHistory');
    } else if (_isStabilityAI) {
      historyList = prefs.getStringList('stabilitySearchHistory');
    } else if(_isOpenAI) {
      historyList = prefs.getStringList('openaiSearchHistory');
    }

    setState(() {
      if (historyList != null) {
        _searchHistory = historyList.map<Map<String, dynamic>>((item) {
          final decoded = json.decode(item);
          if (decoded['type'] == 'image') {
            decoded['output'] = base64Decode(decoded['output']);
          }
          return decoded as Map<String, dynamic>;
        }).toList();
      } else {
        _searchHistory = [];
      }
    });
  }

  Future<void> _saveSearchHistory() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> historyList = _searchHistory.map((item) {
      if (item['output'] is Uint8List) {
        return json.encode({
          'input': item['input'].trim(),
          'output': base64Encode(item['output']),
          'type': 'image'
        });
      }
      return json.encode(item);
    }).toList();

    if (_isGemini) {
      await prefs.setStringList('geminiSearchHistory', historyList);
    } else if (_isStabilityAI) {
      await prefs.setStringList('stabilitySearchHistory', historyList);
    } else {
      await prefs.setStringList('openaiSearchHistory', historyList);
    }
  }
  Future<void> _updateOutput() async {
    setState(() {           
      _isLoading = true;
      _output = ""; 
      _isImage = false; 
      _showGeminiImage = false; 
    });

    final userInput = _controller.text;
    String response = "";
    bool isImage = false;
    Uint8List imageBytes = Uint8List(0);

    try {
      if (_isGemini) {
        if (selectedOption == "Generate Text") {
          response = await generateGeminiChatCompletion(userInput);
        } else if (selectedOption == "Generate Embedding") {
          final embedding = await generateGeminiEmbeddings(userInput);
          response = embedding.toString();
        } else if (selectedOption == "Generate Image") {
          _showGeminiImage = true;
          isImage = true;
          response = 'assets/images/image.jpg'; 
        }
      } else if (_isStabilityAI) {
        if (selectedOption == "Generate Image") {
          imageBytes = await generateStabilitiAiImage(userInput);
          isImage = true;
        }
      } else {
        if (selectedOption == "Generate Text") {
          response = await getOpenAIResponse(userInput);
        } else if (selectedOption == "Generate Image") {
          imageBytes = await generateOpenAImage(userInput);
          isImage = true;
        } else if (selectedOption == "Generate Embedding") {
          response = await generateOpenAIEmbeddings(userInput);
        }
      }
    } catch (e) {
      print("update method catch");
      response = "Error: $e";
    }

    setState(() {
      _output = response;
      _isLoading = false;
      _isImage = isImage;
      _imageBytes = imageBytes;
      _controller.clear();

      // Add to chat messages
      _chatMessages.insert(0, {'text': userInput, 'isUser': true, 'isImage': false});
      if (isImage) {
        _chatMessages.insert(0,{
          'text': "Image generated",
          'isUser': false,
          'isImage': true,
          'imageBytes': imageBytes,
          'showGeminiImage': _showGeminiImage
        });
      } else {
        _chatMessages.insert(0, {'text': response, 'isUser': false, 'isImage': false});
      }

      // Add to search history
      Map<String, dynamic> historyEntry = { 
        'input': userInput.trim(),
        'isImage': isImage.toString(),
      };

      if (isImage) {
        if (_isStabilityAI) {
          historyEntry['output'] = imageBytes;
        } else if (_isGemini) {
          historyEntry['output'] = 'assets/images/image.jpg';
        } else if (_isOpenAI) {
          historyEntry['output'] = imageBytes;
        }
      } else {
        historyEntry['output'] = response;
      }
      _searchHistory.insert(0, historyEntry);

      if (_searchHistory.length > 10) {
        _searchHistory.removeLast();
      }
      _saveSearchHistory();
    });
  }

  @override
    Widget build(BuildContext context) {
      return Scaffold(
        appBar: AppBar(
          title: Text(_isGemini ? 'Intelligent Assistant - Gemini' : _isStabilityAI ? 'Intelligent Assistant - Stability' : 'Intelligent Assistant - OpenAI'),
          backgroundColor: Colors.amber,
        ),
        drawer: Drawer(
          child: Column(
            children: <Widget>[
              const DrawerHeader(
                decoration: BoxDecoration(
                  color: Colors.amber,
                ),
                child: Center(
                  child: Text(
                    'AI PLATFORMS',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 24,
                    ),
                  ),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.brightness_1, size: 10, color: Colors.amber),
                title: const Text('OpenAI'),
                onTap: () {
                  setState(() {
                    _isOpenAI = true;
                    _isGemini = false;
                    _isStabilityAI = false;
                    selectedOption = 'Generate Text';
                    _controller.text = '';
                    _output = ''; // Reset output
                    _isImage = false; // Reset image flag
                    _chatMessages=[];
                    _loadSearchHistory();
                  });
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.brightness_1, size: 10, color: Colors.amber),
                title: const Text('Gemini'),
                onTap: () {
                  setState(() {
                    _isGemini = true;
                    _isOpenAI = false;
                    _isStabilityAI = false;
                    selectedOption = 'Generate Text';
                    _controller.text = '';
                    _output = ''; // Reset output
                    _isImage = false; // Reset image flag
                    _chatMessages=[];
                  _loadSearchHistory();
                  });
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.brightness_1, size: 10, color: Colors.amber),
                title: const Text('Stability'),
                onTap: () {
                  setState(() {
                    _isGemini = false;
                    _isOpenAI = false;
                    _isStabilityAI = true;
                    selectedOption = 'Generate Image';
                    _controller.text = '';
                    _output = ''; // Reset output
                    _isImage = false; // Reset image flag
                    _chatMessages=[];
                    _loadSearchHistory();
                  });
                  Navigator.pop(context);
                },
              ),
              const Divider(),
              Expanded(
              child: ListView.builder(
                padding: EdgeInsets.zero,
                itemCount: _searchHistory.length + 1,
                itemBuilder: (context, index) {
                  if (index == 0) {
                    // Header
                    return Padding(
                      padding: EdgeInsets.symmetric(vertical: 8.0),
                      child: Center(
                        child: Text('Search History', style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    );
                  }
                  
                  final entry = _searchHistory[index - 1];
                  return ListTile(
                  leading: const Icon(Icons.history, size: 20, color: Colors.amber),
                  title: Text(
                    (entry['input'] ?? '').replaceAll('\n', ' ').trim(),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 16),
                  ),
                      onTap: () {
                    setState(() {
                    _controller.text = entry['input'] ?? '';
                      _isImage = false;
                      _showGeminiImage = false;
                      if (entry['output'] is Uint8List) {
                        _imageBytes = entry['output'];
                        _isImage = true;
                      } else if (entry['output'] is String) {
                        if ( entry['isImage'] == 'true') {
                          _isImage = true;
                          _isOpenAI = false;
                          _showGeminiImage = true;
                        } else {
                          _output = entry['output'];
                        }
                      } else {
                        _output = 'Unsupported output type';
                      }
                      // Clear existing chat messages and add this history item
                      _chatMessages.clear();
                      _chatMessages.insert(0,{'text': entry['input'], 'isUser': true, 'isImage': false});
                      _chatMessages.insert(0,{
                        'text': _isImage ? 'Image generated' : entry['output'],
                        'isUser': false,
                        'isImage': _isImage,
                        'imageBytes': _isImage ? entry['output'] : null,
                        'showGeminiImage': _showGeminiImage,
                      });
                    });
                    Navigator.pop(context);
                  },
                );
                },
              ),
            ),
            ],
          ),
        ),
        body: Container(
        color: Colors.amber.shade50,
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            if (_isLoading)
              const Padding(
                padding: EdgeInsets.only(top: 20),
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.amber),
                ),
              ),
          Expanded(
          child: ListView.builder(
            reverse: true,  // This will make the list start from the bottom
            itemCount: _chatMessages.length,
            itemBuilder: (context, index) {
              final message = _chatMessages[_chatMessages.length - 1 - index];  // Reverse the order
              final bool isUser = message['isUser'] == true;
              final bool isImage = message['isImage'] == true;

              return Align(
                alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                child: Container(
                  margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isUser ? Colors.amber[200] : Colors.grey[200],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: isImage
                      ? (message['showGeminiImage'] == true
                          ? Image.asset(
                              'assets/images/image.jpg',
                              fit: BoxFit.cover,
                              width: 500,
                              height: 500,
                            )
                          : Image.memory(
                              message['imageBytes'] as Uint8List,
                              fit: BoxFit.cover,
                              width: 500,
                              height: 500,
                            ))
                      : SelectableText(
                          message['text'] as String? ?? '',
                          style: TextStyle(fontSize: 16),
                        ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: TextField(
                maxLines: null,
                controller: _controller,
                decoration: const InputDecoration(
                  labelText: 'Message Intelligent Assistant',
                  border: OutlineInputBorder(),
                  filled: true,
                  fillColor: Colors.white70,
                ),
              ),
            ),
            const SizedBox(width: 10),
            if (!_isStabilityAI)
              Container(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              decoration: BoxDecoration(
                color: Colors.amber,
                borderRadius: BorderRadius.circular(12.0),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          DropdownButton<String>(
            value: selectedOption,
            onChanged: (String? value) {
              if (value != null) {
                setState(() {
                  selectedOption = value;
                  if (selectedOption == 'Customer Service') {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => CustomerServiceView()),
                    );
                  }
                });
              }
            },
            icon: const Icon(
              Icons.arrow_downward_rounded,
              size: 24.0,
              color: Colors.black,
            ),
            items: _isGemini
                ? <String>['Generate Text', 'Generate Image', 'Generate Embedding']
                    .map<DropdownMenuItem<String>>((String value) {
                    final Map<String, IconData> iconMap = {
                      'Generate Text': Icons.text_snippet,
                      'Generate Image': Icons.image,
                      'Generate Embedding': Icons.memory,
                    };
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Row(
                        children: [
                          Icon(iconMap[value] ?? Icons.error, size: 22),
                          SizedBox(width: 10),
                          Text(value),
                        ],
                      ),
                    );
                  }).toList()
                : <String>['Generate Text', 'Generate Image', 'Generate Embedding', 'Customer Service']
                    .map<DropdownMenuItem<String>>((String value) {
                    IconData icon = value == 'Generate Text'
                        ? Icons.text_snippet
                        : value == 'Generate Image'
                            ? Icons.image
                            : value == 'Generate Embedding'
                                ? Icons.memory
                                : Icons.support_agent;
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Row(
                        children: [
                          Icon(icon, color: Colors.black),
                          const SizedBox(width: 10),
                          Text(value),
                        ],
                      ),
                    );
                  }).toList(),
          ),
        ],
      ),
    ),
          ],
        ),
        const SizedBox(height: 20),
        Container(
          alignment: Alignment.center,
          child: ElevatedButton(
            onPressed: _updateOutput,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.amber,
              foregroundColor: Colors.black,
            ),
            child: Text(_isStabilityAI ? 'Generate Image' : 'Submit'),
          ),
        ),
      ],
    ),
  ),
    );
  }
}
