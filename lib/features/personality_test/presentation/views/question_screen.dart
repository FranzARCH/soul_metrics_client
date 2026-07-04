import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/question_viewmodel.dart';
import '../../../main/presentation/views/main_layout_screen.dart';

class QuestionScreen extends StatefulWidget {
  const QuestionScreen({super.key});

  @override
  State<QuestionScreen> createState() => _QuestionScreenState();
}

class _QuestionScreenState extends State<QuestionScreen> {
  final Color primaryColor = const Color(0xFF142175);
  final Color secondaryColor = const Color(0xFF5a55a2);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<QuestionViewModel>().loadQuestions();
    });
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<QuestionViewModel>();

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Row(
          children: [
            Icon(Icons.psychology, color: primaryColor, size: 28),
            const SizedBox(width: 8),
            Text('SoulMetrics', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: primaryColor)),
          ],
        ),
        actions: [
          TextButton.icon(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.close, size: 18, color: Color(0xFF767682)),
            label: const Text('Salir', style: TextStyle(color: Color(0xFF767682))),
          )
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(color: const Color(0xFFC6C5D3).withValues(alpha: 0.3), height: 1.0),
        ),
      ),
      body: viewModel.isLoading && viewModel.questions.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : viewModel.error != null
              ? Center(child: Text('Error: ${viewModel.error}', style: const TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)))
              : _buildQuestionnaireContent(viewModel),
    );
  }

  Widget _buildQuestionnaireContent(QuestionViewModel viewModel) {
    if (viewModel.questions.isEmpty) return const SizedBox.shrink();

    final currentQuestion = viewModel.questions[viewModel.currentIndex];
    final progressFraction = (viewModel.currentIndex) / viewModel.questions.length;
    final progressPercentage = (progressFraction * 100).toInt();
    final selectedValue = viewModel.answers[currentQuestion.code];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 680),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Pregunta ${viewModel.currentIndex + 1} de ${viewModel.questions.length}',
                    style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold),
                  ),
                  Text('$progressPercentage% completado', style: const TextStyle(color: Color(0xFF767682))),
                ],
              ),
              const SizedBox(height: 12),
              LinearProgressIndicator(
                value: progressFraction,
                backgroundColor: const Color(0xFFedeeef),
                color: primaryColor,
                minHeight: 8,
                borderRadius: BorderRadius.circular(4),
              ),
              const SizedBox(height: 32),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(32),
                  border: Border.all(color: const Color(0xFFC6C5D3).withValues(alpha: 0.3)),
                  boxShadow: [
                    BoxShadow(color: primaryColor.withValues(alpha: 0.05), blurRadius: 30, offset: const Offset(0, 10))
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFcfe8dd),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        'RASGO: ${currentQuestion.category.toUpperCase()}',
                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF091f19)),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      '"${currentQuestion.text}"',
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: primaryColor, height: 1.3),
                    ),
                    const SizedBox(height: 40),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLikertItem(1, 'Totalmente en desacuerdo', selectedValue, viewModel),
                        _buildLikertItem(2, 'En desacuerdo', selectedValue, viewModel),
                        _buildLikertItem(3, 'Neutral', selectedValue, viewModel),
                        _buildLikertItem(4, 'De acuerdo', selectedValue, viewModel),
                        _buildLikertItem(5, 'Totalmente de acuerdo', selectedValue, viewModel),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  OutlinedButton.icon(
                    onPressed: viewModel.currentIndex == 0 ? null : () => viewModel.previousQuestion(),
                    icon: const Icon(Icons.arrow_back),
                    label: const Text('Atrás'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: secondaryColor,
                      side: BorderSide(color: secondaryColor),
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: selectedValue == null
                        ? null
                        : () async {
                            if (viewModel.currentIndex < viewModel.questions.length - 1) {
                              viewModel.nextQuestion();
                            } else {
                              _showProcessingDialog(context);
                              final success = await viewModel.sendAssessment();
                              if (!mounted) return;
                              Navigator.pop(context); // Cierra cargando

                              if (success && viewModel.result != null) {
                                // 🚀 REQUERIMIENTO: Mostrar modal con el diagnóstico inmediato del último quiz
                                _showImmediateResultModal(context, viewModel.result!);
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text(viewModel.error ?? 'Error al procesar el test')),
                                );
                              }
                            }
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Row(
                      children: [
                        Text(viewModel.currentIndex == viewModel.questions.length - 1 ? 'Finalizar' : 'Siguiente'),
                        const SizedBox(width: 8),
                        const Icon(Icons.arrow_forward, size: 18),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLikertItem(int value, String label, int? selectedValue, QuestionViewModel viewModel) {
    final bool isActive = selectedValue == value;

    return Expanded(
      child: GestureDetector(
        onTap: () => viewModel.selectAnswer(value),
        child: Column(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isActive ? secondaryColor : const Color(0xFFF3F4F5),
                border: Border.all(
                  color: isActive ? secondaryColor : const Color(0xFFC6C5D3),
                  width: 2,
                ),
                boxShadow: isActive ? [BoxShadow(color: secondaryColor.withValues(alpha: 0.3), blurRadius: 10)] : null,
              ),
              child: isActive ? const Icon(Icons.check, color: Colors.white) : const SizedBox.shrink(),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 10,
                fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                color: isActive ? primaryColor : const Color(0xFF767682),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showProcessingDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: const Color(0xFFF8F9FA),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFC6C5D3).withValues(alpha: 0.4)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(color: primaryColor),
              const SizedBox(width: 18),
              Expanded(
                child: Text(
                  'Procesando datos con la IA...',
                  style: TextStyle(
                    color: primaryColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showImmediateResultModal(BuildContext context, dynamic result) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (modalContext) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: const Color(0xFFF8F9FA),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: const Color(0xFFC6C5D3).withValues(alpha: 0.35)),
            boxShadow: [
              BoxShadow(
                color: primaryColor.withValues(alpha: 0.08),
                blurRadius: 24,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFdfe0ff),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(Icons.analytics, color: primaryColor, size: 22),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Diagnóstico Inmediato',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                      color: primaryColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFcfe8dd),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Text(
                  'TEST GUARDADO',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF091f19),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                result.message.isNotEmpty ? result.message : 'Tus respuestas han sido procesadas con éxito',
                style: const TextStyle(fontSize: 15, height: 1.45, color: Color(0xFF454651)),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.pop(modalContext);
                        Navigator.pop(context);
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: primaryColor,
                        side: BorderSide(color: primaryColor.withValues(alpha: 0.45)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('Volver al inicio'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: FilledButton(
                      style: FilledButton.styleFrom(
                        backgroundColor: primaryColor,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () {
                        Navigator.of(modalContext).pushAndRemoveUntil(
                          MaterialPageRoute(
                            builder: (_) => const MainLayoutScreen(initialIndex: 1),
                          ),
                          (route) => false,
                        );
                      },
                      child: const Text('Ver resultados'),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}