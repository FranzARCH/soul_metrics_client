import 'package:flutter/material.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  final Color primaryColor = const Color(0xFF142175);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Historial de Análisis', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: primaryColor)),
            const SizedBox(height: 8),
            const Text('Sigue tu evolución psicológica a través de tus evaluaciones periódicas.', style: TextStyle(color: Color(0xFF767682))),
            const SizedBox(height: 24),

            Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Buscar evaluaciones...',
                      prefixIcon: const Icon(Icons.search, color: Color(0xFF767682)),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
                  child: const Icon(Icons.filter_list, color: Color(0xFF142175)),
                )
              ],
            ),
            const SizedBox(height: 32),

            _buildHistoryCard(
              date: '24 de Octubre, 2023 • 14:30h',
              title: 'Escala de Personalidad Big Five',
              tag: 'Exhaustivo',
              dominantResult: 'Apertura a la Experiencia',
              desc: 'Muestras una fuerte curiosidad intelectual y preferencia por la variedad.',
              icon: Icons.auto_awesome,
              iconBgColor: const Color(0xFFdfe0ff),
            ),
            const SizedBox(height: 16),

            _buildHistoryCard(
              date: '12 de Septiembre, 2023 • 09:15h',
              title: 'Control de Inteligencia Emocional',
              tag: 'Periódico',
              dominantResult: 'Conciencia Social',
              desc: 'Gran capacidad para percibir y comprender las emociones de los demás.',
              icon: Icons.mood,
              iconBgColor: const Color(0xFFe3dfff),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryCard({
    required String date, required String title, required String tag, 
    required String dominantResult, required String desc, 
    required IconData icon, required Color iconBgColor
  }) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFc6c5d3).withOpacity(0.3)),
        boxShadow: [BoxShadow(color: primaryColor.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, 5))]
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(color: iconBgColor, borderRadius: BorderRadius.circular(12)),
                    child: Icon(icon, color: primaryColor),
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(date, style: const TextStyle(fontSize: 12, color: Color(0xFF767682))),
                      const SizedBox(height: 4),
                      Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: primaryColor)),
                    ],
                  )
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),
          const Text('Resultado Dominante', style: TextStyle(fontSize: 12, color: Color(0xFF767682))),
          const SizedBox(height: 4),
          Text(dominantResult, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF5a55a2))),
          const SizedBox(height: 8),
          Text(desc, style: const TextStyle(fontSize: 14, color: Color(0xFF454651))),
          const SizedBox(height: 16),
          const Divider(),
          TextButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.visibility, size: 18),
            label: const Text('Ver Detalles'),
          )
        ],
      ),
    );
  }
}