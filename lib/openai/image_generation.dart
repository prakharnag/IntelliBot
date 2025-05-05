import 'dart:typed_data';
import 'package:dart_openai/dart_openai.dart';
import 'package:http/http.dart' as http;

import '../env/env.dart';

Future<Uint8List>generateOpenAImage(String userInput) async {
  OpenAI.apiKey = Env.apiKey;

  // Generate an image from a prompt.
  final image = await OpenAI.instance.image.create(
    prompt: userInput, // Use userInput as the prompt
    model: "dall-e-3",
    n: 1,
  );

  // Get the URL of the generated image
  final imageUrl = image.data.first.url ?? "No image URL available";
  // Use your proxy endpoint (replace <your-vercel-url> with your actual deployment URL)
  final proxyUrl = 'https://omnibot-chat.vercel.app/api/image-proxy?url=${Uri.encodeComponent(imageUrl)}';
    // Fetch image bytes
  final response = await http.get(Uri.parse(proxyUrl));

 
  if (response.statusCode == 200) {
    //print(response.bodyBytes);
    return response.bodyBytes;
  } else {
    throw Exception('Failed to load image');
  }
}
