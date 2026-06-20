import 'dart:typed_data'; // <-- Clave para reconocer los bytes del PDF sin errores
import 'package:flutter/material.dart';
import '../../domain/entities/question.dart';
import '../../domain/entities/prediction_result.dart';
import '../../domain/usecases/get_questions_usecase.dart';
import '../../domain/usecases/submit_assessment_usecase.dart';

class QuestionViewModel extends ChangeNotifier {
  final GetQuestionsUseCase getQuestionsUseCase;
  final SubmitAssessmentUseCase submitAssessmentUseCase;

  QuestionViewModel({
    required this.getQuestionsUseCase,
    required this.submitAssessmentUseCase,
  });

  List<Question> questions = [];
  int currentIndex = 0;
  bool isLoading = false;
  bool isPdfDownloading = false; // <-- Controla el estado de carga del botón del PDF
  String? error;
  PredictionResult? result;

  final Map<String, int> _answers = {};
  final Map<String, int> _responseTimes = {};
  late DateTime _questionStartTime;

  Map<String, int> get answers => _answers;

  Future<void> loadQuestions() async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      questions = await getQuestionsUseCase();
      _questionStartTime = DateTime.now();
      isLoading = false;
    } catch (e) {
      error = e.toString().replaceAll('Exception: ', '');
      isLoading = false;
    }
    notifyListeners();
  }

  void selectAnswer(int value) {
    if (questions.isEmpty) return;
    
    final currentQuestion = questions[currentIndex];
    final duration = DateTime.now().difference(_questionStartTime).inMilliseconds;
    _responseTimes[currentQuestion.code] = (_responseTimes[currentQuestion.code] ?? 0) + duration;

    _answers[currentQuestion.code] = value;
    notifyListeners();
  }

  void nextQuestion() {
    if (currentIndex < questions.length - 1) {
      currentIndex++;
      _questionStartTime = DateTime.now();
      notifyListeners();
    }
  }

  void previousQuestion() {
    if (currentIndex > 0) {
      currentIndex--;
      _questionStartTime = DateTime.now();
      notifyListeners();
    }
  }

  Future<bool> sendAssessment() async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      result = await submitAssessmentUseCase(_answers, _responseTimes);
      isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      error = e.toString().replaceAll('Exception: ', '');
      isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // NUEVO: Invoca la descarga binaria real a través del caso de uso / repositorio
  Future<Uint8List?> exportReportPdf() async {
    isPdfDownloading = true;
    error = null;
    notifyListeners();

    try {
      // Accede al contrato de descarga acoplado en tu arquitectura limpia
      final pdfBytes = await submitAssessmentUseCase.repository.downloadPdfDossier();
      isPdfDownloading = false;
      notifyListeners();
      return pdfBytes;
    } catch (e) {
      error = e.toString().replaceAll('Exception: ', '');
      isPdfDownloading = false;
      notifyListeners();
      return null;
    }
  }
}