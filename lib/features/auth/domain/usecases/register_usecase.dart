import '../entities/user_entity.dart';
import '../repositories/iauth_repository.dart';

class RegisterUseCase {
  final IAuthRepository repository;

  RegisterUseCase(this.repository);

  Future<User> call(String username, String firstName, String lastName, String email, String password) {
    if (username.isEmpty || email.isEmpty || password.length < 8) {
      throw Exception('Datos inválidos. La contraseña debe tener al menos 8 caracteres.');
    }
    return repository.register(username, firstName, lastName, email, password);
  }
}