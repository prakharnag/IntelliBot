// import 'package:google_generative_ai/google_generative_ai.dart';
// import '../env/env.dart';

// void main() async {
//   const apiKey = Env.geminiAiApiKey;

//   final model = GenerativeModel(
//       model: 'imagegeneration@005',
//       apiKey: apiKey,
//       safetySettings: [
//         SafetySetting(HarmCategory.dangerousContent, HarmBlockThreshold.high)
//       ],
//       generationConfig: GenerationConfig(maxOutputTokens: 200));

//   final content = [Content.text("Give me an image of a car flying in a rainy weather")];
//   final tokenCount = await model.countTokens(content);
//   print('Token count: ${tokenCount.totalTokens}');

//   final response = await model.generateContent(content);
//   print(response.text);
// }
