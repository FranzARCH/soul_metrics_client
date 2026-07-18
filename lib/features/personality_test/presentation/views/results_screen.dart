import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:math' as math;
import 'dart:typed_data';
import '../viewmodels/profile_viewmodel.dart';
import '../viewmodels/question_viewmodel.dart';
import '../../domain/entities/prediction_result.dart';
import '../../domain/entities/personality_profile.dart';
import '../../../../injection_container.dart';
import 'package:file_saver/file_saver.dart';

class ResultsScreen extends StatelessWidget {
  const ResultsScreen({super.key});

  final Color primaryColor = const Color(0xFF142175);
  final Color secondaryColor = const Color(0xFF5a55a2);
  
  static const List<String> _traitOrder = [
    'Openness',
    'Conscientiousness',
    'Extraversion',
    'Agreeableness',
    'Neuroticism',
  ];

  static const Map<String, String> _traitLabelsEs = {
    'Openness': 'Apertura',
    'Conscientiousness': 'Responsabilidad',
    'Extraversion': 'Extraversión',
    'Agreeableness': 'Amabilidad',
    'Neuroticism': 'Neuroticismo',
    'OPN': 'Apertura',
    'CSN': 'Responsabilidad',
    'CON': 'Responsabilidad',
    'EXT': 'Extraversión',
    'AGR': 'Amabilidad',
    'EST': 'Estabilidad emocional',
  };

  static const Map<String, List<String>> _traitAliases = {
    'Openness': ['openness', 'open', 'ope', 'opn', 'opc', 'o', 'apertura'],
    'Conscientiousness': ['conscientiousness', 'con', 'cons', 'csn', 'c', 'responsabilidad'],
    'Extraversion': ['extraversion', 'extroversion', 'ext', 'e', 'extraversion'],
    'Agreeableness': ['agreeableness', 'agr', 'agree', 'a', 'amabilidad'],
    'Neuroticism': ['neuroticism', 'neu', 'neuro', 'n', 'neuroticismo'],
  };

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<ProfileViewModel>(
      create: (_) => locator<ProfileViewModel>()..loadProfileData(),
      child: Consumer<ProfileViewModel>(
        builder: (context, viewModel, child) {
          final latestAssessment = context.watch<QuestionViewModel>().result;
          final currentProfile = viewModel.profile;
          final bool hasRealData = currentProfile?.hasPersonalityProfile == true;
          final bool hasAssessmentResult = latestAssessment != null;

          if (viewModel.isLoading && !hasAssessmentResult) {
            return const Scaffold(
              backgroundColor: Color(0xFFF8F9FA),
              body: Center(child: CircularProgressIndicator()),
            );
          }

          if (viewModel.error != null && !hasAssessmentResult) {
            return Scaffold(
              backgroundColor: const Color(0xFFF8F9FA),
              body: Center(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Text(
                    'Error: ${viewModel.error}', 
                    style: const TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            );
          }

          final PersonalityProfile profileData = hasRealData
              ? currentProfile as PersonalityProfile
              : _getEmptyFallbackProfile();

          final List<_TraitScore> traitScores = hasRealData
              ? _buildProfileTraitScores(profileData)
              : _buildAssessmentTraitScores(latestAssessment);

          return Scaffold(
            backgroundColor: const Color(0xFFF8F9FA),
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              title: Text(
                hasRealData || hasAssessmentResult ? 'Evaluación Completada' : 'Ejemplo de Visualización',
                style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold, fontSize: 18),
              ),
              actions: [
                if (hasRealData || hasAssessmentResult)
                  Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: viewModel.isExporting
                        ? const Padding(
                            padding: EdgeInsets.all(12.0),
                            child: SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          )
                        : IconButton(
                            icon: const Icon(Icons.picture_as_pdf, color: Color(0xFF142175)),
                            tooltip: 'Exportar PDF',
                            onPressed: () => _exportPdf(context, viewModel),
                          ),
                  ),
              ],
            ),
            body: SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      hasRealData || hasAssessmentResult ? 'Tu Perfil de Personalidad' : 'Visualización de Reporte', 
                      style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: primaryColor),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      hasRealData || hasAssessmentResult
                          ? 'Basado en tus respuestas, hemos mapeado tus rasgos Big Five. Este análisis proporciona una visión de tus predisposiciones psicológicas.'
                          : 'Demostración de resultados después de que tomes el quiz. Esta es una vista formal de cómo se renderizarán tus rasgos una vez completes el test oficial.',
                      style: const TextStyle(fontSize: 16, color: Color(0xFF454651), height: 1.4),
                    ),
                    const SizedBox(height: 32),

                    if (hasRealData) ...[
                      _buildMetadataRow(profileData.metadata),
                      const SizedBox(height: 24),
                    ],

                    _buildChartCard(
                      radarData: profileData.radarData,
                      latestAssessment: latestAssessment,
                    ),
                    const SizedBox(height: 24),

                    // Mostrar descripción del backend si está disponible del assessment
                    if (hasAssessmentResult && latestAssessment?.traitDescription != null) ...[
                      _buildTraitDescriptionCard(latestAssessment!.traitDescription!),
                      const SizedBox(height: 24),
                    ] else if (hasRealData && profileData.aiConclusions != null) ...[
                      _buildAiConclusionsCard(profileData.aiConclusions!),
                      const SizedBox(height: 24),
                    ],

                    Text(
                      'Desglose Detallado por Rasgo',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: primaryColor),
                    ),
                    const SizedBox(height: 16),

