class ChatThread {
  final String id;
  final String title;
  final DateTime updatedAt;

  ChatThread({
    required this.id,
    required this.title,
    required this.updatedAt,
  });

  factory ChatThread.fromJson(Map<String, dynamic> json) {
    return ChatThread(
      id: json['id'] as String,
      title: (json['title'] ?? 'Chat') as String,
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }
}