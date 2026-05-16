import '../entities/user_entity.dart';
import '../repositories/iauth_repository.dart';

class LoginUseCase {
  final IAuthRepository repository;

  LoginUseCase(this.repository);

  Future<User> call(String usernameOrEmail, String password) {
    if (usernameOrEmail.isEmpty || password.isEmpty) {
      throw Exception('Las credenciales son obligatorias');
    }
    return repository.login(usernameOrEmail, password);
  }
}