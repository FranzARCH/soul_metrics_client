import '../../domain/entities/user_entity.dart';

class UserModel extends User {
  UserModel({
    required super.id,
    required super.username,
    required super.email,
    super.age,
    super.occupation,
    required super.isActive,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    final ageValue = json['age'] ?? json['edad'];
    final occupationValue = json['occupation'] ?? json['ocupacion'];

    return UserModel(
      id: (json['id'] ?? 0) as int,
      username: (json['username'] ?? '').toString(),
      email: (json['email'] ?? '').toString(),
      age: ageValue is int ? ageValue : int.tryParse(ageValue?.toString() ?? ''),
      occupation: occupationValue?.toString(),
      isActive: json['is_active'] ?? true,
    );
  }
}