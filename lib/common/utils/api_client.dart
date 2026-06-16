import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/api_config.dart';

class ApiClient {
  static const String _tokenKey = 'nb_auth_token';
  static const String _refreshKey = 'nb_refresh_token';
  static const String _userIdKey = 'nb_user_id';
  static const String _apartmentIdKey = 'nb_apartment_id';
  static const String _residentIdKey = 'nb_resident_id';

  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  static Future<void> saveRefreshToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_refreshKey, token);
  }

  static Future<String?> getRefreshToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_refreshKey);
  }

  static Future<void> saveUserData({
    required int userId,
    required int apartmentId,
    required int residentId,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_userIdKey, userId);
    await prefs.setInt(_apartmentIdKey, apartmentId);
    await prefs.setInt(_residentIdKey, residentId);
  }

  static Future<int?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_userIdKey);
  }

  static Future<int?> getApartmentId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_apartmentIdKey);
  }

  static Future<int?> getResidentId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_residentIdKey);
  }

  static Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_refreshKey);
    await prefs.remove(_userIdKey);
    await prefs.remove(_apartmentIdKey);
    await prefs.remove(_residentIdKey);
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

  static Future<http.Response> put(String path, {Object? body}) async {
    final baseUrl = apiBase();
    final url = Uri.parse('$baseUrl$path');
    final headers = await _getHeaders();
    final bodyStr = body != null ? jsonEncode(body) : null;
    return http.put(url, headers: headers, body: bodyStr);
  }

  static Future<http.Response> delete(String path) async {
    final baseUrl = apiBase();
    final url = Uri.parse('$baseUrl$path');
    final headers = await _getHeaders();
    return http.delete(url, headers: headers);
  }

  /// Parse a LocalDateTime returned by Spring Boot (serialized as int array).
  /// Format: [year, month, day, hour, minute, second, nano] or ISO string.
  static DateTime? parseDateTime(dynamic value) {
    if (value == null) return null;
    if (value is String) return DateTime.tryParse(value);
    if (value is List && value.length >= 5) {
      return DateTime(
        value[0] as int,
        value[1] as int,
        value[2] as int,
        value[3] as int,
        value[4] as int,
        value.length > 5 ? (value[5] as int) : 0,
      );
    }
    return null;
  }
}
