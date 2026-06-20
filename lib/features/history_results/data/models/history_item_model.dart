import '../../domain/entities/history_item.dart';

class HistoryItemModel extends HistoryItem {
  HistoryItemModel({
    required super.id,
    required super.answersData,
    required super.predictedScores,
    required super.traitDescriptions,
    required super.graphicsData,
    required super.createdAt,
  });

  factory HistoryItemModel.fromJson(Map<String, dynamic> json) {
    // Limpieza de tipos numéricos explícitos para el mapeo en caliente del historial
    final Map<String, double> scoresMap = {};
    final rawScores = json['predicted_scores'] as Map<String, dynamic>? ?? {};
    rawScores.forEach((key, value) {
      // Si tu backend anida la estructura {"EXT": {"score": 3.8}} extrae la propiedad interna
      if (value is Map<String, dynamic>) {
        scoresMap[key] = double.tryParse(value['score']?.toString() ?? '0.0') ?? 0.0;
      } else {
        scoresMap[key] = double.tryParse(value.toString()) ?? 0.0;
      }
    });

    return HistoryItemModel(
      id: json['id'] ?? 0,
      answersData: json['answers_data'] ?? {},
      predictedScores: scoresMap,
      traitDescriptions: Map<String, String>.from(json['trait_descriptions'] ?? {}),
      graphicsData: json['graphics_data'] ?? {},
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at']) 
          : DateTime.now(),
    );
  }
}