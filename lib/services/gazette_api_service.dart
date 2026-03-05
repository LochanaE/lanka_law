import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/gazette_item.dart';

class GazetteApiService {
  static const String baseUrl = 'http://10.0.2.2:8000';

  Future<List<GazetteItem>> fetchGazettes({
    required String type,
    String? lang,
    int? year,
  }) async {
    try {
      // ✅ Default lang = 'en' (so backend always filters consistently)
      final safeLang = (lang == null || lang.trim().isEmpty)
          ? 'en'
          : lang.trim();

      final uri = Uri.parse('$baseUrl/gazettes').replace(
        queryParameters: {
          'type': type,
          'lang': safeLang,
          if (year != null) 'year': year.toString(),
        },
      );

      final response = await http.get(uri).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final decoded = utf8.decode(response.bodyBytes);
        final Map<String, dynamic> jsonMap = jsonDecode(decoded);

        // ✅ backend returns { "items": [...] }
        final List<dynamic> items = (jsonMap['items'] as List<dynamic>? ?? []);

        return items
            .map((e) => GazetteItem.fromJson(e as Map<String, dynamic>))
            .toList();
      } else {
        throw Exception('Failed to load gazettes: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  Future<String> fetchSignedUrl(String gazetteId, {int expires = 3600}) async {
    try {
      final uri = Uri.parse(
        '$baseUrl/gazettes/$gazetteId/signed-url',
      ).replace(queryParameters: {'expires': expires.toString()});

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

// import 'dart:convert';
// import 'package:http/http.dart' as http;
// import '../models/gazette_item.dart';

// class GazetteApiService {
//   static const String baseUrl = 'http://10.0.2.2:8000';

//   Future<List<GazetteItem>> fetchGazettes({
//     required String type,
//     String? lang,
//     int? year,
//   }) async {
//     try {
//       final uri = Uri.parse('$baseUrl/gazettes').replace(
//         queryParameters: {
//           'type': type,
//           if (lang != null) 'lang': lang,
//           if (year != null) 'year': year.toString(),
//         },
//       );

//       final response = await http
//           .get(
//             uri,
//             headers: {'Content-Type': 'application/json; charset=UTF-8'},
//           )
//           .timeout(const Duration(seconds: 15));

//       final decodedBody = utf8.decode(response.bodyBytes);

//       if (response.statusCode != 200) {
//         // helpful for debugging if backend returns html/error
//         throw Exception(
//           'Failed to load gazettes: ${response.statusCode} | $decodedBody',
//         );
//       }

//       final dynamic jsonData = jsonDecode(decodedBody);

//       // ✅ Backend returns: { "items": [ ... ] }
//       List<dynamic> items;

//       if (jsonData is Map<String, dynamic>) {
//         items = (jsonData['items'] as List<dynamic>? ?? []);
//       } else if (jsonData is List) {
//         // fallback (if backend later changes to raw list)
//         items = jsonData;
//       } else {
//         throw Exception('Unexpected response format: $jsonData');
//       }

//       return items
//           .map((e) => GazetteItem.fromJson(e as Map<String, dynamic>))
//           .toList();
//     } catch (e) {
//       throw Exception('Network error: $e');
//     }
//   }

//   Future<String> fetchSignedUrl(String gazetteId, {int expires = 3600}) async {
//     try {
//       final uri = Uri.parse(
//         '$baseUrl/gazettes/$gazetteId/signed-url',
//       ).replace(queryParameters: {'expires': expires.toString()});

//       final response = await http
//           .get(
//             uri,
//             headers: {'Content-Type': 'application/json; charset=UTF-8'},
//           )
//           .timeout(const Duration(seconds: 15));

//       final decodedBody = utf8.decode(response.bodyBytes);

//       if (response.statusCode != 200) {
//         throw Exception(
//           'Failed to get signed URL: ${response.statusCode} | $decodedBody',
//         );
//       }

//       final dynamic jsonData = jsonDecode(decodedBody);

//       // backend: { "signed_url": "..." }
//       if (jsonData is Map<String, dynamic> && jsonData['signed_url'] != null) {
//         return jsonData['signed_url'].toString();
//       }

//       throw Exception('Unexpected signed-url response: $jsonData');
//     } catch (e) {
//       throw Exception('Network error: $e');
//     }
//   }
// }
