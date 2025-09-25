import 'dart:convert';
import 'package:http/http.dart' as http;

class ChatController {
  final String apiKey;
  final String apiUrl;

  ChatController({
    required this.apiKey,
    this.apiUrl =
        'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent',
  });

  Future<String> sendMessage(
    String message, {
    List<Map<String, String>>? history,
  }) async {
    final headers = {
      'Content-Type': 'application/json',
      'X-goog-api-key': apiKey,
    };
    // Gemini expects a list of content parts (history + user message)
    final List<Map<String, dynamic>> contents = [];
    if (history != null) {
      for (final msg in history) {
        final content = msg['content']?.toString().trim() ?? '';
        if (content.isEmpty) continue;
        contents.add({
          'parts': [
            {'text': content},
          ],
        });
      }
    }
    // Add the new user message
    final userMsg = message.trim();
    if (userMsg.isNotEmpty) {
      contents.add({
        'parts': [
          {'text': userMsg},
        ],
      });
    }

    final body = jsonEncode({'contents': contents});
    final url = Uri.parse(apiUrl);
    final response = await http.post(url, headers: headers, body: body);
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      // Gemini's response: data['candidates'][0]['content']['parts'][0]['text']
      return data['candidates']?[0]?['content']?['parts']?[0]?['text'] ??
          'No response';
    } else {
      throw Exception('Failed to get response: ${response.body}');
    }
  }
}
