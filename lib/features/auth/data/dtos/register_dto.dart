class RegisterDto {
  final String username;
  final String firstName;
  final String lastName;
  final String email;
  final String password;

  RegisterDto({
    required this.username,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.password,
  });

  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'first_name': firstName,
      'last_name': lastName,
      'email': email,
      'password': password,
    };
  }
}