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
  String? error;
  PredictionResult? result;

  // Almacenamiento local de respuestas interactivas: { 'EXT1': 4 }
  final Map<String, int> _answers = {};
  
  // Control de tiempos transcurridos por pregunta
  final Map<String, int> _responseTimes = {};
  late DateTime _questionStartTime;

  Map<String, int> get answers => _answers;

  Future<void> loadQuestions() async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      questions = await getQuestionsUseCase();
      _questionStartTime = DateTime.now(); // Inicia reloj de primera pregunta
      isLoading = false;
    } catch (e) {
      error = e.toString();
      isLoading = false;
    }
    notifyListeners();
  }

  void selectAnswer(int value) {
    if (questions.isEmpty) return;
    
    final currentQuestion = questions[currentIndex];
    
    // Calcula tiempo transcurrido en milisegundos para la pregunta actual
    final duration = DateTime.now().difference(_questionStartTime).inMilliseconds;
    _responseTimes[currentQuestion.code] = (_responseTimes[currentQuestion.code] ?? 0) + duration;

    // Registra la respuesta Likert seleccionada
    _answers[currentQuestion.code] = value;
    notifyListeners();
  }

  void nextQuestion() {
    if (currentIndex < questions.length - 1) {
      currentIndex++;
      _questionStartTime = DateTime.now(); // Reinicia el cronómetro para la nueva pregunta
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
}