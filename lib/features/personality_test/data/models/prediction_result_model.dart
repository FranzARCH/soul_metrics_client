import '../../domain/entities/prediction_result.dart';

class PredictionResultModel extends PredictionResult {
  PredictionResultModel({
    required super.id,
    required super.status,
    required super.personalityPrediction,
    required super.traitDescriptions,
    super.traitDescription,
    required super.graphicsData,
    required super.message,
  });

  factory PredictionResultModel.fromJson(Map<String, dynamic> json) {
    // Parseo robusto: acepta números directos y objetos anidados {score|value|percentage|probability}
    final Map<String, double> predictionMap = {};
    final rawPrediction = json['personality_prediction'] as Map<String, dynamic>? ?? {};
    rawPrediction.forEach((key, value) {
      if (value is Map<String, dynamic>) {
        final dynamic candidate = value['score'] ?? value['value'] ?? value['percentage'] ?? value['probability'];
        predictionMap[key] = _toDouble(candidate);
      } else {
        predictionMap[key] = _toDouble(value);
      }
    });

    // Parsear trait_descriptions como objeto con title y description
    TraitDescription? traitDesc;
    final rawTraitDesc = json['trait_descriptions'];
    if (rawTraitDesc is Map<String, dynamic>) {
      traitDesc = TraitDescription(
        title: rawTraitDesc['title'] ?? '',
        description: rawTraitDesc['description'] ?? '',
      );
    }

    return PredictionResultModel(
      id: json['id'] ?? 0,
      status: json['status'] ?? 'success',
      personalityPrediction: predictionMap,
      traitDescriptions: Map<String, String>.from(json['trait_descriptions'] ?? {}),
      traitDescription: traitDesc,
      graphicsData: json['graphics_data'] ?? {},
      message: json['message'] ?? '',
    );
  }

  static double _toDouble(dynamic value) {
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '') ?? 0.0;
  }
}