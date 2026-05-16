import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'injection_container.dart';
import 'features/auth/presentation/viewmodels/auth_viewmodel.dart';
import 'features/auth/presentation/views/login_screen.dart';

void main() {
  setupLocator(); 
  
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => locator<AuthViewModel>()),
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
      home: const LoginScreen(), 
    );
  }
}