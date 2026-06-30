import 'dart:convert';
import '../../../../common/utils/api_client.dart';
import '../models/resident_model.dart';

class SettingsRemoteDataSource {
  Future<ResidentModel> getResidentInfo(int apartmentId) async {
    final response = await ApiClient.get('/api/directory/apartments/$apartmentId/resident');
    if (response.statusCode == 200) {
      return ResidentModel.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to fetch resident info');
    }
  }

  Future<ResidentModel> updateContactInfo(int residentId, String email, String phone) async {
    final response = await ApiClient.put(
      '/api/directory/residents/$residentId/contact',
      body: {
        'email': email,
        'phone': phone,
      },
    );
    if (response.statusCode == 200) {
      return ResidentModel.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to update contact info');
    }
  }

  Future<void> changePassword(String email, String oldPassword, String newPassword) async {
    final response = await ApiClient.put(
      '/api/iam/password/change',
      body: {
        'email': email,
        'oldPassword': oldPassword,
        'newPassword': newPassword,
      },
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to change password');
    }
  }
}
