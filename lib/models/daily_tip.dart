class DailyTip {
  final String id;
  final String day;
  final String category;
  final String tipEn;
  final String tipSi;
  final String? sourceRef;

  DailyTip({
    required this.id,
    required this.day,
    required this.category,
    required this.tipEn,
    required this.tipSi,
    this.sourceRef,
  });

  factory DailyTip.fromJson(Map<String, dynamic> json) {
    return DailyTip(
      id: json['id'] as String? ?? '',
      day: json['day'] as String? ?? '',
      category: json['category'] as String? ?? '',
      tipEn: json['tip_en'] as String? ?? '',
      tipSi: json['tip_si'] as String? ?? '',
      sourceRef: json['source_ref'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'day': day,
      'category': category,
      'tip_en': tipEn,
      'tip_si': tipSi,
      'source_ref': sourceRef,
    };
  }
}
