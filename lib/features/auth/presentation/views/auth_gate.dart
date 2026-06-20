import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../main/presentation/views/main_layout_screen.dart';
import '../viewmodels/auth_viewmodel.dart';
import 'login_screen.dart';

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  late final Future<bool> _restoreFuture;

  @override
  void initState() {
    super.initState();
    _restoreFuture = context.read<AuthViewModel>().restoreSession();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _restoreFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final restored = snapshot.data == true;
        if (restored) {
          return const MainLayoutScreen();
        }

        return const LoginScreen();
      },
    );
  }
}
