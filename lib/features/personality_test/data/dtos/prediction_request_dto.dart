class PredictionRequestDto {
  final Map<String, int> answers;
  final Map<String, int> responseTimes;

  PredictionRequestDto({required this.answers, required this.responseTimes});

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> jsonPayload = {};
    
    // Mapea las respuestas puestas (Ej: 'EXT1': 4)
    answers.forEach((key, value) {
      jsonPayload[key] = value;
    });

    // Mapea los tiempos transcurridos en el formato esperado de Django (Ej: 'EXT1_E': 2450)
    responseTimes.forEach((key, value) {
      jsonPayload['${key}_E'] = value;
    });

    return jsonPayload;
  }
}