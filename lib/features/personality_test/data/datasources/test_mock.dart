import '../../domain/entities/question.dart';
import '../models/prediction_result_model.dart';
import '../dtos/prediction_request_dto.dart';

class TestMockDataSource {
  // Lista de las 50 preguntas exactas entregadas para el Mock
  final List<Question> _mockQuestions = [
    // Extraversión
    Question(code: "EXT1", category: "Extraversion", text: "Soy el alma de la fiesta"),
    Question(code: "EXT2", category: "Extraversion", text: "No hablo mucho"),
    Question(code: "EXT3", category: "Extraversion", text: "Me siento cómodo con la gente"),
    Question(code: "EXT4", category: "Extraversion", text: "Me mantengo en segundo plano"),
    Question(code: "EXT5", category: "Extraversion", text: "Inicio las conversaciones"),
    Question(code: "EXT6", category: "Extraversion", text: "Tengo poco que decir"),
    Question(code: "EXT7", category: "Extraversion", text: "Hablo con muchas personas distintas en las fiestas"),
    Question(code: "EXT8", category: "Extraversion", text: "No me gusta llamar la atención"),
    Question(code: "EXT9", category: "Extraversion", text: "No me molesta ser el centro de atención"),
    Question(code: "EXT10", category: "Extraversion", text: "Soy callado con los desconocidos"),
    
    // Neuroticismo / Estabilidad Emocional
    Question(code: "EST1", category: "Neuroticism", text: "Me estreso fácilmente"),
    Question(code: "EST2", category: "Neuroticism", text: "Estoy relajado la mayor parte del tiempo"),
    Question(code: "EST3", category: "Neuroticism", text: "Me preocupo por las cosas"),
    Question(code: "EST4", category: "Neuroticism", text: "Rara vez me siento triste/deprimido"),
    Question(code: "EST5", category: "Neuroticism", text: "Me altero con facilidad"),
    Question(code: "EST6", category: "Neuroticism", text: "Me molesto fácilmente"),
    Question(code: "EST7", category: "Neuroticism", text: "Cambio mucho de humor"),
    Question(code: "EST8", category: "Neuroticism", text: "Tengo cambios de humor frecuentes"),
    Question(code: "EST9", category: "Neuroticism", text: "Me irrito fácilmente"),
    Question(code: "EST10", category: "Neuroticism", text: "A menudo me siento deprimido"),

    // Amabilidad
    Question(code: "AGR1", category: "Agreeableness", text: "Siento poca preocupación por los demás"),
    Question(code: "AGR2", category: "Agreeableness", text: "Me intereso por las personas"),
    Question(code: "AGR3", category: "Agreeableness", text: "Insulto a las personas"),
    Question(code: "AGR4", category: "Agreeableness", text: "Simpatizo con los sentimientos de otros"),
    Question(code: "AGR5", category: "Agreeableness", text: "No me interesan los problemas ajenos"),
    Question(code: "AGR6", category: "Agreeableness", text: "Tengo un corazón blando"),
    Question(code: "AGR7", category: "Agreeableness", text: "No me interesan realmente los demás"),
    Question(code: "AGR8", category: "Agreeableness", text: "Dedico tiempo a los demás"),
    Question(code: "AGR9", category: "Agreeableness", text: "Siento las emociones de los demás"),
    Question(code: "AGR10", category: "Agreeableness", text: "Hago que la gente se sienta cómoda"),

    // Responsabilidad
    Question(code: "CSN1", category: "Conscientiousness", text: "Always listo / Siempre estoy preparado"),
    Question(code: "CSN2", category: "Conscientiousness", text: "Dejo mis cosas tiradas"),
    Question(code: "CSN3", category: "Conscientiousness", text: "Presto atención a los detalles"),
    Question(code: "CSN4", category: "Conscientiousness", text: "Hago un desastre de las cosas"),
    Question(code: "CSN5", category: "Conscientiousness", text: "Hago mis deberes de inmediato"),
    Question(code: "CSN6", category: "Conscientiousness", text: "A menudo olvido devolver las cosas a su lugar"),
    Question(code: "CSN7", category: "Conscientiousness", text: "Me gusta el orden"),
    Question(code: "CSN8", category: "Conscientiousness", text: "Evado mis responsabilidades"),
    Question(code: "CSN9", category: "Conscientiousness", text: "Sigo un horario"),
    Question(code: "CSN10", category: "Conscientiousness", text: "Soy exigente en mi trabajo"),

    // Apertura a la Experiencia
    Question(code: "OPN1", category: "Openness", text: "Tengo un vocabulario amplio"),
    Question(code: "OPN2", category: "Openness", text: "Me cuesta entender ideas abstractas"),
    Question(code: "OPN3", category: "Openness", text: "Tengo una imaginación vívida"),
    Question(code: "OPN4", category: "Openness", text: "No me interesan las ideas abstractas"),
    Question(code: "OPN5", category: "Openness", text: "Tengo ideas excelentes"),
    Question(code: "OPN6", category: "Openness", text: "No tengo buena imaginación"),
    Question(code: "OPN7", category: "Openness", text: "Entiendo las cosas rápidamente"),
    Question(code: "OPN8", category: "Openness", text: "Uso palabras difíciles"),
    Question(code: "OPN9", category: "Openness", text: "Paso tiempo reflexionando sobre las cosas"),
    Question(code: "OPN10", category: "Openness", text: "Estoy lleno de ideas"),
  ];

  Future<List<Question>> fetchQuestions() async {
    await Future.delayed(const Duration(milliseconds: 400));
    return _mockQuestions;
  }

  Future<PredictionResultModel> calculateMockPrediction(PredictionRequestDto request) async {
    await Future.delayed(const Duration(seconds: 2)); // Simula procesamiento del pkl

    // Simulación de promedios para simular el comportamiento del modelo de ML
    int sum = 0;
    request.answers.forEach((key, value) => sum += value);
    double calculatedScore = sum / request.answers.length; // Valor entre 1.0 y 5.0

    String level;
    if (calculatedScore >= 4.0) {
      level = "Muy extrovertido";
    } else if (calculatedScore >= 3.0) {
      level = "Extrovertido";
    } else if (calculatedScore >= 2.0) {
      level = "Neutral";
    } else {
      level = "Introvertido";
    }

    return PredictionResultModel(
      status: "success",
      personalityPrediction: calculatedScore,
      personalityType: level,
      message: "Predicción realizada correctamente desde el pkl simulado.",
    );
  }
}