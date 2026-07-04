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

  static Future<http.Response> get(String path) => _send('GET', path);

  static Future<http.Response> post(String path, {Object? body}) =>
      _send('POST', path, body: body);

  static Future<http.Response> put(String path, {Object? body}) =>
      _send('PUT', path, body: body);

  static Future<http.Response> delete(String path) => _send('DELETE', path);

  /// Single request dispatcher. The backend now enforces JWT, so a protected
  /// endpoint returns 401 when the access token is expired/invalid. In that case
  /// we try the refresh token once and replay the request. Auth/onboarding
  /// endpoints are skipped to avoid loops (and they don't need a token anyway).
  static Future<http.Response> _send(String method, String path,
      {Object? body, bool isRetry = false}) async {
    final baseUrl = apiBase();
    final url = Uri.parse('$baseUrl$path');
    final headers = await _getHeaders();
    final bodyStr = body != null ? jsonEncode(body) : null;

    http.Response res;
    switch (method) {
      case 'GET':
        res = await http.get(url, headers: headers);
        break;
      case 'POST':
        res = await http.post(url, headers: headers, body: bodyStr);
        break;
      case 'PUT':
        res = await http.put(url, headers: headers, body: bodyStr);
        break;
      case 'DELETE':
        res = await http.delete(url, headers: headers);
        break;
      default:
        throw ArgumentError('Unsupported method $method');
    }

    final isAuthCall = path.startsWith('/api/iam/login') ||
        path.startsWith('/api/iam/refresh') ||
        path.startsWith('/api/onboarding');
    if ((res.statusCode == 401 || res.statusCode == 403) && !isRetry && !isAuthCall) {
      final refreshed = await _tryRefresh();
      if (refreshed) {
        return _send(method, path, body: body, isRetry: true);
      }
    }
    return res;
  }

  /// Exchanges the stored refresh token for a fresh access/refresh pair.
  /// Returns true and persists the new tokens on success.
  static Future<bool> _tryRefresh() async {
    final refreshToken = await getRefreshToken();
    if (refreshToken == null) return false;
    try {
      final url = Uri.parse('${apiBase()}/api/iam/refresh');
      final res = await http.post(
        url,
        headers: {'Content-Type': 'application/json', 'Accept': 'application/json'},
        body: jsonEncode({'refreshToken': refreshToken}),
      );
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body) as Map<String, dynamic>;
        final newAccess = data['accessToken'] as String?;
        final newRefresh = data['refreshToken'] as String?;
        if (newAccess != null) await saveToken(newAccess);
        if (newRefresh != null) await saveRefreshToken(newRefresh);
        return newAccess != null;
      }
    } catch (_) {
      // Network error or malformed body — treat as refresh failure.
    }
    return false;
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
