import 'api_client.dart';
import '../models/chat_message.dart';

class MessagesService {
  final ApiClient api;
  MessagesService(this.api);

  Future<List<ChatMessage>> getMessages(String threadId) async {
    final data = await api.get('/threads/$threadId/messages');
    final list = (data['messages'] as List).cast<Map<String, dynamic>>();
    return list.map(ChatMessage.fromJson).toList();
  }

  Future<ChatMessage> sendMessage(String threadId, String text, {int topK = 10}) async {
    final data = await api.post('/threads/$threadId/message', {
      'question': text,
      'top_k': topK,
    });

    // backend returns assistant_message
    return ChatMessage.fromJson(data['assistant_message']);
  }
}