                    ...traitScores.map(_buildTraitRow),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void _exportPdf(BuildContext context, ProfileViewModel viewModel) async {
    final pdfBytes = await viewModel.exportPdf();
    
    if (!context.mounted) return;
    
    if (pdfBytes != null && pdfBytes.isNotEmpty) {
      try {
        // 1. Guardamos el archivo usando file_saver
        final String fileName = "reporte_personalidad_${DateTime.now().millisecondsSinceEpoch}";
        
        await FileSaver.instance.saveFile(
          name: fileName,
          bytes: pdfBytes,
          mimeType: MimeType.pdf,
        );

        // 2. Mostramos el mensaje de éxito
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('¡PDF descargado con éxito! (${(pdfBytes.length / 1024).toStringAsFixed(1)} KB)'),
            backgroundColor: Colors.green,
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al guardar el archivo: $e'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } else if (viewModel.error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al generar PDF: ${viewModel.error}'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  Widget _buildTraitDescriptionCard(TraitDescription traitDesc) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFEEF2F6),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFD0D7DE)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.auto_awesome, color: secondaryColor, size: 20),
              const SizedBox(width: 8),
              Text('Insights Analíticos de IA', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: primaryColor)),
            ],
          ),
          const SizedBox(height: 12),
          Text(traitDesc.title, style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1E293B), fontSize: 14)),
          const SizedBox(height: 8),
          Text(traitDesc.description, style: const TextStyle(color: Color(0xFF475569), fontSize: 13, height: 1.3)),
        ],
      ),
    );
  }

  Widget _buildMetadataRow(ProfileMetadata? meta) {
    if (meta == null) return const SizedBox();
    return Row(
      children: [
        _buildMetaChip(Icons.assignment_turned_in, '${meta.totalTestsTaken} Tests', 'Completados'),
        const SizedBox(width: 12),
        _buildMetaChip(Icons.calendar_today, '${meta.daysActive} Días', 'Monitoreado'),
        const SizedBox(width: 12),
        _buildMetaChip(Icons.star, _traitLabelsEs[meta.primaryDominantTrait] ?? meta.primaryDominantTrait, 'Dominante'),
      ],
    );
  }

  Widget _buildMetaChip(IconData icon, String title, String subtitle) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Column(
          children: [
            Icon(icon, color: primaryColor, size: 20),
            const SizedBox(height: 6),
            Text(title, style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: primaryColor), textAlign: TextAlign.center),
            Text(subtitle, style: const TextStyle(fontSize: 10, color: Color(0xFF767682)), textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }

  Widget _buildChartCard({
    required ComparisonRadarData? radarData,
    required PredictionResult? latestAssessment,
  }) {
    final liveRadar = _buildLiveRadar(latestAssessment);
    final resolvedLabels = (radarData?.labels.isNotEmpty == true)
        ? radarData!.labels
        : liveRadar.labels;

    final labels = resolvedLabels.map((l) => _traitLabelsEs[l] ?? l).toList();

    final initialSource = (radarData?.initialData.isNotEmpty == true)
        ? radarData!.initialData
        : liveRadar.initialData;
    final currentSource = (radarData?.currentData.isNotEmpty == true)
        ? radarData!.currentData
        : liveRadar.currentData;

    final initialScores = initialSource.map(_normalizeToPercent).toList();
    final currentScores = currentSource.map(_normalizeToPercent).toList();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        children: [
          Text(
            radarData?.title ?? liveRadar.title,
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: primaryColor),
          ),
          const SizedBox(height: 12),
          AspectRatio(
            aspectRatio: 1,
            child: CustomPaint(
              painter: _DualRadarChartPainter(
                labels: labels,
                initialDataset: initialScores,
                currentDataset: currentScores,
                axisColor: const Color(0xFFDADCE5),
                labelColor: const Color(0xFF6B6D7A),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAiConclusionsCard(AiConclusions ai) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFEEF2F6),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFD0D7DE)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.auto_awesome, color: secondaryColor, size: 20),
              const SizedBox(width: 8),
              Text('Insights Analíticos de IA', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: primaryColor)),
            ],
          ),
          const SizedBox(height: 12),
          Text(ai.summary, style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1E293B), fontSize: 14)),
          const SizedBox(height: 8),
          Text(ai.trendsAnalysis, style: const TextStyle(color: Color(0xFF475569), fontSize: 13, height: 1.3)),
          const SizedBox(height: 12),
          const Divider(color: Color(0xFFCBD5E1)),
          const SizedBox(height: 4),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.lightbulb_outline, color: Colors.orange, size: 18),
              const SizedBox(width: 6),
              Expanded(
                child: Text('Sugerencia: ${ai.recommendation}', style: const TextStyle(color: Color(0xFF0F172A), fontStyle: FontStyle.italic, fontSize: 13)),
              )
            ],
          )
        ],
      ),
    );
  }

  Widget _buildTraitRow(_TraitScore score) {
    final barColor = score.key == 'Neuroticism' ? const Color(0xFF767682) : primaryColor;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [BoxShadow(color: const Color(0xFF142175).withValues(alpha: 0.03), blurRadius: 20, offset: const Offset(0, 5))]
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(score.label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Color(0xFF142175))),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(color: barColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(6)),
                child: Text(score.level, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: barColor)),
              )
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: LinearProgressIndicator(
                  value: score.value / 100,
                  backgroundColor: const Color(0xFFedeeef),
                  color: barColor,
                  minHeight: 8,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(width: 12),
              Text('${score.value.toStringAsFixed(0)}%', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: barColor)),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            score.description,
            style: const TextStyle(fontSize: 13, color: Color(0xFF454651), height: 1.4),
          ),
        ],
      ),
    );
  }

  PersonalityProfile _getEmptyFallbackProfile() {
    return const PersonalityProfile(
      hasPersonalityProfile: false,
      traitsConclusions: {
        'Openness': TraitConclusion(overallPercentage: 0.0, level: 'MEDIO', conclusion: 'Completa tu primer test para desbloquear las conclusiones de la IA.'),
        'Conscientiousness': TraitConclusion(overallPercentage: 0.0, level: 'MEDIO', conclusion: 'Completa tu primer test para desbloquear las conclusiones de la IA.'),
        'Extraversion': TraitConclusion(overallPercentage: 0.0, level: 'MEDIO', conclusion: 'Completa tu primer test para desbloquear las conclusiones de la IA.'),
        'Agreeableness': TraitConclusion(overallPercentage: 0.0, level: 'MEDIO', conclusion: 'Completa tu primer test para desbloquear las conclusiones de la IA.'),
        'Neuroticism': TraitConclusion(overallPercentage: 0.0, level: 'MEDIO', conclusion: 'Completa tu primer test para desbloquear las conclusiones de la IA.'),
      }
    );
  }

  List<_TraitScore> _buildProfileTraitScores(PersonalityProfile profileData) {
    return _traitOrder.map((trait) {
      final traitConclusion = profileData.traitsConclusions[trait];
      final double percentage = (traitConclusion != null) ? (traitConclusion.overallPercentage * 100) : 0.0;
      final String desc = traitConclusion?.conclusion ?? 'Sin análisis disponible para este rasgo.';
      final String lvl = traitConclusion?.level.toUpperCase() ?? 'MEDIO';

      return _TraitScore(
        key: trait,
        label: _traitLabelsEs[trait] ?? trait,
        value: percentage.clamp(0.0, 100.0),
        description: desc,
        level: lvl,
      );
    }).toList();
  }

  List<_TraitScore> _buildAssessmentTraitScores(PredictionResult? assessment) {
    if (assessment == null) {
      return _buildProfileTraitScores(_getEmptyFallbackProfile());
    }

    return _traitOrder.map((trait) {
      final raw = _resolveTraitValue(assessment.personalityPrediction, trait);
      final value = _normalizeToPercent(raw);
      final desc = _resolveTraitDescription(assessment.traitDescriptions, trait) ?? 'Evaluación recién procesada.';
      final level = _levelFromPercent(value);

      return _TraitScore(
        key: trait,
        label: _traitLabelsEs[trait] ?? trait,
        value: value,
        description: desc,
        level: level,
      );
    }).toList();
  }

  _LiveRadarData _buildLiveRadar(PredictionResult? assessment) {
    if (assessment == null) {
      return const _LiveRadarData(
        title: 'Distribución de rasgos',
        labels: _traitOrder,
        initialData: [50, 50, 50, 50, 50],
        currentData: [50, 50, 50, 50, 50],
      );
    }

    final graphics = assessment.graphicsData;
    final radar = graphics['comparison_radar_chart'];
    if (radar is Map<String, dynamic>) {
      final labels = List<String>.from(radar['labels'] ?? _traitOrder);
      final datasets = radar['datasets'] as List<dynamic>? ?? [];
      List<double> initial = [];
      List<double> current = [];

      if (datasets.isNotEmpty) {
        initial = List<double>.from(
          ((datasets.first as Map<String, dynamic>)['data'] as List<dynamic>? ?? [])
              .map((e) => double.tryParse(e.toString()) ?? 0.0),
        );
      }
      if (datasets.length > 1) {
        current = List<double>.from(
          ((datasets[1] as Map<String, dynamic>)['data'] as List<dynamic>? ?? [])
              .map((e) => double.tryParse(e.toString()) ?? 0.0),
        );
      }

      if (current.isNotEmpty) {
        return _LiveRadarData(
          title: (radar['title'] ?? 'Distribución de rasgos').toString(),
          labels: labels,
          initialData: initial.isNotEmpty ? initial : List.filled(current.length, 50),
          currentData: current,
        );
      }
    }

    final currentData = _traitOrder
      .map((trait) => _normalizeToPercent(_resolveTraitValue(assessment.personalityPrediction, trait)))
        .toList();

    return _LiveRadarData(
      title: 'Distribución de rasgos',
      labels: _traitOrder,
      initialData: List.filled(currentData.length, 50),
      currentData: currentData,
    );
  }

  double _normalizeToPercent(double raw) {
    if (raw <= 1.0) return (raw * 100).clamp(0.0, 100.0);
    if (raw <= 5.0) return ((raw - 1.0) / 4.0 * 100).clamp(0.0, 100.0);
    if (raw <= 10.0) return (raw * 10).clamp(0.0, 100.0);
    return raw.clamp(0.0, 100.0);
  }

  double _resolveTraitValue(Map<String, double> values, String trait) {
    if (values.containsKey(trait)) {
      return values[trait] ?? 0.0;
    }

    final normalizedMap = <String, double>{};
    values.forEach((key, value) {
      normalizedMap[_normalizeKey(key)] = value;
    });

    final aliases = _traitAliases[trait] ?? const <String>[];
    for (final alias in aliases) {
      final match = normalizedMap[_normalizeKey(alias)];
      if (match != null) return match;
    }

    final traitNorm = _normalizeKey(trait);
    for (final entry in normalizedMap.entries) {
      if (entry.key.contains(traitNorm) || traitNorm.contains(entry.key)) {
        return entry.value;
      }
    }

    return 0.0;
  }

  String? _resolveTraitDescription(Map<String, String> descriptions, String trait) {
    if (descriptions.containsKey(trait)) {
      return descriptions[trait];
    }

    final normalizedMap = <String, String>{};
    descriptions.forEach((key, value) {
      normalizedMap[_normalizeKey(key)] = value;
    });

    final aliases = _traitAliases[trait] ?? const <String>[];
    for (final alias in aliases) {
      final match = normalizedMap[_normalizeKey(alias)];
      if (match != null && match.trim().isNotEmpty) return match;
    }

    return null;
  }

  String _normalizeKey(String input) {
    return input.toLowerCase().replaceAll(RegExp(r'[^a-z]'), '');
  }

  String _levelFromPercent(double value) {
    if (value >= 67) return 'ALTO';
    if (value >= 34) return 'MEDIO';
    return 'BAJO';
  }
}

