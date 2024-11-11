import 'package:dart_openai/dart_openai.dart';
import '../env/env.dart';


Future<String> getOpenAIResponse(String userInput) async {
  OpenAI.apiKey = Env.apiKey;

  final systemMessage = OpenAIChatCompletionChoiceMessageModel(
    content: [
      OpenAIChatCompletionChoiceMessageContentItemModel.text(
        "You are an intelligent assistant and you need to reply on my prompts",
      ),
    ],
    role: OpenAIChatMessageRole.assistant,
  );

  final userQuery = OpenAIChatCompletionChoiceMessageModel(
  content: [
    OpenAIChatCompletionChoiceMessageContentItemModel.text(userInput),
  ],
  role: OpenAIChatMessageRole.assistant,
);

  final requestMessages = [
    systemMessage,
    userQuery
  ];

  OpenAIChatCompletionModel chatCompletion = await OpenAI.instance.chat.create(
    model: "gpt-4o-mini",
    seed: 6,
    messages: requestMessages,
    temperature: 0.2,
    maxTokens: 500,
  );


  print(chatCompletion.choices.first.message.content?.first.text); //
  print(chatCompletion.usage.promptTokens); //
  print(chatCompletion.id); //
  return chatCompletion.choices.first.message.content?.first.text ?? "";
}

