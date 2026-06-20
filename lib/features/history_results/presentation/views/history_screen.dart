import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/history_viewmodel.dart';
import '../../domain/entities/history_item.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final Color primaryColor = const Color(0xFF142175);
  final searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<HistoryViewModel>().fetchHistory();
    });
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<HistoryViewModel>();

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Historial de Análisis', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: primaryColor)),
              const SizedBox(height: 8),
              const Text('Sigue tu evolución psicológica a través de tus evaluaciones periódicas.', style: TextStyle(color: Color(0xFF767682))),
              const SizedBox(height: 24),

              // Buscador funcional conectado al filtro del ViewModel
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: searchController,
                      onChanged: viewModel.filterSearch,
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

              if (viewModel.isLoading)
                const Center(child: Padding(padding: EdgeInsets.all(32.0), child: CircularProgressIndicator()))
              else if (viewModel.error != null)
                Center(child: Text('Error: ${viewModel.error}', style: const TextStyle(color: Colors.redAccent)))
              else if (viewModel.filteredRecords.isEmpty)
                const Center(child: Padding(padding: EdgeInsets.all(32.0), child: Text('No hay evaluaciones registradas.')))
              else
                ...viewModel.filteredRecords.map((record) => Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: _buildDynamicHistoryCard(record),
                    )),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDynamicHistoryCard(HistoryItem record) {
    // Determinamos un rasgo dominante de forma dinámica según el puntaje más alto devuelto en predicted_scores
    String dominantTrait = 'Calculando...';
    double highestScore = -1.0;
    
    record.predictedScores.forEach((key, value) {
      if (value > highestScore) {
        highestScore = value;
        dominantTrait = key;
      }
    });

    final String localizedTrait = _localiseTrait(dominantTrait);
    final String description = record.traitDescriptions[dominantTrait] ?? 'Evaluación completada con éxito.';
    
    // Formateo manual sutil de la marca de tiempo de Django
    final String formattedDate = "${record.createdAt.day}/${record.createdAt.month}/${record.createdAt.year} • ${record.createdAt.hour}:${record.createdAt.minute.toString().padLeft(2, '0')}h";

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
              Expanded(
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(color: const Color(0xFFdfe0ff), borderRadius: BorderRadius.circular(12)),
                      child: Icon(Icons.auto_awesome, color: primaryColor),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(formattedDate, style: const TextStyle(fontSize: 12, color: Color(0xFF767682))),
                          const SizedBox(height: 4),
                          Text('Reporte de Rasgos #${record.id}', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: primaryColor)),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          const Text('Resultado Dominante', style: TextStyle(fontSize: 12, color: Color(0xFF767682))),
          const SizedBox(height: 4),
          Text(localizedTrait, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF5a55a2))),
          const SizedBox(height: 8),
          Text(description, style: const TextStyle(fontSize: 14, color: Color(0xFF454651))),
          const SizedBox(height: 16),
          const Divider(),
          TextButton.icon(
            onPressed: () {
              // Aquí podrías inyectar el record.graphicsData directamente a tu vista de resultados para ver el histórico detallado
            },
            icon: const Icon(Icons.visibility, size: 18),
            label: const Text('Ver Detalles'),
          )
        ],
      ),
    );
  }

  String _localiseTrait(String traitKey) {
    switch (traitKey) {
      case 'Openness': return 'Apertura a la Experiencia';
      case 'Conscientiousness': return 'Responsabilidad';
      case 'Extraversion': return 'Extraversión';
      case 'Agreeableness': return 'Amabilidad';
      case 'Neuroticism': return 'Neuroticismo';
      default: return traitKey;
    }
  }
}