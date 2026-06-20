import '../entities/user_entity.dart';
import '../repositories/iauth_repository.dart';

class UpdateProfileUseCase {
  final IAuthRepository repository;

  UpdateProfileUseCase(this.repository);

  Future<User> call(int age, String occupation) {
    if (age <= 0 || occupation.trim().isEmpty) {
      throw Exception('Datos de perfil inválidos.');
    }
    return repository.updateProfile(age, occupation.trim());
  }
}
