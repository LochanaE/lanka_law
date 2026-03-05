class GazetteItem {
  final String id;
  final String title;
  final String gazetteType;
  final String? issueNo;
  final String? language;
  final DateTime? publishedDate;
  final String? filePath;
  final int? fileSize;
  final bool isActive;

  GazetteItem({
    required this.id,
    required this.title,
    required this.gazetteType,
    this.issueNo,
    this.language,
    this.publishedDate,
    this.filePath,
    this.fileSize,
    required this.isActive,
  });

  factory GazetteItem.fromJson(Map<String, dynamic> json) {
    return GazetteItem(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      gazetteType: json['gazette_type']?.toString() ?? 'regular',
      issueNo: json['issue_no']?.toString(),
      language: json['language']?.toString(),
      publishedDate: _parseDate(json['published_date']),
      filePath: json['file_path']?.toString(),
      fileSize: json['file_size'] as int?,
      isActive: json['is_active'] ?? true,
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
