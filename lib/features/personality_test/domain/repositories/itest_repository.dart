import '../entities/question.dart';
import '../entities/prediction_result.dart';
import 'dart:typed_data';

abstract class ITestRepository {
  Future<List<Question>> getAssessmentQuestions();
  Future<PredictionResult> submitAnswers(Map<String, int> answers);
  Future<Uint8List> downloadPdfDossier();
}