class ChatSource {
  final String domain;
  final double score;

  ChatSource({required this.domain, required this.score});

  factory ChatSource.fromJson(Map<String, dynamic> json) {
    return ChatSource(
      domain: json['domain'] ?? '',
      score: (json['score'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class ChatMessage {
  final String text;
  final bool isUser;
  final String? lang;
  final String? retrievalQuery;
  final List<ChatSource>? sources;

  ChatMessage({
    required this.text,
    required this.isUser,
    this.lang,
    this.retrievalQuery,
    this.sources,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    List<ChatSource> sources = [];
    if (json['sources'] != null) {
      sources = (json['sources'] as List)
          .map((e) => ChatSource.fromJson(e as Map<String, dynamic>))
          .toList();
    }

    final isUser = json['role'] == 'user' || json['isUser'] == true || json['is_user'] == true;
    final text = (json['answer'] ?? json['text'] ?? json['content'] ?? '').toString();

    return ChatMessage(
      text: text,
      isUser: isUser,
      lang: json['lang'] as String?,
      retrievalQuery: (json['retrieval_query'] ?? json['retrievalQuery']) as String?,
      sources: sources,
    );
  }
}
