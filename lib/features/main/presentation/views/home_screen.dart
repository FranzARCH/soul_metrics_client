import 'package:flutter/material.dart';
// Asegúrate de importar la pantalla del cuestionario correctamente según tu estructura de carpetas
import '../../../personality_test/presentation/views/question_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  final Color primaryColor = const Color(0xFF142175);
  final Color secondaryColor = const Color(0xFF5a55a2);

  @override
  Widget build(BuildContext context) {
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
                // Welcome Section
                Text('Hola, Sofía', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: primaryColor)),
                const SizedBox(height: 8),
                const Text(
                  'Hoy es un buen día para profundizar en tu autoconocimiento. Tu última sesión mostró un crecimiento notable en resiliencia.',
                  style: TextStyle(fontSize: 16, color: Color(0xFF454651)),
                ),
                const SizedBox(height: 32),

                // CTA Card
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2e3a8c),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(color: primaryColor.withOpacity(0.1), blurRadius: 20, offset: const Offset(0, 10))
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
                        style: TextStyle(fontSize: 14, color: Colors.white.withOpacity(0.9))),
                      const SizedBox(height: 24),
                      
                      // BOTÓN ACTUALIZADO CON LA REDIRECCIÓN
                      ElevatedButton.icon(
                        onPressed: () {
                          // Navega a la pantalla del cuestionario
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const QuestionScreen()),
                          );
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

                // Last Assessment Summary
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
                          const Text('12 Oct', style: TextStyle(color: Colors.grey)),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _buildProgressRow('Conciencia', 85, primaryColor),
                      const SizedBox(height: 12),
                      _buildProgressRow('Extraversión', 62, secondaryColor),
                      const SizedBox(height: 16),
                      const Divider(),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(Icons.trending_up, color: const Color(0xFF1b3129), size: 18),
                          const SizedBox(width: 8),
                          const Text('+12% de mejora en Foco Mental', style: TextStyle(fontWeight: FontWeight.w500, color: Color(0xFF1b3129))),
                        ],
                      )
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // Insights del Día
                Text('Insights del Día', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: primaryColor)),
                const SizedBox(height: 16),
                
                Wrap(
                  spacing: 16,
                  runSpacing: 16,
                  children: [
                    SizedBox(
                      width: 350,
                      child: _buildInsightCard(Icons.lightbulb_outline, 'Pausa Cognitiva', 'Tomar descansos de 5 minutos cada 90 minutos de trabajo mejora tu retención.', const Color(0xFFcfe8dd), const Color(0xFF091f19)),
                    ),
                    SizedBox(
                      width: 350,
                      child: _buildInsightCard(Icons.self_improvement, 'Foco Consciente', 'Hoy tu perfil sugiere que podrías beneficiarte de ejercicios de respiración 4-7-8.', const Color(0xFFe3dfff), const Color(0xFF15095c)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProgressRow(String label, double percent, Color color) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
            Text('${percent.toInt()}%', style: TextStyle(fontWeight: FontWeight.bold, color: color)),
          ],
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: percent / 100,
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
}