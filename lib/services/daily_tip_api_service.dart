import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:io' show Platform;
import '../models/daily_tip.dart';

class DailyTipApiService {
  String get baseUrl {
    if (Platform.isAndroid) {
      return 'http://10.0.2.2:8000';
    } else {
      return 'http://127.0.0.1:8000';
    }
  }

  Future<DailyTip> fetchDailyTip({String? category}) async {
    String url = '$baseUrl/daily-tip';
    if (category != null && category.isNotEmpty) {
      url += '?category=$category';
    }

    print('📡 [DailyTipApiService] Request URL: $url');
    try {
      final response = await http.get(Uri.parse(url));
      print('📡 [DailyTipApiService] Status Code: ${response.statusCode}');
      
      final bodyToPrint = response.body.length > 300 
          ? '${response.body.substring(0, 300)}...' 
          : response.body;
      print('📡 [DailyTipApiService] Body: $bodyToPrint');

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
        return DailyTip.fromJson(jsonResponse);
      } else {
        throw Exception('Failed to load daily tip. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ [DailyTipApiService] Error fetching daily tip: $e');
      throw Exception('Failed to connect to the server');
    }
  }
}
