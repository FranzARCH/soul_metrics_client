import '../entities/history_item.dart';

abstract class IHistoryRepository {
  Future<List<HistoryItem>> getUserPredictionHistory();
}