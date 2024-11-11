import 'package:google_generative_ai/google_generative_ai.dart';
import '../env/env.dart';

Future<List<double>> generateGeminiEmbeddings(String userInput) async {
  const apiKey = Env.geminiAiApiKey;

  final model = GenerativeModel(model: 'embedding-001', apiKey: apiKey);
  final content = Content.text(userInput);

  final result = await model.embedContent(content);
  return result.embedding.values;
}
