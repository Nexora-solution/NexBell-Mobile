class UserEntity {
  final int id;
  final String email;
  final String accessToken;
  final String refreshToken;

  UserEntity({
    required this.id,
    required this.email,
    required this.accessToken,
    required this.refreshToken,
  });
}
