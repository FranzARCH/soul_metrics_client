import '../../domain/entities/personality_profile.dart';

class PersonalityProfileModel extends PersonalityProfile {
  PersonalityProfileModel({
    required super.hasPersonalityProfile,
    super.id,
    super.userId,
    super.lastUpdated,
    super.metadata,
    super.aiConclusions,
    required super.traitsConclusions,
    super.radarData,
  });

  factory PersonalityProfileModel.fromJson(Map<String, dynamic> json) {
    final bool hasProfile = json['has_personality_profile'] ?? false;
    if (!hasProfile) {
      return PersonalityProfileModel(hasPersonalityProfile: false, traitsConclusions: {});
    }

    // 🚀 CORRECCIÓN DE TIPO: Convierte de forma segura strings/objetos a double porcentual
    final Map<String, TraitConclusion> mappedTraits = {};
    final traitsJson = json['traits_conclusions'] as Map<String, dynamic>? ?? {};
    
    traitsJson.forEach((key, value) {
      if (value is Map<String, dynamic>) {
        mappedTraits[key] = TraitConclusion(
          // Si viene como string "0.87" lo parsea, si viene de otra forma lo previene
          overallPercentage: double.tryParse(value['overall_percentage']?.toString() ?? '0.0') ?? 0.0,
          level: value['level'] ?? 'medium',
          conclusion: value['conclusion'] ?? '',
        );
      }
    });

    // Parseo seguro del Radar Chart para evitar colisiones con sub-objetos de gráficos
    ComparisonRadarData? radar;
    final graphics = json['graphics_data'] as Map<String, dynamic>?;
    if (graphics != null && graphics['comparison_radar_chart'] != null) {
      final radarJson = graphics['comparison_radar_chart'] as Map<String, dynamic>;
      final datasets = radarJson['datasets'] as List<dynamic>? ?? [];
      
      List<double> initial = [];
      List<double> current = [];

      if (datasets.length >= 2) {
        // Convierte dinámicamente cada elemento numérico evitando subtipos inválidos
        initial = (datasets[0]['data'] as List<dynamic>? ?? [])
            .map((e) => double.tryParse(e.toString()) ?? 0.0)
            .toList();
        current = (datasets[1]['data'] as List<dynamic>? ?? [])
            .map((e) => double.tryParse(e.toString()) ?? 0.0)
            .toList();
      }

      radar = ComparisonRadarData(
        title: radarJson['title'] ?? 'Baseline Shift',
        labels: List<String>.from(radarJson['labels'] ?? []),
        initialData: initial,
        currentData: current,
      );
    }

    final metaJson = json['report_metadata'] as Map<String, dynamic>? ?? {};
    final aiJson = json['ai_conclusions'] as Map<String, dynamic>? ?? {};

    return PersonalityProfileModel(
      hasPersonalityProfile: true,
      id: json['id'],
      userId: json['user_id'],
      lastUpdated: json['last_updated'],
      metadata: ProfileMetadata(
        totalTestsTaken: metaJson['total_tests_taken'] ?? 0,
        firstTestDate: metaJson['first_test_date'] ?? '',
        daysActive: metaJson['days_active'] ?? 0,
        primaryDominantTrait: metaJson['primary_dominant_trait'] ?? '',
        highestVarianceTrait: metaJson['highest_variance_trait'] ?? '',
      ),
      aiConclusions: AiConclusions(
        summary: aiJson['summary'] ?? '',
        trendsAnalysis: aiJson['trends_analysis'] ?? '',
        recommendation: aiJson['recommendation'] ?? '',
      ),
      traitsConclusions: mappedTraits,
      radarData: radar,
    );
  }
}