class _TraitScore {
  final String key;
  final String label;
  final double value;
  final String description;
  final String level;

  const _TraitScore({required this.key, required this.label, required this.value, required this.description, required this.level});
}

class _DualRadarChartPainter extends CustomPainter {
  final List<String> labels;
  final List<double> initialDataset;
  final List<double> currentDataset;
  final Color axisColor;
  final Color labelColor;

  _DualRadarChartPainter({required this.labels, required this.initialDataset, required this.currentDataset, required this.axisColor, required this.labelColor});

  @override
  void paint(Canvas canvas, Size size) {
    if (labels.isEmpty) return;

    final center = Offset(size.width / 2, size.height / 2);
    final maxRadius = size.shortestSide * 0.35;
    const levels = 4;
    final angleStep = (2 * math.pi) / labels.length;

    final gridPaint = Paint()..color = axisColor..style = PaintingStyle.stroke..strokeWidth = 1;

    for (var level = 1; level <= levels; level++) {
      final radius = maxRadius * (level / levels);
      final path = Path();
      for (var i = 0; i < labels.length; i++) {
        final angle = -math.pi / 2 + i * angleStep;
        final point = Offset(center.dx + radius * math.cos(angle), center.dy + radius * math.sin(angle));
        if (i == 0) {
          path.moveTo(point.dx, point.dy);
        } else {
          path.lineTo(point.dx, point.dy);
        }
      }
      path.close();
      canvas.drawPath(path, gridPaint);
    }

    for (var i = 0; i < labels.length; i++) {
      final angle = -math.pi / 2 + i * angleStep;
      canvas.drawLine(center, Offset(center.dx + maxRadius * math.cos(angle), center.dy + maxRadius * math.sin(angle)), gridPaint);

      final labelPainter = TextPainter(
        text: TextSpan(text: labels[i], style: TextStyle(color: labelColor, fontSize: 11, fontWeight: FontWeight.w500)),
        textDirection: TextDirection.ltr,
      )..layout();

      final labelRadius = maxRadius + 18;
      labelPainter.paint(canvas, Offset(
        center.dx + labelRadius * math.cos(angle) - (labelPainter.width / 2),
        center.dy + labelRadius * math.sin(angle) - (labelPainter.height / 2),
      ));
    }

    _drawPolygon(canvas, center, maxRadius, angleStep, initialDataset, const Color(0xFF94A3B8).withValues(alpha: 0.15), const Color(0xFF94A3B8));
    _drawPolygon(canvas, center, maxRadius, angleStep, currentDataset, const Color(0xFF142175).withValues(alpha: 0.18), const Color(0xFF142175));
  }

  void _drawPolygon(Canvas canvas, Offset center, double maxRadius, double angleStep, List<double> dataset, Color fill, Color stroke) {
    final path = Path();
    for (var i = 0; i < dataset.length; i++) {
      final radius = maxRadius * ((dataset[i] / 100).clamp(0.0, 1.0));
      final angle = -math.pi / 2 + i * angleStep;
      final p = Offset(center.dx + radius * math.cos(angle), center.dy + radius * math.sin(angle));
      if (i == 0) {
        path.moveTo(p.dx, p.dy);
      } else {
        path.lineTo(p.dx, p.dy);
      }
    }
    path.close();
    canvas.drawPath(path, Paint()..color = fill..style = PaintingStyle.fill);
    canvas.drawPath(path, Paint()..color = stroke..style = PaintingStyle.stroke..strokeWidth = 2);
  }

  @override
  bool shouldRepaint(covariant _DualRadarChartPainter oldDelegate) => true;
}

class _LiveRadarData {
  final String title;
  final List<String> labels;
  final List<double> initialData;
  final List<double> currentData;

  const _LiveRadarData({
    required this.title,
    required this.labels,
    required this.initialData,
    required this.currentData,
  });
}