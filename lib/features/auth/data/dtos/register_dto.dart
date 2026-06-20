class RegisterDto {
  final String username;
  final String email;
  final String password;
  final int age;
  final String occupation;

  RegisterDto({
    required this.username,
    required this.email,
    required this.password,
    required this.age,
    required this.occupation,
  });

  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'email': email,
      'password': password,
      'age': age,
      'occupation': occupation,
    };
  }
}