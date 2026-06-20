class LoginDto {
  final String usernameOrEmail;
  final String password;

  LoginDto({required this.usernameOrEmail, required this.password});

  Map<String, dynamic> toJson() {
    return {
      'username': usernameOrEmail,
      'password': password,
    };
  }
}