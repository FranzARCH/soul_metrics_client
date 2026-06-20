class PersonalityProfile {
  final bool hasPersonalityProfile;
  final int? id;
  final int? userId;
  final String? lastUpdated;
  final ProfileMetadata? metadata;
  final AiConclusions? aiConclusions;
  final Map<String, TraitConclusion> traitsConclusions;
  final ComparisonRadarData? radarData;

  const PersonalityProfile({
    required this.hasPersonalityProfile,
    this.id,
    this.userId,
    this.lastUpdated,
    this.metadata,
    this.aiConclusions,
    required this.traitsConclusions,
    this.radarData,
  });
}

class ProfileMetadata {
  final int totalTestsTaken;
  final String firstTestDate;
  final int daysActive;
  final String primaryDominantTrait;
  final String highestVarianceTrait;

  const ProfileMetadata({
    required this.totalTestsTaken,
    required this.firstTestDate,
    required this.daysActive,
    required this.primaryDominantTrait,
    required this.highestVarianceTrait,
  });
}

class AiConclusions {
  final String summary;
  final String trendsAnalysis;
  final String recommendation;

  const AiConclusions({
    required this.summary,
    required this.trendsAnalysis,
    required this.recommendation,
  });
}

class TraitConclusion {
  final double overallPercentage;
  final String level;
  final String conclusion;

  const TraitConclusion({
    required this.overallPercentage,
    required this.level,
    required this.conclusion,
  });
}

class ComparisonRadarData {
  final String title;
  final List<String> labels;
  final List<double> initialData;
  final List<double> currentData;

  const ComparisonRadarData({
    required this.title,
    required this.labels,
    required this.initialData,
    required this.currentData,
  });
}