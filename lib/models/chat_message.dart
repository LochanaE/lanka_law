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
}
