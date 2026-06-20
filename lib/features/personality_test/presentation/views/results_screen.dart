import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:math' as math;
import '../viewmodels/question_viewmodel.dart';

class ResultsScreen extends StatelessWidget {
  const ResultsScreen({super.key});

  final Color primaryColor = const Color(0xFF142175);
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
  };

  static const Map<String, String> _traitPrefix = {
    'Openness': 'OPN',
    'Conscientiousness': 'CSN',
    'Extraversion': 'EXT',
    'Agreeableness': 'AGR',
    'Neuroticism': 'EST',
  };

  static const Map<String, String> _traitDescriptions = {
    'Openness': 'Alta curiosidad y preferencia por la novedad. Posees imaginacion vivida.',
    'Conscientiousness': 'Organizado y disciplinado, manteniendo flexibilidad en tus rutinas.',
    'Extraversion': 'Naturaleza ambivertida: comodo socialmente y tambien valoras la soledad para recargar.',
    'Agreeableness': 'Compasivo y cooperativo. Valoras la armonia social sobre la competencia.',
    'Neuroticism': 'Estabilidad emocional y resiliencia. Mantienes la calma bajo presion.',
  };

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<QuestionViewModel>();
    final traitScores = _buildTraitScores(viewModel.answers);

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Evaluación completada', style: TextStyle(color: Color(0xFF5a55a2), fontWeight: FontWeight.w600, fontSize: 12)),
            const SizedBox(height: 8),
            Text('Tu Perfil de Personalidad', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: primaryColor)),
            const SizedBox(height: 8),
            const Text(
              'Basado en tus respuestas, hemos mapeado tus rasgos Big Five. Este análisis proporciona una visión clínica de tus predisposiciones psicológicas.',
              style: TextStyle(fontSize: 16, color: Color(0xFF454651)),
            ),
            const SizedBox(height: 32),

            _buildChartCard(traitScores),
            const SizedBox(height: 20),

            ...traitScores.map(_buildTraitRow),
            const SizedBox(height: 24),

            ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.download, size: 20),
              label: const Text('Descargar reporte'),
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFFcfe8dd),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Perspectiva y Crecimiento', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF091f19))),
                        const SizedBox(height: 8),
                        Text('Tu alta Apertura y Amabilidad sugieren potencial de liderazgo en entornos colaborativos.', style: TextStyle(color: const Color(0xFF354b43).withValues(alpha: 0.9))),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.5), shape: BoxShape.circle),
                    child: const Icon(Icons.trending_up, color: Color(0xFF1b3129), size: 32),
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  List<_TraitScore> _buildTraitScores(Map<String, int> answers) {
    if (answers.isEmpty) {
      return const [
        _TraitScore(
          key: 'Openness',
          label: 'Apertura',
          value: 68,
          description: 'Alta curiosidad y preferencia por la novedad. Posees imaginacion vivida.',
        ),
        _TraitScore(
          key: 'Conscientiousness',
          label: 'Responsabilidad',
          value: 61,
          description: 'Organizado y disciplinado, manteniendo flexibilidad en tus rutinas.',
        ),
        _TraitScore(
          key: 'Extraversion',
          label: 'Extraversión',
          value: 56,
          description: 'Naturaleza ambivertida: comodo socialmente y tambien valoras la soledad para recargar.',
        ),
        _TraitScore(
          key: 'Agreeableness',
          label: 'Amabilidad',
          value: 73,
          description: 'Compasivo y cooperativo. Valoras la armonia social sobre la competencia.',
        ),
        _TraitScore(
          key: 'Neuroticism',
          label: 'Neuroticismo',
          value: 39,
          description: 'Estabilidad emocional y resiliencia. Mantienes la calma bajo presion.',
        ),
      ];
    }

    final scores = <_TraitScore>[];

    for (final trait in _traitOrder) {
      final prefix = _traitPrefix[trait]!;
      final values = answers.entries
          .where((entry) => entry.key.startsWith(prefix))
          .map((entry) => entry.value.toDouble())
          .toList();

      final averageLikert = values.isEmpty ? 3.0 : values.reduce((a, b) => a + b) / values.length;
      final normalized = ((averageLikert - 1) / 4) * 100;

      scores.add(
        _TraitScore(
          key: trait,
          label: _traitLabelsEs[trait]!,
          value: normalized.clamp(0, 100),
          description: _traitDescriptions[trait]!,
        ),
      );
    }

    return scores;
  }

  Widget _buildChartCard(List<_TraitScore> scores) {
    final chartValues = _traitOrder
        .map((trait) => scores.firstWhere((element) => element.key == trait).value)
        .toList();
    final chartLabels = _traitOrder
      .map((trait) => _traitLabelsEs[trait]!)
      .toList();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          Text(
            'Distribución de rasgos',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: primaryColor,
            ),
          ),
          const SizedBox(height: 12),
          AspectRatio(
            aspectRatio: 1,
            child: CustomPaint(
              painter: _RadarChartPainter(
                values: chartValues,
                labels: chartLabels,
                axisColor: const Color(0xFFDADCE5),
                fillColor: const Color(0xFF142175).withValues(alpha: 0.18),
                strokeColor: const Color(0xFF142175),
                labelColor: const Color(0xFF6B6D7A),
              ),
            ),
          ),
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
        boxShadow: [BoxShadow(color: const Color(0xFF142175).withValues(alpha: 0.05), blurRadius: 20, offset: const Offset(0, 5))]
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(score.label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Color(0xFF142175))),
              Text('${score.value.toStringAsFixed(0)}%', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: barColor)),
            ],
          ),
          const SizedBox(height: 10),
          LinearProgressIndicator(
            value: score.value / 100,
            backgroundColor: const Color(0xFFedeeef),
            color: barColor,
            minHeight: 7,
            borderRadius: BorderRadius.circular(4),
          ),
          const SizedBox(height: 10),
          Text(
            score.description,
            style: const TextStyle(
              fontSize: 13,
              color: Color(0xFF454651),
              height: 1.35,
            ),
          ),
        ],
      ),
    );
  }
}

