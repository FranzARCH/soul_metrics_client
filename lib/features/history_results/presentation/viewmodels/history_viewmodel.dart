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
      final lowerQuery = query.toLowerCase();
      filteredRecords = historyRecords.where((record) {
        // Filtra por ID del reporte
        final idMatch = record.id.toString().contains(query);
        
        // Filtra por claves de rasgos (EST, OPN, EXT, etc.)
        final traitKeyMatch = record.predictedScores.keys
            .any((key) => key.toLowerCase().contains(lowerQuery));
        
        // Filtra por descripciones de rasgos
        final descMatch = record.traitDescriptions.values
            .any((desc) => desc.toLowerCase().contains(lowerQuery));
        
        // Filtra por fecha (formato día/mes/año)
        final dateString = '${record.createdAt.day}/${record.createdAt.month}/${record.createdAt.year}';
        final dateMatch = dateString.contains(query);
        
        return idMatch || traitKeyMatch || descMatch || dateMatch;
      }).toList();
    }
    notifyListeners();
  }
}