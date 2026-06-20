class Question {
  final int id;
  final String code; // P.ej. "EST1", "AGR3"
  final String text; // Enunciado
  final String category; // 'O', 'C', 'E', 'A', 'N'

  const Question({
    required this.id,
    required this.code,
    required this.text,
    required this.category,
  });

  factory Question.fromJson(Map<String, dynamic> json) {
    return Question(
      id: json['id'] ?? 0,
      code: json['code'] ?? '',
      text: json['text'] ?? '',
      category: json['category'] ?? '',
    );
  }
}