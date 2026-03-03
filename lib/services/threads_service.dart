import '../models/chat_thread.dart';
import 'api_client.dart';

class ThreadsService {
  final ApiClient api;

  ThreadsService(this.api);

  Future<ChatThread> createThread({String title = "New Chat"}) async {
    final data = await api.post('/threads', {'title': title});
    return ChatThread.fromJson(data['thread']);
  }

  Future<List<ChatThread>> listThreads() async {
    final data = await api.get('/threads');
    final list = (data['threads'] as List).cast<Map<String, dynamic>>();
    return list.map(ChatThread.fromJson).toList();
  }
}