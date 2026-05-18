import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class AIService {
  static Future<String> generateCreepyResponse(String prompt) async {
    final apiKey = dotenv.env['OPENAI_API_KEY'];
    const url = "https://api.openai.com/v1/chat/completions";

    final response = await http.post(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $apiKey',
      },
      body: jsonEncode({
        "model": "gpt-4",
        "messages": [
          {
            "role": "system",
            "content":
                "You're an eerie dream interpreter. Return short, poetic horror stories based on the user's fear or dream."
          },
          {
            "role": "user",
            "content": prompt
          }
        ],
        "temperature": 0.9,
        "max_tokens": 300
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['choices'][0]['message']['content'].trim();
    } else {
      print("OpenAI error: ${response.body}");
      throw Exception("Failed to generate response");
    }
  }

  static Future<String?> generateDreamImage(String prompt) async {
    final apiKey = dotenv.env['OPENAI_API_KEY'];
    const url = "https://api.openai.com/v1/images/generations";

    final response = await http.post(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $apiKey',
      },
      body: jsonEncode({
        "model": "dall-e-2", // safer for now
        "prompt": prompt,
        "n": 1,
        "size": "1024x1024"
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['data'][0]['url'];
    } else {
      print("Image generation error: ${response.body}");
      return null;
    }
  }

  static Future<String> expandPromptForImage(String shortInput) async {
    final apiKey = dotenv.env['OPENAI_API_KEY'];
    const url = "https://api.openai.com/v1/chat/completions";

    final response = await http.post(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $apiKey',
      },
      body: jsonEncode({
        "model": "gpt-3.5-turbo",
        "messages": [
          {
            "role": "system",
            "content":
                "You're a dream interpreter creating eerie image prompts for an AI artist. Translate short fears or phrases into dark, surreal image descriptions. Be poetic and creepy. Avoid gore. Example: 'mirrors' → 'A haunted hallway filled with mirrors that reflect forgotten memories.'"
          },
          {
            "role": "user",
            "content": shortInput
          }
        ],
        "temperature": 0.85,
        "max_tokens": 100
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['choices'][0]['message']['content'].trim();
    } else {
      print("Prompt expansion error: ${response.body}");
      return "A dark, surreal dream based on: $shortInput";
    }
  }
}
