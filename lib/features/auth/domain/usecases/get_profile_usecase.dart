import '../entities/user_entity.dart';
import '../repositories/iauth_repository.dart';

class GetProfileUseCase {
  final IAuthRepository repository;

  GetProfileUseCase(this.repository);

  Future<User> call() {
    return repository.getProfile();
  }
}
