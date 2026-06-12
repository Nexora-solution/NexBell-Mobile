import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/api_config.dart';

class ApiClient {
  static const String _tokenKey = 'nb_auth_token';

  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  static Future<void> clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
  }

  static Future<Map<String, String>> _getHeaders() async {
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    final token = await getToken();
    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  static Future<http.Response> get(String path) async {
    final baseUrl = apiBase();
    final url = Uri.parse('$baseUrl$path');
    final headers = await _getHeaders();
    return http.get(url, headers: headers);
  }

  static Future<http.Response> post(String path, {Object? body}) async {
    final baseUrl = apiBase();
    final url = Uri.parse('$baseUrl$path');
    final headers = await _getHeaders();
    final bodyStr = body != null ? jsonEncode(body) : null;
    return http.post(url, headers: headers, body: bodyStr);
  }
}
