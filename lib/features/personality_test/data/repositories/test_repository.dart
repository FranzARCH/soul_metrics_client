import '../../domain/entities/question.dart';
import '../../domain/entities/prediction_result.dart';
import '../../domain/repositories/itest_repository.dart';
import '../datasources/test_mock.dart';
import '../dtos/prediction_request_dto.dart';

class TestRepositoryImpl implements ITestRepository {
  final TestMockDataSource dataSource;

  TestRepositoryImpl(this.dataSource);

  @override
  Future<List<Question>> getAssessmentQuestions() async {
    return await dataSource.fetchQuestions();
  }

  @override
  Future<PredictionResult> submitAnswers(Map<String, int> answers, Map<String, int> times) async {
    final dto = PredictionRequestDto(answers: answers, responseTimes: times);
    return await dataSource.calculateMockPrediction(dto);
  }
}