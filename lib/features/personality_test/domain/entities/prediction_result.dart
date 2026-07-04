class PredictionResult {
  final int id;
  final String status;
  final Map<String, double> personalityPrediction;
  final Map<String, String> traitDescriptions;
  final TraitDescription? traitDescription;
  final Map<String, dynamic> graphicsData;
  final String message;

  const PredictionResult({
    required this.id,
    required this.status,
    required this.personalityPrediction,
    required this.traitDescriptions,
    this.traitDescription,
    required this.graphicsData,
    required this.message,
  });
}

class TraitDescription {
  final String title;
  final String description;

  const TraitDescription({
    required this.title,
    required this.description,
  });
}