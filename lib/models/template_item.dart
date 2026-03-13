class TemplateItem {
  final String id; // ✅ UUID string
  final String templateCode;
  final String title;

  final String? description;
  final String fileType; // PDF/DOC/DOCX
  final String? sourceName;
  final String filePath; // templates/business/...
  final bool isFeatured;

  final String mainCategory; // Business/...
  final String subCategory; // Charges/...
  final String language; // en

  TemplateItem({
    required this.id,
    required this.templateCode,
    required this.title,
    this.description,
    required this.fileType,
    this.sourceName,
    required this.filePath,
    required this.isFeatured,
    required this.mainCategory,
    required this.subCategory,
    required this.language,
  });

  factory TemplateItem.fromJson(Map<String, dynamic> json) {
    return TemplateItem(
      id: (json['id'] ?? '').toString(), // ✅ always string
      templateCode: (json['template_code'] ?? '').toString(),
      title: (json['title'] ?? '').toString(),
      description: json['description']?.toString(),
      fileType: (json['file_type'] ?? '').toString(),
      sourceName: json['source_name']?.toString(),
      filePath: (json['file_path'] ?? '').toString(),
      isFeatured: json['is_featured'] == true,
      mainCategory: (json['main_category'] ?? '').toString(),
      subCategory: (json['sub_category'] ?? '').toString(),
      language: (json['language'] ?? 'en').toString(),
    );
  }
}
