import 'package:flutter/material.dart';

class ResultsScreen extends StatelessWidget {
  const ResultsScreen({super.key});

  final Color primaryColor = const Color(0xFF142175);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Evaluación completada: 24 Oct, 2023', style: TextStyle(color: Color(0xFF5a55a2), fontWeight: FontWeight.w600, fontSize: 12)),
            const SizedBox(height: 8),
            Text('Tu Perfil de Personalidad', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: primaryColor)),
            const SizedBox(height: 8),
            const Text(
              'Basado en tus respuestas, hemos mapeado tus rasgos Big Five. Este análisis proporciona una visión clínica de tus predisposiciones psicológicas.',
              style: TextStyle(fontSize: 16, color: Color(0xFF454651)),
            ),
            const SizedBox(height: 32),

            ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.download, size: 20),
              label: const Text('Descargar Reporte Detallado'),
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 24),

            _buildTraitCard('Apertura', 84, primaryColor, 'Alta curiosidad y preferencia por la novedad. Posees imaginación vívida.'),
            _buildTraitCard('Responsabilidad', 62, primaryColor, 'Organizado y disciplinado, manteniendo flexibilidad en tus rutinas.'),
            _buildTraitCard('Extraversión', 45, primaryColor, 'Naturaleza ambivertida—cómodo socialmente pero valoras la soledad para recargar.'),
            _buildTraitCard('Amabilidad', 71, primaryColor, 'Compasivo y cooperativo. Valoras la armonía social sobre la competencia.'),
            _buildTraitCard('Neuroticismo', 28, const Color(0xFF767682), 'Estabilidad emocional y resiliencia. Mantienes la calma bajo presión.'),
            
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
                        Text('Tu alta Apertura y Amabilidad sugieren potencial de liderazgo en entornos colaborativos.', style: TextStyle(color: const Color(0xFF354b43).withOpacity(0.9))),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(color: Colors.white.withOpacity(0.5), shape: BoxShape.circle),
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

  Widget _buildTraitCard(String title, double score, Color color, String desc) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: const Color(0xFF142175).withOpacity(0.05), blurRadius: 20, offset: const Offset(0, 5))]
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF142175))),
              Text('${score.toInt()}%', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color)),
            ],
          ),
          const SizedBox(height: 12),
          LinearProgressIndicator(value: score / 100, backgroundColor: const Color(0xFFedeeef), color: color, minHeight: 8, borderRadius: BorderRadius.circular(4)),
          const SizedBox(height: 12),
          Text(desc, style: const TextStyle(fontSize: 14, color: Color(0xFF454651))),
        ],
      ),
    );
  }
}