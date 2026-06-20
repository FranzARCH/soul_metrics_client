class User {
  final int id;
  final String username;
  final String email;
  final int? age;
  final String? occupation;
  final bool isActive;

  User({
    required this.id,
    required this.username,
    required this.email,
    this.age,
    this.occupation,
    required this.isActive,
  });
}