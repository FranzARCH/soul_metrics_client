import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import '../../domain/entities/personality_profile.dart';
import '../../domain/repositories/iprofile_repository.dart';
import '../models/personality_profile_model.dart';
import '../../../../features/auth/data/services/auth_token_store.dart';

class ProfileRepositoryImpl implements IProfileRepository {
  final http.Client client;
  final AuthTokenStore tokenStore;
  final String baseUrl;

  ProfileRepositoryImpl({
    required this.client,
    required this.tokenStore,
    required this.baseUrl,
  });

  @override
  Future<PersonalityProfile> getHolisticProfile() async {
    final token = await tokenStore.getAccessToken();
    if (token == null || token.isEmpty) {
      throw Exception('Sesión expirada o no encontrada.');
    }

    final response = await client.get(
      Uri.parse('$baseUrl/api/profile/personality/'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> decoded = jsonDecode(response.body);
      return PersonalityProfileModel.fromJson(decoded);
    }
    
    throw Exception('Error al recuperar el perfil holístico: ${response.statusCode}');
  }

  @override
  Future<Uint8List> exportPersonalityProfilePdf() async {
    final token = await tokenStore.getAccessToken();
    if (token == null || token.isEmpty) {
      throw Exception('Sesión expirada o no encontrada.');
    }

    final response = await client.get(
      Uri.parse('$baseUrl/api/profile/personality/export/'),
      headers: {
        'Accept': 'application/pdf',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return response.bodyBytes;
    }
    
    throw Exception('Error al generar el PDF: ${response.statusCode}');
  }
}
