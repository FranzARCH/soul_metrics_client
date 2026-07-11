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

  // IMPORTANTE: Removemos el '/' del final por si acaso
  final response = await client.get(
    Uri.parse('$baseUrl/api/profile/personality/export'),
    headers: {
      // CAMBIO 1: Le decimos al backend que aceptamos CUALQUIER cosa (*/*).
      // Esto evita que Django REST Framework filtre y lance el error 406.
      'Accept': '*/*',
      
      // CAMBIO 2: Añadimos un User-Agent común. A veces Gunicorn/Django 
      // bloquea o cambia el comportamiento con peticiones que vienen de "Dart/HttpClient".
      'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36',
      
      'Authorization': 'Bearer $token',
    },
  );

  if (response.statusCode == 200) {
    // Si el backend envió los bytes del PDF de forma nativa en el body,
    // esto los capturará perfectamente sin importar lo que diga el Content-Type.
    return response.bodyBytes;
  }
  
  // Si sigue fallando, ahora sí podremos ver el JSON de error real en la consola
  print("Error del servidor: ${response.body}");
  throw Exception('Error al generar el PDF: ${response.statusCode}');
}
}
