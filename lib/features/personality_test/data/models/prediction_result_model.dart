import '../../domain/entities/prediction_result.dart';

class PredictionResultModel extends PredictionResult {
  PredictionResultModel({
    required super.id,
    required super.status,
    required super.personalityPrediction,
    required super.traitDescriptions,
    required super.graphicsData,
    required super.message,
  });

  factory PredictionResultModel.fromJson(Map<String, dynamic> json) {
    // Forzamos un mapa explícito <String, double> limpiando inferencias dinámicas
    final Map<String, double> predictionMap = {};
    final rawPrediction = json['personality_prediction'] as Map<String, dynamic>? ?? {};
    rawPrediction.forEach((key, value) {
      predictionMap[key] = double.tryParse(value.toString()) ?? 0.0;
    });

    return PredictionResultModel(
      id: json['id'] ?? 0,
      status: json['status'] ?? 'success',
      personalityPrediction: predictionMap,
      traitDescriptions: Map<String, String>.from(json['trait_descriptions'] ?? {}),
      graphicsData: json['graphics_data'] ?? {},
      message: json['message'] ?? '',
    );
  }
}