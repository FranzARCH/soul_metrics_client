import '../entities/user_entity.dart';

abstract class IAuthRepository {
  Future<User> login(String usernameOrEmail, String password);
  Future<User> register(String username, String firstName, String lastName, String email, String password);
}