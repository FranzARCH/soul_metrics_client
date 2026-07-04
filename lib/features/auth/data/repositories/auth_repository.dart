import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/iauth_repository.dart';
import '../datasources/auth_api_datasource.dart';
import '../dtos/login_dto.dart';
import '../dtos/register_dto.dart';
import '../models/auth_tokens_model.dart';
import '../models/user_model.dart';
import '../services/auth_token_store.dart';

class AuthRepository implements IAuthRepository {
  final AuthApiDataSource apiDataSource;
  final AuthTokenStore tokenStore;

  AuthRepository(
    this.apiDataSource,
    this.tokenStore,
  );

  @override
  Future<User> login(String usernameOrEmail, String password) async {
    final dto = LoginDto(usernameOrEmail: usernameOrEmail, password: password);
    final response = await apiDataSource.login(dto);
    final tokens = _extractTokens(response);
    await tokenStore.saveTokens(accessToken: tokens.accessToken, refreshToken: tokens.refreshToken);
    return _resolveUserFromAuthResponse(response);
  }

  @override
  Future<User> register(String username, String email, String password, int age, String occupation) async {
    final dto = RegisterDto(
      username: username,
      email: email,
      password: password,
      age: age,
      occupation: occupation,
    );
    final response = await apiDataSource.register(dto);

    final userPayload = _extractUserPayload(response);
    if (userPayload != null) {
      return UserModel.fromJson(userPayload);
    }

    return User(
      id: 0,
      username: username,
      email: email,
      age: age,
      occupation: occupation,
      isActive: true,
    );
  }

  @override
  Future<User> getProfile() async {
    return _withAccessToken((token) async {
      final response = await apiDataSource.getProfile(token);
      final payload = _extractUserPayload(response) ?? response;
      return UserModel.fromJson(payload);
    });
  }

  @override
  Future<User> updateProfile(String username, String email, int age, String occupation) async {
    return _withAccessToken((token) async {
      final response = await apiDataSource.updateProfile(token, {
        'username': username,
        'email': email,
        'edad': age,
        'ocupacion': occupation,
      });
      final payload = _extractUserPayload(response) ?? response;
      return UserModel.fromJson(payload);
    });
  }

  @override
  Future<void> logout() async {
    final refreshToken = await tokenStore.getRefreshToken();

    if (refreshToken != null && refreshToken.isNotEmpty) {
      try {
        await apiDataSource.logout(refreshToken);
      } catch (_) {
        // We still clear local session even if remote blacklist fails.
      }
    }

    await tokenStore.clear();
  }

  @override
  Future<bool> restoreSession() async {
    final refreshToken = await tokenStore.getRefreshToken();
    if (refreshToken == null || refreshToken.isEmpty) {
      return false;
    }

    final accessToken = await tokenStore.getAccessToken();
    if (accessToken == null || accessToken.isEmpty) {
      final refreshed = await _refreshAccessToken();
      if (!refreshed) {
        await tokenStore.clear();
        return false;
      }
    }

    try {
      await getProfile();
      return true;
    } catch (_) {
      final refreshed = await _refreshAccessToken();
      if (!refreshed) {
        await tokenStore.clear();
        return false;
      }

      try {
        await getProfile();
        return true;
      } catch (_) {
        await tokenStore.clear();
        return false;
      }
    }
  }

  Future<User> _resolveUserFromAuthResponse(Map<String, dynamic> response) async {
    final payload = _extractUserPayload(response);
    if (payload != null) {
      return UserModel.fromJson(payload);
    }

    return getProfile();
  }

  Map<String, dynamic>? _extractUserPayload(Map<String, dynamic> response) {
    final direct = response['user'];
    if (direct is Map<String, dynamic>) return direct;

    final data = response['data'];
    if (data is Map<String, dynamic>) {
      final nestedUser = data['user'];
      if (nestedUser is Map<String, dynamic>) return nestedUser;

      if (data.containsKey('username') || data.containsKey('email')) {
        return data;
      }
    }

    if (response.containsKey('username') || response.containsKey('email')) {
      return response;
    }

    return null;
  }

  AuthTokensModel _extractTokens(Map<String, dynamic> response) {
    final directAccess = response['access'];
    final directRefresh = response['refresh'];
    if (directAccess is String && directRefresh is String) {
      return AuthTokensModel(accessToken: directAccess, refreshToken: directRefresh);
    }

    final tokens = response['tokens'];
    if (tokens is Map<String, dynamic>) {
      final access = tokens['access'];
      final refresh = tokens['refresh'];
      if (access is String && refresh is String) {
        return AuthTokensModel(accessToken: access, refreshToken: refresh);
      }
    }

    throw Exception('La API no devolvió tokens válidos.');
  }

  Future<bool> _refreshAccessToken() async {
    final refreshToken = await tokenStore.getRefreshToken();
    if (refreshToken == null || refreshToken.isEmpty) {
      return false;
    }

    try {
      final response = await apiDataSource.refreshToken(refreshToken);
      final accessToken = response['access'];
      final nextRefreshToken = response['refresh'];

      if (accessToken is! String || accessToken.isEmpty) {
        return false;
      }

      await tokenStore.saveTokens(
        accessToken: accessToken,
        refreshToken: (nextRefreshToken is String && nextRefreshToken.isNotEmpty) ? nextRefreshToken : refreshToken,
      );
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<T> _withAccessToken<T>(Future<T> Function(String token) action) async {
    var accessToken = await tokenStore.getAccessToken();

    if (accessToken == null || accessToken.isEmpty) {
      final refreshed = await _refreshAccessToken();
      if (!refreshed) throw Exception('Sesión expirada. Inicia sesión nuevamente.');
      accessToken = await tokenStore.getAccessToken();
    }

    if (accessToken == null || accessToken.isEmpty) {
      throw Exception('No se pudo recuperar el token de acceso.');
    }

    try {
      return await action(accessToken);
    } catch (e) {
      final errorText = e.toString().toLowerCase();
      final shouldRefresh = errorText.contains('401') || errorText.contains('unauthorized') || errorText.contains('not authenticated');

      if (!shouldRefresh) rethrow;

      final refreshed = await _refreshAccessToken();
      if (!refreshed) rethrow;

      final newToken = await tokenStore.getAccessToken();
      if (newToken == null || newToken.isEmpty) rethrow;
      return action(newToken);
    }
  }
}