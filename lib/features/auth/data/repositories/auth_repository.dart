import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/iauth_repository.dart';
import '../datasources/user_mock.dart';
import '../dtos/login_dto.dart';
import '../dtos/register_dto.dart';

class AuthRepository implements IAuthRepository {
  final AuthMockDataSource mockDataSource;

  AuthRepository(this.mockDataSource);

  @override
  Future<User> login(String usernameOrEmail, String password) async {
    final dto = LoginDto(username: usernameOrEmail, password: password);
    return await mockDataSource.login(dto);
  }

  @override
  Future<User> register(String username, String firstName, String lastName, String email, String password) async {
    final dto = RegisterDto(
      username: username,
      firstName: firstName,
      lastName: lastName,
      email: email,
      password: password,
    );
    return await mockDataSource.register(dto);
  }
}