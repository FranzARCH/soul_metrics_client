import '../models/user_model.dart';
import '../dtos/login_dto.dart';
import '../dtos/register_dto.dart';

class AuthMockDataSource {
  final List<Map<String, dynamic>> _usersDb = [
    {
      'id': 1,
      'username': 'sofi-sarmiento',
      'email': 'sofi@soulmetrics.com',
      'age': 21,
      'occupation': 'Estudiante de Psicologia',
      'password': 'password123',
      'is_active': true,
    }
  ];

  Future<UserModel> login(LoginDto request) async {
    await Future.delayed(const Duration(seconds: 1)); 

    final user = _usersDb.where((u) => 
      (u['username'] == request.usernameOrEmail || u['email'] == request.usernameOrEmail) && 
      u['password'] == request.password
    ).toList();

    if (user.isEmpty) throw Exception('Credenciales incorrectas');
    if (user.first['is_active'] == false) throw Exception('Cuenta inactiva');

    return UserModel.fromJson(user.first);
  }

  Future<UserModel> register(RegisterDto request) async {
    await Future.delayed(const Duration(seconds: 1));

    if (_usersDb.any((u) => u['username'] == request.username)) {
      throw Exception('El nombre de usuario ya existe');
    }
    if (_usersDb.any((u) => u['email'] == request.email)) {
      throw Exception('El correo ya está registrado');
    }

    final newUser = {
      'id': _usersDb.length + 1,
      'username': request.username,
      'email': request.email,
      'age': request.age,
      'occupation': request.occupation,
      'password': request.password, 
      'is_active': true,
    };

    _usersDb.add(newUser);
    return UserModel.fromJson(newUser);
  }
}