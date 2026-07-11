import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../auth/presentation/viewmodels/auth_viewmodel.dart';
import '../../../history_results/domain/entities/history_item.dart';
import '../../../history_results/presentation/viewmodels/history_viewmodel.dart';
import '../../../personality_test/presentation/viewmodels/profile_viewmodel.dart';
import 'package:go_router/go_router.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final Color primaryColor = const Color(0xFF142175);
  final Color secondaryColor = const Color(0xFF5a55a2);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authVm = context.read<AuthViewModel>();
      final historyVm = context.read<HistoryViewModel>();
      final profileVm = context.read<ProfileViewModel>();

      if (authVm.currentUser == null && !authVm.isLoading) {
        authVm.loadProfile();
      }
      if (historyVm.historyRecords.isEmpty && !historyVm.isLoading) {
        historyVm.fetchHistory();
      }
      if (profileVm.profile == null && !profileVm.isLoading) {
        profileVm.loadProfileData();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final authVm = context.watch<AuthViewModel>();
    final historyVm = context.watch<HistoryViewModel>();
    final profileVm = context.watch<ProfileViewModel>();

    final userName = authVm.currentUser?.username ?? 'Usuario';
    final latestRecord = _getLatestRecord(historyVm.historyRecords);
    final topTraits = _extractTopTraits(latestRecord?.predictedScores);
    final aiSummary = profileVm.profile?.aiConclusions?.summary;
    final aiRecommendation = profileVm.profile?.aiConclusions?.recommendation;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 800),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Hola, $userName', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: primaryColor)),
                const SizedBox(height: 8),
                Text(
                  latestRecord == null
                      ? 'Hoy es un buen día para iniciar tu evaluación de personalidad con IA.'
                      : 'Tu última evaluación quedó registrada. Revisa tus rasgos dominantes y compáralos con tu evolución.',
                  style: const TextStyle(fontSize: 16, color: Color(0xFF454651)),
                ),
                const SizedBox(height: 32),

                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2e3a8c),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(color: primaryColor.withValues(alpha: 0.1), blurRadius: 20, offset: const Offset(0, 10))
                    ]
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(color: const Color(0xFF9ea9ff), borderRadius: BorderRadius.circular(20)),
                        child: Text('RECOMENDADO', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: primaryColor)),
                      ),
                      const SizedBox(height: 16),
                      const Text('Evalúa tu estado emocional actual', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
                      const SizedBox(height: 8),
                      Text('Nuestro test de 5 minutos te ayudará a identificar patrones de pensamiento y áreas de oportunidad para esta semana.', 
                        style: TextStyle(fontSize: 14, color: Colors.white.withValues(alpha: 0.9))),
                      const SizedBox(height: 24),

                      ElevatedButton.icon(
                        onPressed: () {
                          context.go('/test');
                        },
                        icon: const Icon(Icons.arrow_forward, size: 18),
                        label: const Text('Iniciar Evaluación'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFdfe0ff),
                          foregroundColor: const Color(0xFF000d60),
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      )
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFedeeef)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Último Reporte', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: primaryColor)),
                          Text(
                            latestRecord != null ? _formatDate(latestRecord.createdAt) : 'Sin datos',
                            style: const TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      if (historyVm.isLoading)
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 24),
                          child: Center(child: CircularProgressIndicator()),
                        )
                      else if (latestRecord == null)
                        const Text('Aún no tienes evaluaciones guardadas.', style: TextStyle(color: Color(0xFF454651)))
                      else ...[
                        _buildProgressRow(topTraits[0].label, topTraits[0].score, primaryColor),
                        const SizedBox(height: 12),
                        _buildProgressRow(topTraits[1].label, topTraits[1].score, secondaryColor),
                        const SizedBox(height: 16),
                        const Divider(),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(Icons.trending_up, color: const Color(0xFF1b3129), size: 18),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                latestRecord.traitDescriptions[topTraits[0].key] ?? 'Evaluación completada con éxito.',
                                style: const TextStyle(fontWeight: FontWeight.w500, color: Color(0xFF1b3129)),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                Text('Insights del Día', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: primaryColor)),
                const SizedBox(height: 16),

                // Una columna en móvil, dos columnas solo si la pantalla es muy grande
                LayoutBuilder(
                  builder: (context, constraints) {
                    if (constraints.maxWidth > 600) {
                      // Dos columnas en pantallas grandes
                      return IntrinsicHeight(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Expanded(
                              child: _buildInsightCard(
                                Icons.lightbulb_outline,
                                'Resumen IA',
                                aiSummary ?? 'Completa tu primera evaluación para recibir insights personalizados de IA.',
                                const Color(0xFFcfe8dd),
                                const Color(0xFF091f19),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: _buildInsightCard(
                                Icons.self_improvement,
                                'Recomendación',
                                aiRecommendation ?? 'Activa tu perfil cognitivo respondiendo el test para obtener recomendaciones accionables.',
                                const Color(0xFFe3dfff),
                                const Color(0xFF15095c),
                              ),
                            ),
                          ],
                        ),
                      );
                    } else {
                      // Una columna en móvil
                      return Column(
                        children: [
                          _buildInsightCard(
                            Icons.lightbulb_outline,
                            'Resumen IA',
                            aiSummary ?? 'Completa tu primera evaluación para recibir insights personalizados de IA.',
                            const Color(0xFFcfe8dd),
                            const Color(0xFF091f19),
                          ),
                          const SizedBox(height: 16),
                          _buildInsightCard(
                            Icons.self_improvement,
                            'Recomendación',
                            aiRecommendation ?? 'Activa tu perfil cognitivo respondiendo el test para obtener recomendaciones accionables.',
                            const Color(0xFFe3dfff),
                            const Color(0xFF15095c),
                          ),
                        ],
                      );
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProgressRow(String label, double percent, Color color) {
    final normalizedPercent = percent.clamp(0.0, 100.0);
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
            Text('${normalizedPercent.toInt()}%', style: TextStyle(fontWeight: FontWeight.bold, color: color)),
          ],
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: normalizedPercent / 100,
          backgroundColor: const Color(0xFFedeeef),
          color: color,
          borderRadius: BorderRadius.circular(4),
          minHeight: 8,
        ),
      ],
    );
  }

  Widget _buildInsightCard(IconData icon, String title, String desc, Color bgColor, Color iconColor) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFf3f4f5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFe1e3e4)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(8)),
            child: Icon(icon, color: iconColor),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(desc, style: const TextStyle(color: Color(0xFF454651), fontSize: 14, height: 1.5)),
              ],
            ),
          )
        ],
      ),
    );
  }

  _TraitProgress _safeTrait(MapEntry<String, double>? entry) {
    if (entry == null) {
      return const _TraitProgress(key: 'Unknown', label: 'Sin datos', score: 0.0);
    }

    final raw = entry.value;
    final score = _normalizeToPercent(raw);

    return _TraitProgress(
      key: entry.key,
      label: _localiseTrait(entry.key),
      score: score,
    );
  }

  List<_TraitProgress> _extractTopTraits(Map<String, double>? scores) {
    if (scores == null || scores.isEmpty) {
      return const [
        _TraitProgress(key: 'Unknown', label: 'Sin datos', score: 0),
        _TraitProgress(key: 'Unknown', label: 'Sin datos', score: 0),
      ];
    }

    final entries = scores.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
    final first = _safeTrait(entries.first);
    final second = _safeTrait(entries.length > 1 ? entries[1] : entries.first);
    return [first, second];
  }

  HistoryItem? _getLatestRecord(List<HistoryItem> records) {
    if (records.isEmpty) return null;
    final sorted = [...records]..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return sorted.first;
  }

  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    return '$day/$month/${date.year}';
  }

  String _localiseTrait(String traitKey) {
    switch (traitKey) {
      case 'EST':
      case 'EmotionalStability':
        return 'Estabilidad emocional';
      case 'OPN':
      case 'Openness':
        return 'Apertura';
      case 'CSN':
      case 'CON':
      case 'Conscientiousness':
        return 'Responsabilidad';
      case 'EXT':
      case 'Extraversion':
        return 'Extraversión';
      case 'AGR':
      case 'Agreeableness':
        return 'Amabilidad';
      case 'NEU':
      case 'Neuroticism':
        return 'Neuroticismo';
      default:
        return traitKey;
    }
  }

  double _normalizeToPercent(double raw) {
    if (raw <= 1.0) return (raw * 100).clamp(0.0, 100.0);
    if (raw <= 5.0) return ((raw - 1.0) / 4.0 * 100).clamp(0.0, 100.0);
    if (raw <= 10.0) return (raw * 10).clamp(0.0, 100.0);
    return raw.clamp(0.0, 100.0);
  }
}

class _TraitProgress {
  final String key;
  final String label;
  final double score;

  const _TraitProgress({
    required this.key,
    required this.label,
    required this.score,
  });
}