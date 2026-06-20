class HistoryItem {
  final int id;
  final Map<String, dynamic> answersData;
  final Map<String, double> predictedScores;
  final Map<String, String> traitDescriptions;
  final Map<String, dynamic> graphicsData;
  final DateTime createdAt;

  const HistoryItem({
    required this.id,
    required this.answersData,
    required this.predictedScores,
    required this.traitDescriptions,
    required this.graphicsData,
    required this.createdAt,
  });
}