import '../../domain/entities/question.dart';
import '../../domain/repositories/itest_repository.dart';

class GetQuestionsUseCase {
  final ITestRepository repository;
  GetQuestionsUseCase(this.repository);

  Future<List<Question>> call() async {
    return await repository.getAssessmentQuestions();
  }
}