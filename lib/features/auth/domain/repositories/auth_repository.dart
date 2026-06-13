import '../entities/user_entity.dart';

abstract class AuthRepository {
  Future<UserEntity> login(String email, String password);
  Future<void> logout(String refreshToken);
  Future<String> requestPasswordReset(String email);
  Future<void> confirmPasswordReset(String token, String newPassword);
  Future<void> changePassword(String email, String oldPassword, String newPassword);
}