class _TraitScore {
  final String key;
  final String label;
  final double value;
  final String description;

  const _TraitScore({
    required this.key,
    required this.label,
    required this.value,
    required this.description,
  });
}

class _RadarChartPainter extends CustomPainter {
  final List<double> values;
  final List<String> labels;
  final Color axisColor;
  final Color fillColor;
  final Color strokeColor;
  final Color labelColor;

  _RadarChartPainter({
    required this.values,
    required this.labels,
    required this.axisColor,
    required this.fillColor,
    required this.strokeColor,
    required this.labelColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (values.length != labels.length || values.isEmpty) return;

    final center = Offset(size.width / 2, size.height / 2);
    final maxRadius = size.shortestSide * 0.35;
    const levels = 4;
    final angleStep = (2 * math.pi) / values.length;

    final gridPaint = Paint()
      ..color = axisColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    for (var level = 1; level <= levels; level++) {
      final radius = maxRadius * (level / levels);
      final path = Path();

      for (var i = 0; i < values.length; i++) {
        final angle = -math.pi / 2 + i * angleStep;
        final point = Offset(
          center.dx + radius * math.cos(angle),
          center.dy + radius * math.sin(angle),
        );

        if (i == 0) {
          path.moveTo(point.dx, point.dy);
        } else {
          path.lineTo(point.dx, point.dy);
        }
      }

      path.close();
      canvas.drawPath(path, gridPaint);
    }

    for (var i = 0; i < values.length; i++) {
      final angle = -math.pi / 2 + i * angleStep;
      final endPoint = Offset(
        center.dx + maxRadius * math.cos(angle),
        center.dy + maxRadius * math.sin(angle),
      );

      canvas.drawLine(center, endPoint, gridPaint);

      final labelPoint = Offset(
        center.dx + (maxRadius + 18) * math.cos(angle),
        center.dy + (maxRadius + 18) * math.sin(angle),
      );

      final labelPainter = TextPainter(
        text: TextSpan(
          text: labels[i],
          style: TextStyle(
            color: labelColor,
            fontSize: 11,
            fontWeight: FontWeight.w500,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();

      labelPainter.paint(
        canvas,
        Offset(
          labelPoint.dx - (labelPainter.width / 2),
          labelPoint.dy - (labelPainter.height / 2),
        ),
      );
    }

    final valuePath = Path();

    for (var i = 0; i < values.length; i++) {
      final normalized = (values[i] / 100).clamp(0.0, 1.0);
      final radius = maxRadius * normalized;
      final angle = -math.pi / 2 + i * angleStep;
      final point = Offset(
        center.dx + radius * math.cos(angle),
        center.dy + radius * math.sin(angle),
      );

      if (i == 0) {
        valuePath.moveTo(point.dx, point.dy);
      } else {
        valuePath.lineTo(point.dx, point.dy);
      }
    }

    valuePath.close();

    final fillPaint = Paint()
      ..color = fillColor
      ..style = PaintingStyle.fill;

    final strokePaint = Paint()
      ..color = strokeColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    canvas.drawPath(valuePath, fillPaint);
    canvas.drawPath(valuePath, strokePaint);
  }

  @override
  bool shouldRepaint(covariant _RadarChartPainter oldDelegate) {
    if (oldDelegate.values.length != values.length) return true;
    for (var i = 0; i < values.length; i++) {
      if (oldDelegate.values[i] != values[i]) return true;
      if (oldDelegate.labels[i] != labels[i]) return true;
    }
    return oldDelegate.axisColor != axisColor ||
        oldDelegate.fillColor != fillColor ||
        oldDelegate.strokeColor != strokeColor ||
        oldDelegate.labelColor != labelColor;
  }
}
