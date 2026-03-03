import 'dart:convert';
import 'package:http/http.dart' as http;
import 'auth_service.dart';

class ApiClient {
  final AuthService auth;
  final String baseUrl;

  ApiClient({
    required this.auth,
    this.baseUrl = 'http://10.0.2.2:8000', // Android emulator
  });

  Future<Map<String, dynamic>> get(String path) async {
    final token = await auth.requireIdToken();
    final res = await http.get(
      Uri.parse('$baseUrl$path'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json; charset=UTF-8',
      },
    );

    final body = utf8.decode(res.bodyBytes);
    final data = jsonDecode(body);

    if (res.statusCode != 200) {
      throw Exception(data['detail'] ?? data['error'] ?? 'Server error');
    }
    return data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> post(String path, Map<String, dynamic> payload) async {
    final token = await auth.requireIdToken();
    final res = await http.post(
      Uri.parse('$baseUrl$path'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(payload),
    );

    final body = utf8.decode(res.bodyBytes);
    final data = jsonDecode(body);

    if (res.statusCode != 200) {
      throw Exception(data['detail'] ?? data['error'] ?? 'Server error');
    }
    return data as Map<String, dynamic>;
  }
}