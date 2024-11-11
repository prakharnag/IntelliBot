import 'package:google_generative_ai/google_generative_ai.dart';
import '../env/env.dart';

Future<String> generateGeminiChatCompletion(String userInput) async {
  const apiKey = Env.geminiAiApiKey;

  final model = GenerativeModel(
      model: 'gemini-1.5-flash-latest',
      apiKey: apiKey,
      safetySettings: [
        SafetySetting(HarmCategory.dangerousContent, HarmBlockThreshold.high)
      ],
      generationConfig: GenerationConfig(maxOutputTokens: 200));

  final content = [Content.text(userInput)];
  final tokenCount = await model.countTokens(content);
  print('Token count: ${tokenCount.totalTokens}');

  final response = await model.generateContent(content);
  return response.text ?? 'No response generated';
}
