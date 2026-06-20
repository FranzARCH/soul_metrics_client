import '../../domain/entities/question.dart';
import '../../domain/entities/prediction_result.dart';
import '../../domain/repositories/itest_repository.dart';
import '../datasources/assessment_datasource.dart';
import '../dtos/prediction_request_dto.dart';
import '../../../../features/auth/data/services/auth_token_store.dart'; 
import 'dart:typed_data';

class TestRepositoryImpl implements ITestRepository {
  final AssessmentApiDataSource dataSource;
  final AuthTokenStore tokenStore;

  TestRepositoryImpl({
    required this.dataSource, 
    required this.tokenStore,
  });

  // Método privado para leer el token de SharedPreferences de forma asíncrona
  Future<String> _getValidToken() async {
    final token = await tokenStore.getAccessToken();
    if (token == null || token.isEmpty) {
      throw Exception('No se encontró una sesión activa. Inicia sesión nuevamente.');
    }
    return token;
  }

  @override
  Future<List<Question>> getAssessmentQuestions() async {
    final token = await _getValidToken();
    return await dataSource.getQuestions(token);
  }

  @override
  Future<PredictionResult> submitAnswers(Map<String, int> answers, Map<String, int> times) async {
    final token = await _getValidToken();
    final dto = PredictionRequestDto(answers: answers, responseTimes: times);
    return await dataSource.calculatePrediction(token, dto);
  }

  @override
  Future<Uint8List> downloadPdfDossier() async {
    final token = await _getValidToken();
    return await dataSource.downloadPdfReport(token);
  }
}