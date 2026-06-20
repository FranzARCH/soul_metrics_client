import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:soul_metrics_client/features/history_results/presentation/viewmodels/history_viewmodel.dart';
import 'package:soul_metrics_client/features/personality_test/presentation/viewmodels/profile_viewmodel.dart';
import 'package:soul_metrics_client/features/personality_test/presentation/viewmodels/question_viewmodel.dart';
import 'injection_container.dart';
import 'features/auth/presentation/viewmodels/auth_viewmodel.dart';
import 'features/auth/presentation/views/auth_gate.dart';

void main() {
  setupLocator(); 
  
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => locator<AuthViewModel>()),
        ChangeNotifierProvider(create: (_) => locator<QuestionViewModel>()),
        ChangeNotifierProvider(create: (_) => locator<HistoryViewModel>()),
        ChangeNotifierProvider(create: (_) => locator<ProfileViewModel>()),
      ],
      child: const SoulMetricsApp(),
    ),
  );
}

class SoulMetricsApp extends StatelessWidget {
  const SoulMetricsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SoulMetrics',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Inter',
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF142175)),
        useMaterial3: true,
      ),
      home: const AuthGate(), 
    );
  }
}