import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import '../../domain/entities/question.dart';
import '../dtos/prediction_request_dto.dart';
import '../models/prediction_result_model.dart';

class AssessmentApiDataSource {
  final http.Client client;
  final String baseUrl;

  AssessmentApiDataSource({
    required this.client,
    required this.baseUrl,
  });

  Map<String, String> _headers(String? token, {String accept = 'application/json'}) {
    final headers = {
      'Content-Type': 'application/json',
      'Accept': accept,
    };
    if (token != null) headers['Authorization'] = 'Bearer $token';
    return headers;
  }

  // GET /api/questions/ - Mapeo de diccionario de llaves a lista de entidades
  Future<List<Question>> getQuestions(String token) async {
    final response = await client.get(
      Uri.parse('$baseUrl/api/questions/'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);
      
      // Mapea el objeto {"EXT1": {...}, "EXT3": {...}} a una Lista iterable
      if (decoded is Map<String, dynamic>) {
        final List<Question> questionList = [];
        int index = 1;

        decoded.forEach((key, value) {
          if (value is Map<String, dynamic>) {
            questionList.add(Question(
              id: index++,
              code: key, // "EXT1", "AGR1", etc.
              text: value['text'] ?? '',
              category: value['category'] ?? '',
            ));
          }
        });
        return questionList;
      }
      throw Exception('Estructura de preguntas inesperada en el backend.');
    }
    throw Exception('Error al obtener preguntas: ${response.statusCode}');
  }

  Future<PredictionResultModel> calculatePrediction(String token, PredictionRequestDto dto) async {
    final response = await client.post(
      Uri.parse('$baseUrl/api/predict/'),
      headers: _headers(token),
      body: jsonEncode(dto.toJson()),
    );

    final Map<String, dynamic> data = jsonDecode(response.body);

    if (response.statusCode == 200 || response.statusCode == 201) {
      return PredictionResultModel.fromJson(data);
    }
    throw Exception(data['error'] ?? 'Error en la inferencia en Django.');
  }

  // NUEVO: GET /api/profile/personality/export/ - Descarga binaria del PDF Dossier
  Future<Uint8List> downloadPdfReport(String token) async {
    final response = await client.get(
      Uri.parse('$baseUrl/api/profile/personality/export/'),
      // Pedimos explícitamente la respuesta binaria del PDF generado
      headers: _headers(token, accept: 'application/pdf'), 
    );

    if (response.statusCode == 200) {
      return response.bodyBytes; // Retorna el chorro de bytes crudos del archivo
    }
    throw Exception('El servidor no pudo generar el PDF (${response.statusCode})');
  }
}