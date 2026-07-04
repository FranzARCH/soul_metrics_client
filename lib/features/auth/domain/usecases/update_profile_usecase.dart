import '../entities/user_entity.dart';
import '../repositories/iauth_repository.dart';

class UpdateProfileUseCase {
  final IAuthRepository repository;

  UpdateProfileUseCase(this.repository);

  Future<User> call(String username, String email, int age, String occupation) {
    final normalizedUsername = username.trim();
    final normalizedEmail = email.trim();
    final normalizedOccupation = occupation.trim();

    if (normalizedUsername.isEmpty ||
        normalizedEmail.isEmpty ||
        !normalizedEmail.contains('@') ||
        age <= 0 ||
        normalizedOccupation.isEmpty) {
      throw Exception('Datos de perfil inválidos.');
    }

    return repository.updateProfile(
      normalizedUsername,
      normalizedEmail,
      age,
      normalizedOccupation,
    );
  }
}
