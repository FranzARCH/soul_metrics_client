import '../entities/user_entity.dart';

abstract class IAuthRepository {
  Future<User> login(String usernameOrEmail, String password);
  Future<User> register(String username, String email, String password, int age, String occupation);
  Future<User> getProfile();
  Future<User> updateProfile(int age, String occupation);
  Future<void> logout();
  Future<bool> restoreSession();
}