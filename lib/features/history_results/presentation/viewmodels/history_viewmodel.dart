import 'package:flutter/material.dart';
import '../../domain/entities/history_item.dart';
import '../../domain/usecases/get_prediction_history_usecase.dart';

class HistoryViewModel extends ChangeNotifier {
  final GetPredictionHistoryUseCase getPredictionHistoryUseCase;

  HistoryViewModel({required this.getPredictionHistoryUseCase});

  List<HistoryItem> historyRecords = [];
  List<HistoryItem> filteredRecords = [];
  bool isLoading = false;
  String? error;

  Future<void> fetchHistory() async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      historyRecords = await getPredictionHistoryUseCase();
      filteredRecords = List.from(historyRecords);
    } catch (e) {
      error = e.toString().replaceAll('Exception: ', '');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void filterSearch(String query) {
    if (query.isEmpty) {
      filteredRecords = List.from(historyRecords);
    } else {
      filteredRecords = historyRecords.where((record) {
        // Filtra de forma flexible por el ID del reporte o por descripciones guardadas
        final idMatch = record.id.toString().contains(query);
        final descMatch = record.traitDescriptions.values
            .any((desc) => desc.toLowerCase().contains(query.toLowerCase()));
        return idMatch || descMatch;
      }).toList();
    }
    notifyListeners();
  }
}