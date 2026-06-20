class PredictionResult {
  final int id;
  final String status;
  final Map<String, double> personalityPrediction;
  final Map<String, String> traitDescriptions;
  final Map<String, dynamic> graphicsData;
  final String message;

  const PredictionResult({
    required this.id,
    required this.status,
    required this.personalityPrediction,
    required this.traitDescriptions,
    required this.graphicsData,
    required this.message,
  });
}