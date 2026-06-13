import '../../../../common/errors/failures.dart';
import '../../domain/entities/resident_entity.dart';
import '../../domain/repositories/settings_repository.dart';
import '../datasource/settings_remote_datasource.dart';

class SettingsRepositoryImpl implements SettingsRepository {
  final SettingsRemoteDataSource remoteDataSource;

  SettingsRepositoryImpl(this.remoteDataSource);

  @override
  Future<ResidentEntity> getResidentInfo(int apartmentId) async {
    try {
      return await remoteDataSource.getResidentInfo(apartmentId);
    } catch (e) {
      throw ServerFailure('Failed to load resident info');
    }
  }

  @override
  Future<ResidentEntity> updateContactInfo(int residentId, String email, String phone) async {
    try {
      return await remoteDataSource.updateContactInfo(residentId, email, phone);
    } catch (e) {
      throw ServerFailure('Failed to update contact info');
    }
  }

  @override
  Future<void> changePassword(String email, String oldPassword, String newPassword) async {
    try {
      await remoteDataSource.changePassword(email, oldPassword, newPassword);
    } catch (e) {
      throw AuthFailure('Failed to change password');
    }
  }
}
