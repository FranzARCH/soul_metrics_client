import '../../domain/entities/prediction_result.dart';

class PredictionResultModel extends PredictionResult {
  PredictionResultModel({
    required super.status,
    required super.personalityPrediction,
    required super.personalityType,
    required super.message,
  });

  factory PredictionResultModel.fromJson(Map<String, dynamic> json) {
    return PredictionResultModel(
      status: json['status'] ?? 'success',
      personalityPrediction: (json['personality_prediction'] as num).toDouble(),
      personalityType: json['personality_type'] ?? 'Neutral',
      message: json['message'] ?? '',
    );
  }
}