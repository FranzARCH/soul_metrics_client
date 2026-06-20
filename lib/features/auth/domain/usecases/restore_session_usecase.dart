import '../repositories/iauth_repository.dart';

class RestoreSessionUseCase {
  final IAuthRepository repository;

  RestoreSessionUseCase(this.repository);

  Future<bool> call() {
    return repository.restoreSession();
  }
}
