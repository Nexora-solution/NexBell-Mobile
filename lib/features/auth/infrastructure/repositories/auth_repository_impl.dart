import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasource/auth_remote_datasource.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;

  AuthRepositoryImpl(this.remoteDataSource);

  @override
  Future<UserEntity> login(String email, String password) async {
    try {
      final userModel = await remoteDataSource.login(email, password);
      return userModel;
    } catch (e) {
      // Here you would typically map to a Failure object
      rethrow;
    }
  }

  @override
  Future<void> logout(String refreshToken) async {
    await remoteDataSource.logout(refreshToken);
  }

  @override
  Future<String> requestPasswordReset(String email) async {
    return await remoteDataSource.requestPasswordReset(email);
  }

  @override
  Future<void> confirmPasswordReset(String token, String newPassword) async {
    await remoteDataSource.confirmPasswordReset(token, newPassword);
  }

  @override
  Future<void> changePassword(String email, String oldPassword, String newPassword) async {
    await remoteDataSource.changePassword(email, oldPassword, newPassword);
  }
}
