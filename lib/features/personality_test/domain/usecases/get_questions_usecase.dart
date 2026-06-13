import '../entities/question.dart';
import '../repositories/itest_repository.dart';

class GetQuestionsUseCase {
  final ITestRepository repository;

  GetQuestionsUseCase(this.repository);

  Future<List<Question>> call() async {
    return await repository.getAssessmentQuestions();
  }
}