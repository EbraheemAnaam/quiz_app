import 'dart:convert';
import 'package:http/http.dart' as http;

class ChatController {
  final String apiKey;
  final String apiUrl;

  ChatController({
    required this.apiKey,
    this.apiUrl =
        'https://generativelanguage.googleapis.com/v1beta/models/gemini-pro:generateContent',
  });

  Future<String> sendMessage(
    String message, {
    List<Map<String, String>>? history,
  }) async {
    final headers = {'Content-Type': 'application/json'};
    // Gemini expects a list of content parts (history + user message)
    final List<Map<String, dynamic>> contents = [];
    if (history != null) {
      for (final msg in history) {
        final content = msg['content']?.toString().trim() ?? '';
        if (content.isEmpty) continue;
        if (msg['role'] == 'user') {
          contents.add({
            'role': 'user',
            'parts': [content],
          });
        } else if (msg['role'] == 'assistant' || msg['role'] == 'model') {
          contents.add({
            'role': 'model',
            'parts': [content],
          });
        }
      }
    }
    // Add the new user message
    final userMsg = message.trim();
    if (userMsg.isNotEmpty) {
      contents.add({
        'role': 'user',
        'parts': [userMsg],
      });
    }

    // Remove any parts that are not plain strings
    for (final c in contents) {
      c['parts'] = (c['parts'] as List)
          .where((p) => p is String && p.trim().isNotEmpty)
          .toList();
    }

    final body = jsonEncode({'contents': contents});
    final url = Uri.parse('$apiUrl?key=$apiKey');
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
