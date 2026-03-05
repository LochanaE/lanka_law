class ActItem {
  final String id;
  final String? actNo;
  final String title;
  final DateTime? publishedDate;
  final String? language;
  final String? filePath;
  final int? year;

  ActItem({
    required this.id,
    this.actNo,
    required this.title,
    this.publishedDate,
    this.language,
    this.filePath,
    this.year,
  });

  factory ActItem.fromJson(Map<String, dynamic> json) {
    return ActItem(
      id: json['id']?.toString() ?? '',
      actNo: json['act_no']?.toString(),
      title: json['title']?.toString() ?? '',
      publishedDate: _parseDate(json['published_date']),
      language: json['language']?.toString(),
      filePath: json['file_path']?.toString(),
      year: json['year'] != null ? int.tryParse(json['year'].toString()) : null,
    );
  }

  static DateTime? _parseDate(dynamic dateStr) {
    if (dateStr == null) return null;
    try {
      return DateTime.parse(dateStr.toString());
    } catch (e) {
      return null;
    }
  }
}
