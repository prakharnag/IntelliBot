import 'package:dart_openai/dart_openai.dart';
import 'package:openai_dart/env/env.dart';

Future<String> generateOpenAIEmbeddings(String userInput) async {
  OpenAI.apiKey = Env.apiKey;

  final embedding = await OpenAI.instance.embedding.create(
    model: "text-embedding-3-small",
    input: userInput,
  );
  final firstEmbedding = embedding.data[0].embeddings.toString();
  print('Embedding dimensions: ${embedding.data[0].embeddings.length}');
  print('First embedding: $firstEmbedding');

  return firstEmbedding;
}
