import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../domain/entities/history_item.dart';
import '../../domain/repositories/ihistory_repository.dart';
import '../models/history_item_model.dart';
import '../../../../features/auth/data/services/auth_token_store.dart';

class HistoryRepositoryImpl implements IHistoryRepository {
  final http.Client client;
  final AuthTokenStore tokenStore;
  final String baseUrl;

  HistoryRepositoryImpl({
    required this.client,
    required this.tokenStore,
    required this.baseUrl,
  });

  @override
  Future<List<HistoryItem>> getUserPredictionHistory() async {
    final token = await tokenStore.getAccessToken();
    if (token == null || token.isEmpty) {
      throw Exception('Sesión inválida o expirada.');
    }

    final response = await client.get(
      Uri.parse('$baseUrl/api/history/'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);
      
      List? results;
      // Valida si la respuesta viene con paginación estándar de Django Rest Framework
      if (decoded is Map<String, dynamic>) {
        results = decoded['results'] ?? decoded['data'];
      } else if (decoded is List) {
        results = decoded;
      }

      if (results != null) {
        return results.map((item) => HistoryItemModel.fromJson(item)).toList();
      }
      return [];
    }
    throw Exception('Error al recuperar el historial: ${response.statusCode}');
  }
}