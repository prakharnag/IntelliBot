import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:openai_dart/customer_support/analyze_order.dart';

class CustomerServiceView extends StatefulWidget {
  const CustomerServiceView({super.key});

  @override
  CustomerServiceViewState createState() => CustomerServiceViewState();
}

class CustomerServiceViewState extends State<CustomerServiceView> {
  XFile? _image;
  Uint8List? _imageBytes;
  final ImagePicker _picker = ImagePicker();
  Map<String, Object?>? _result;
  bool _isLoading = false;
  TextEditingController _urlController = TextEditingController();

  Future<void> _pickImage() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        final bytes = await pickedFile.readAsBytes();
        setState(() {
          _image = pickedFile;
          _imageBytes = bytes;
        });
      }
    } catch (e) {
      print("Error picking image: $e");
    }
  }

  Future<void> _loadImageFromUrl() async {
    final url = _urlController.text;
    if (url.isEmpty) {
      print("URL is empty");
      return;
    }
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        setState(() {
          _imageBytes = response.bodyBytes;
          _image = null; // Clear the picked image to avoid confusion
        });
      } else {
        print("Failed to load image from URL: ${response.statusCode}");
      }
    } catch (e) {
      print("Error loading image from URL: $e");
    }
  }

  Future<void> _submitToOpenAI() async {
    if (_imageBytes != null) {
      setState(() {
        _isLoading = true;
      });

      Map<String, String> imageData = {
        'imageName': _image?.name ?? 'url_image',
        'imageBase64': base64Encode(_imageBytes!),
      };
      print(imageData['imageName']);
      final result = await simulateDeliveryExceptionSupport(imageData);
      print(result);
      setState(() {
        _result = result;
        _isLoading = false;
      });
    } else {
      print('No image selected');
    }
  }

  void _showImageSourceDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Choose Image Source"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: Text("Select from Gallery"),
                onTap: () {
                  Navigator.of(context).pop();
                  _pickImage();
                },
              ),
              ListTile(
                title: Text("Enter Image URL"),
                onTap: () {
                  Navigator.of(context).pop();
                  _showUrlInputDialog();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showUrlInputDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Enter Image URL"),
          content: TextField(
            controller: _urlController,
            decoration: InputDecoration(hintText: "Image URL"),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _loadImageFromUrl();
              },
              child: Text("Load Image"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Customer Service'),
        backgroundColor: Colors.amber,
      ),
      body: Container(
        color: Colors.amber.shade50,
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    if (_imageBytes != null) ...[
                      kIsWeb
                          ? Image.memory(_imageBytes!, height: 300, width: 300)
                          : Image.memory(_imageBytes!, height: 300, width: 300),
                      const SizedBox(height: 5),
                    ],
                    if (_isLoading) ...[
                      CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.amber),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Analyzing...',
                        style: TextStyle(color: Colors.black),
                      ),
                      const SizedBox(height: 10),
                    ] else if (_result != null) ...[
                      Container(
                        padding: const EdgeInsets.all(16.0),
                        decoration: BoxDecoration(
                          color: Colors.blueAccent.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.blueAccent),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Result:',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                                color: Colors.black,
                              ),
                            ),
                            const SizedBox(height: 5),
                            Text('Analysis: ${_result!["rationale"]}', style: TextStyle(color: Colors.black)),
                            Text('Image Description: ${_result!["imageDescription"]}', style: TextStyle(color: Colors.black)),
                            Text('Action Taken: ${_result!["actionResult"]}', style: TextStyle(color: Colors.black)),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(16.0),
              color: Colors.amber.shade50,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: _showImageSourceDialog,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.amber,
                      foregroundColor: Colors.black,
                    ),
                    child: const Text('Upload Image'),
                  ),
                  ElevatedButton(
                    onPressed: _submitToOpenAI,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.amber,
                      foregroundColor: Colors.black,
                    ),
                    child: const Text('Submit to OpenAI'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
