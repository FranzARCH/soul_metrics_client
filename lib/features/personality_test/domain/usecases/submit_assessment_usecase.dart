import '../entities/prediction_result.dart';
import '../repositories/itest_repository.dart';

class SubmitAssessmentUseCase {
  final ITestRepository repository;

  SubmitAssessmentUseCase(this.repository);

  Future<PredictionResult> call(Map<String, int> answers, Map<String, int> times) async {
    if (answers.length < 50) {
      throw Exception('Debes responder todas las preguntas antes de enviar.');
    }
    return await repository.submitAnswers(answers, times);
  }
}