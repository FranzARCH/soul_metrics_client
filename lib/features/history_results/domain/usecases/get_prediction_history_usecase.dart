import '../entities/history_item.dart';
import '../repositories/ihistory_repository.dart';

class GetPredictionHistoryUseCase {
  final IHistoryRepository repository;

  GetPredictionHistoryUseCase(this.repository);

  Future<List<HistoryItem>> call() async {
    return await repository.getUserPredictionHistory();
  }
}