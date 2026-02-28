import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:lanka_law/models/chat_message.dart';

class ChatService {
  static const String _baseUrl = 'http://10.0.2.2:8000';

  Future<ChatMessage> sendMessage(String text, {int topK = 10}) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/chat'),
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: jsonEncode({
          'question': text,
          'top_k': topK,
        }),
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        // Decode body handling utf-8
        final decodedData = utf8.decode(response.bodyBytes);
        final Map<String, dynamic> data = jsonDecode(decodedData);
        
        List<ChatSource> sources = [];
        if (data['sources'] != null) {
          sources = (data['sources'] as List)
              .map((e) => ChatSource.fromJson(e as Map<String, dynamic>))
              .toList();
        }

        return ChatMessage(
          text: data['answer'] ?? '',
          isUser: false,
          lang: data['lang'],
          retrievalQuery: data['retrieval_query'],
          sources: sources,
        );
      } else {
        throw Exception('Server error: ${response.statusCode}');
      }
    } on TimeoutException {
      throw Exception('Connection timed out. Please try again.');
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }
}
