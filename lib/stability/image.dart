//import 'dart:io';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import '../env/env.dart';

String generateFileName(String prompt) {
  // Replace non-alphanumeric characters with underscores and trim the string
  return prompt.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '_').toLowerCase().substring(0, 30);
}

Future<String> getApplicationDocumentsDirectoryPath() async {
final directory = await getApplicationDocumentsDirectory();
  return directory.path;
}

Future<Uint8List> generateStabilitiAiImage(String prompt) async {
  const apiKey = Env.stabilityAiApiKey; // Replace with your StabilityAI API key
  final url = Uri.parse('https://api.stability.ai/v2beta/stable-image/generate/ultra');

  try {
    final request = http.MultipartRequest('POST', url)
      ..headers['authorization'] = 'Bearer $apiKey'
      ..headers['accept'] = 'image/*'
      ..fields['prompt'] = prompt
      ..fields['output_format'] = 'webp';

    final streamedResponse = await request.send();
    if (streamedResponse.statusCode == 200) {
      // Process the response
      final responseBytes = await streamedResponse.stream.toBytes();
      return Uint8List.fromList(responseBytes);
    } else {
      // Handle error response
      print('Error - HTTP ${streamedResponse.statusCode}: ${streamedResponse.reasonPhrase}');
      return Uint8List(0); // Return empty Uint8List or handle error as per your application's logic
    }
  } catch (e) {
    // Handle exceptions
    print('Exception during API call: $e');
    return Uint8List(0); // Return empty Uint8List or handle error as per your application's logic
  }
}

// A serene waterfall in a dense forest
// A vast desert with rolling sand dunes
// A futuristic cityscape with flying cars and skyscrapers
// A gourmet pizza with various toppings
// A street artist creating a mural on a wall
// A portrait of an elderly woman with a kind smile
// Christmas tree in illinois institute of technology
// Generate a spaceship entering Illinois Institute of technology

// Generate a modern robotic cleaner
// Generate a new Electric Vehicle SUV
// Generate a laptop with large screen
// Generate a new Smartphone
// Generate a chicago style pizza
//generate a deer running from  three lions in the forest