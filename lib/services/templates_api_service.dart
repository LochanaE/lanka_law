import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/template_item.dart';

class TemplatesApiService {
  static const String baseUrl = 'http://10.0.2.2:8000';

  Future<List<TemplateItem>> fetchTemplates({
    required String category,
    String lang = 'en',
    String? subCategory,
    bool featuredOnly = false,
    String? q,
  }) async {
    final Map<String, String> queryParams = {
      'category': category,
      'lang': lang,
    };

    // ✅ backend expects 'sub' (not sub_category)
    if (subCategory != null && subCategory.isNotEmpty && subCategory != 'All') {
      queryParams['sub'] = subCategory;
    }

    if (featuredOnly) {
      queryParams['featured'] = '1';
    }

    if (q != null && q.trim().isNotEmpty) {
      queryParams['q'] = q.trim();
    }

    final uri = Uri.parse(
      '$baseUrl/templates',
    ).replace(queryParameters: queryParams);

    // ✅ Debug prints
    print('[TemplatesApi] GET $uri');

    final response = await http.get(uri);

    print('[TemplatesApi] status=${response.statusCode}');
    final bodyPreview = response.body.length > 400
        ? response.body.substring(0, 400)
        : response.body;
    print('[TemplatesApi] bodyPreview=$bodyPreview');

    if (response.statusCode != 200) {
      throw Exception(
        'Failed to load templates: ${response.statusCode} ${response.body}',
      );
    }

    final decoded = json.decode(response.body);

    // backend returns { "items": [...] }
    final items = (decoded is Map<String, dynamic>) ? decoded['items'] : null;

    if (items is List) {
      final list = items
          .map((e) => TemplateItem.fromJson(e as Map<String, dynamic>))
          .toList();
      print('[TemplatesApi] parsedCount=${list.length}');
      return list;
    }

    // fallback (if backend ever returns plain list)
    if (decoded is List) {
      final list = decoded
          .map((e) => TemplateItem.fromJson(e as Map<String, dynamic>))
          .toList();
      print('[TemplatesApi] parsedCount=${list.length}');
      return list;
    }

    print('[TemplatesApi] Unexpected response structure');
    return [];
  }

  // ✅ templateId is UUID string
  Future<String> getSignedUrl(String templateId) async {
    final uri = Uri.parse('$baseUrl/templates/$templateId/signed-url');

    print('[TemplatesApi] GET $uri');

    final response = await http.get(uri);

    print('[TemplatesApi] signed-url status=${response.statusCode}');
    final bodyPreview = response.body.length > 300
        ? response.body.substring(0, 300)
        : response.body;
    print('[TemplatesApi] signed-url bodyPreview=$bodyPreview');

    if (response.statusCode != 200) {
      throw Exception(
        'Failed signed URL: ${response.statusCode} ${response.body}',
      );
    }

    final Map<String, dynamic> data =
        json.decode(response.body) as Map<String, dynamic>;
    final url = data['signed_url'] as String?;
    if (url == null || url.isEmpty) {
      throw Exception('signed_url missing in response');
    }
    return url;
  }
}
