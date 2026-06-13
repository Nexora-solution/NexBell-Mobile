import 'dart:convert';
import '../../../../common/utils/api_client.dart';
import '../models/user_model.dart';

class AuthRemoteDataSource {
  Future<UserModel> login(String email, String password) async {
    final response = await ApiClient.post('/api/iam/login', body: {
      'email': email,
      'password': password,
    });

    if (response.statusCode == 200) {
      return UserModel.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to login: ${response.body}');
    }
  }

  Future<void> logout(String refreshToken) async {
    final response = await ApiClient.post('/api/iam/logout?refreshToken=$refreshToken');
    if (response.statusCode != 200) {
      throw Exception('Failed to logout');
    }
  }

  Future<String> requestPasswordReset(String email) async {
    final response = await ApiClient.post('/api/iam/password/request-reset', body: {
      'email': email,
    });
    if (response.statusCode == 200) {
      return response.body;
    } else {
      throw Exception('Failed to request reset');
    }
  }

  Future<void> confirmPasswordReset(String token, String newPassword) async {
    final response = await ApiClient.post('/api/iam/password/confirm-reset', body: {
      'token': token,
      'newPassword': newPassword,
    });
    if (response.statusCode != 200) {
      throw Exception('Failed to confirm reset');
    }
  }

  Future<void> changePassword(String email, String oldPassword, String newPassword) async {
    final response = await ApiClient.put('/api/iam/password/change', body: {
      'email': email,
      'oldPassword': oldPassword,
      'newPassword': newPassword,
    });
    if (response.statusCode != 200) {
      throw Exception('Failed to change password');
    }
  }
}
