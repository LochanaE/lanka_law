import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/act_item.dart';

class ActsApiService {
  static const String baseUrl = 'http://10.0.2.2:8000';

  Future<List<ActItem>> fetchActs({
    String? lang,
    int? year,
  }) async {
    try {
      final safeLang = (lang == null || lang.trim().isEmpty) ? 'en' : lang.trim();

      final uri = Uri.parse('$baseUrl/acts').replace(
        queryParameters: {
          'lang': safeLang,
          if (year != null) 'year': year.toString(),
        },
      );

      final response = await http.get(uri).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final decoded = utf8.decode(response.bodyBytes);
        final Map<String, dynamic> jsonMap = jsonDecode(decoded);

        final List<dynamic> items = (jsonMap['items'] as List<dynamic>? ?? []);

        return items
            .map((e) => ActItem.fromJson(e as Map<String, dynamic>))
            .toList();
      } else {
        throw Exception('Failed to load acts: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  Future<String> fetchSignedUrl(String actId, {int expires = 3600}) async {
    try {
      final uri = Uri.parse('$baseUrl/acts/$actId/signed-url')
          .replace(queryParameters: {'expires': expires.toString()});

      final response = await http.get(uri).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final decoded = utf8.decode(response.bodyBytes);
        final Map<String, dynamic> data = jsonDecode(decoded);
        return (data['signed_url'] ?? '').toString();
      } else {
        throw Exception('Failed to get signed URL: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }
}
