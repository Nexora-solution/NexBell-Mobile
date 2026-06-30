import '../entities/resident_entity.dart';

abstract class SettingsRepository {
  Future<ResidentEntity> getResidentInfo(int apartmentId);
  Future<ResidentEntity> updateContactInfo(int residentId, String email, String phone);
  Future<void> changePassword(String email, String oldPassword, String newPassword);
}
