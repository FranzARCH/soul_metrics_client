import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../dtos/login_dto.dart';
import '../dtos/register_dto.dart';

class AuthApiDataSource {
  final http.Client client;
  final String baseUrl;

  AuthApiDataSource({
    required this.client,
    this.baseUrl = 'https://soulmetrics.onrender.com',
  });

  Future<Map<String, dynamic>> register(RegisterDto request) async {
    final response = await _safeRequest(() => client.post(
          Uri.parse('$baseUrl/api/auth/register/'),
          headers: _defaultHeaders,
          body: jsonEncode(request.toJson()),
        ));

    return _decodeOrThrow(response);
  }

  Future<Map<String, dynamic>> login(LoginDto request) async {
    final response = await _safeRequest(() => client.post(
          Uri.parse('$baseUrl/api/auth/login/'),
          headers: _defaultHeaders,
          body: jsonEncode(request.toJson()),
        ));

    return _decodeOrThrow(response);
  }

  Future<Map<String, dynamic>> refreshToken(String refreshToken) async {
    final response = await _safeRequest(() => client.post(
          Uri.parse('$baseUrl/api/auth/login/refresh/'),
          headers: _defaultHeaders,
          body: jsonEncode({'refresh': refreshToken}),
        ));

    return _decodeOrThrow(response);
  }

  Future<void> logout(String refreshToken) async {
    final response = await _safeRequest(() => client.post(
          Uri.parse('$baseUrl/api/auth/logout/'),
          headers: _defaultHeaders,
          body: jsonEncode({'refresh': refreshToken}),
        ));

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(_extractErrorMessage(response.body) ?? 'No se pudo cerrar sesión.');
    }
  }

  Future<Map<String, dynamic>> getProfile(String accessToken) async {
    final response = await _safeRequest(() => client.get(
          Uri.parse('$baseUrl/api/auth/profile/'),
          headers: {
            ..._defaultHeaders,
            'Authorization': 'Bearer $accessToken',
          },
        ));

    return _decodeOrThrow(response);
  }

  Future<Map<String, dynamic>> updateProfile(String accessToken, Map<String, dynamic> body) async {
    final response = await _safeRequest(() => client.put(
          Uri.parse('$baseUrl/api/auth/profile/'),
          headers: {
            ..._defaultHeaders,
            'Authorization': 'Bearer $accessToken',
          },
          body: jsonEncode(body),
        ));

    return _decodeOrThrow(response);
  }

  Map<String, dynamic> _decodeOrThrow(http.Response response) {
    final decoded = jsonDecode(response.body);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (decoded is Map<String, dynamic>) {
        return decoded;
      }
      return {'data': decoded};
    }

    final message = _extractErrorMessage(response.body) ?? 'Error en la solicitud de autenticación.';
    throw Exception(message);
  }

  String? _extractErrorMessage(String body) {
    try {
      final decoded = jsonDecode(body);
      if (decoded is Map<String, dynamic>) {
        final possibleMessage = decoded['detail'] ?? decoded['message'] ?? decoded['error'];
        if (possibleMessage != null) return possibleMessage.toString();
      }
    } catch (_) {
      return null;
    }
    return null;
  }

  Future<http.Response> _safeRequest(Future<http.Response> Function() request) async {
    try {
      return await request();
    } on http.ClientException catch (_) {
      throw Exception('No se pudo conectar con el backend (client failed to fetch). En Flutter Web suele ser CORS del servidor.');
    } on SocketException {
      throw Exception('No se pudo conectar con el backend. Verifica conexión e URL base.');
    }
  }

  Map<String, String> get _defaultHeaders => const {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };
}
