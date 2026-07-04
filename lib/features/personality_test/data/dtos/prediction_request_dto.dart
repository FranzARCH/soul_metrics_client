class PredictionRequestDto {
  final Map<String, int> answers;

  PredictionRequestDto({required this.answers});

  Map<String, dynamic> toJson() {
    return Map<String, dynamic>.from(answers);
  }
}