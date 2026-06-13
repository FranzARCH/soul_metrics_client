import '../entities/question.dart';
import '../entities/prediction_result.dart';

abstract class ITestRepository {
  Future<List<Question>> getAssessmentQuestions();
  Future<PredictionResult> submitAnswers(Map<String, int> answers, Map<String, int> times);
}