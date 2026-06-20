import '../entities/user_entity.dart';
import '../repositories/iauth_repository.dart';

class RegisterUseCase {
  final IAuthRepository repository;

  RegisterUseCase(this.repository);

  Future<User> call(String username, String email, String password, int age, String occupation) {
    if (username.isEmpty || email.isEmpty || password.length < 8 || age <= 0 || occupation.isEmpty) {
      throw Exception('Datos inválidos. La contraseña debe tener al menos 8 caracteres.');
    }
    return repository.register(username, email, password, age, occupation);
  }
}