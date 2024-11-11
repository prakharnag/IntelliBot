import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../env/env.dart';
import "package:openai_dart/models/order_details.dart";

const String orderid = "12345"; // Placeholder order ID for testing
const String instructionprompt = "You are a customer service assistant for a delivery service, equipped to analyze images of packages. If a package appears damaged in the image, automatically process a refund according to policy. If the package looks wet, initiate a replacement. If the package appears normal and not damaged, escalate to agent. For any other issues or unclear images, escalate to agent. You must always use tools!";

const apiKey = Env.apiKey;

Future<FunctionCallBase> deliveryExceptionSupportHandler(Map<String, String> imageData) async {
 
  final payload = {
    "model": model,
    "messages": [
      {
        "role": "user",
        "content": instructionprompt,
      },
      {
        "role": "user",
        "content": [
          {
            "type": "image_url",
            "image_url": {
              "url": "data:image/jpeg;base64,${imageData['imageBase64']}"
            }
          },
        ],
      }
    ],
    "functions": [
      {
        "name": "refund_order",
        "description": "Refund an order",
        "parameters": {
          "type": "object",
          "properties": {
            "rationale": {"type": "string"},
            "image_description": {"type": "string"},
          },
          "required": ["rationale", "image_description"]
        }
      },
      {
        "name": "replace_order",
        "description": "Replace an order",
        "parameters": {
          "type": "object",
          "properties": {
            "rationale": {"type": "string"},
            "image_description": {"type": "string"},
          },
          "required": ["rationale", "image_description"]
        }
      },
      {
        "name": "escalate_to_agent",
        "description": "Escalate to an agent",
        "parameters": {
          "type": "object",
          "properties": {
            "rationale": {"type": "string"},
            "image_description": {"type": "string"},
            "message": {"type": "string"},
          },
          "required": ["rationale", "image_description", "message"]
        }
      }
    ],
    "function_call": "auto",
    "temperature": 0.0,
  };

  final response = await http.post(
    Uri.parse('https://api.openai.com/v1/chat/completions'),
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $apiKey',
    },
    body: jsonEncode(payload),
  );


  if (response.statusCode == 200) {
    final responseBody = jsonDecode(response.body);
    final functionCall = responseBody['choices'][0]['message']['function_call'];
    final action = functionCall['name'];
    final arguments = jsonDecode(functionCall['arguments']);
    FunctionCallBase tool;
  switch (action) {
    case 'refund_order':
      tool = RefundOrder(
        rationale: arguments['rationale'] ?? 'No rationale provided',
        imageDescription: arguments['image_description'] ?? 'No image description provided',
      );
      break;
    case 'replace_order':
      tool = ReplaceOrder(
        rationale: arguments['rationale'] ?? 'No rationale provided',
        imageDescription: arguments['image_description'] ?? 'No image description provided',
      );
      break;
    case 'escalate_to_agent':
      tool = EscalateToAgent(
        rationale: arguments['rationale'] ?? 'No rationale provided',
        imageDescription: arguments['image_description'] ?? 'No image description provided',
        message: 'Please review the package for any issues.',
      );
      break;
    default:
      throw Exception('Unknown action: $action');
  }

    final actionResult = tool.call(orderid);
    print("- Parameters: $arguments");
    print(">> Action result: $actionResult");

    return tool;
  } else {
    throw Exception('Failed to get response from OpenAI API');
  }
}

Future<Map<String, Object?>?> simulateDeliveryExceptionSupport(Map<String, String> imageData) async {
  try {
    print("\n===================== Simulating user message  =====================");
    final result = await deliveryExceptionSupportHandler(imageData);
    final actionResult = result.call(orderid);
    print("\nAll simulations completed successfully.");
    return {
      "imageDescription": result.imageDescription,
      "rationale": result.rationale,
      "actionResult": actionResult
    };
  } catch (e, stackTrace) {
    print("An error occurred during simulation: $e");
    print("Stack trace: $stackTrace");
    return null;
  }
}