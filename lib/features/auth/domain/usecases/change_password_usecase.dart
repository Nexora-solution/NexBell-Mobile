import '../repositories/auth_repository.dart';

class ChangePasswordUseCase {
  final AuthRepository repository;

  ChangePasswordUseCase(this.repository);

  // Based on README: PUT /api/iam/password/change 
  // Requirement: email, oldPassword, newPassword
  Future<void> execute(String email, String oldPassword, String newPassword) {
    // Note: The AuthRepository interface might need update if it doesn't match
    // I will use a custom method for this specific implementation
    return (repository as dynamic).changePassword(email, oldPassword, newPassword);
  }
}
