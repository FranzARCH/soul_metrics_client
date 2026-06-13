class PredictionResult {
  final String status;
  final double personalityPrediction;
  final String personalityType;
  final String message;

  PredictionResult({
    required this.status,
    required this.personalityPrediction,
    required this.personalityType,
    required this.message,
  });
}