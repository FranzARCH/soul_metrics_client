import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

// Imports de tus pantallas
import '../../auth/presentation/viewmodels/auth_viewmodel.dart';
import '../../auth/presentation/views/login_screen.dart';
import '../../auth/presentation/views/register_screen.dart';
import '../../main/presentation/views/home_screen.dart';
import '../../personality_test/presentation/views/results_screen.dart';
import '../../history_results/presentation/views/history_screen.dart';
import '../../profile/presentation/views/profile_screen.dart';
import '../../personality_test/presentation/views/question_screen.dart';
import '../presentation/views/main_layout_screen.dart'; 
import '../../../injection_container.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>();

final goRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/login',
  
  refreshListenable: locator<AuthViewModel>(), // Esto obliga a GoRouter a re-ejecutar el redirect cada vez que hagas notifyListeners() en Auth

  redirect: (BuildContext context, GoRouterState state) {
    final authVm = context.read<AuthViewModel>();
    
    // 1. Mientras lee del almacenamiento local (Hive/SharedPreferences), pausamos el ruteo por completo.
    // GoRouter se mantendrá en espera en la URL en la que intentó ingresar el usuario.
    if (authVm.isBootstrapping) {
      return null; 
    }

    final bool itemAuthenticated = authVm.isAuthenticated;
    final bool isLoggingIn = state.matchedLocation == '/login';
    final bool isRegistering = state.matchedLocation == '/register';

    // 2. Si NO está autenticado y NO está intentando ingresar o registrarse, forzar /login
    if (!itemAuthenticated && !isLoggingIn && !isRegistering) {
      return '/login';
    }

    // 3. Si YA está autenticado e intenta acceder a las pantallas de credenciales, mandarlo al home
    if (itemAuthenticated && (isLoggingIn || isRegistering)) {
      return '/';
    }

    // En cualquier otro caso (como refrescar estando en /test/123), permite al usuario quedarse ahí de forma segura
    return null;
  },
  routes: [
    GoRoute(
      path: '/login',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/register',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const RegisterScreen(),
    ),
    GoRoute(
      path: '/test', // El : indica que es dinámico
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const QuestionScreen(), // Aquí puedes pasar el testId si lo necesitas
    ),
    // Configuración de las pestañas persistentes
    StatefulShellRoute.indexedStack(
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state, navigationShell) {
        return MainLayoutScreen(navigationShell: navigationShell);
      },
      branches: [
        StatefulShellBranch(
          routes: [GoRoute(path: '/', builder: (context, state) => const HomeScreen())],
        ),
        StatefulShellBranch(
          routes: [GoRoute(path: '/results', builder: (context, state) => const ResultsScreen())],
        ),
        StatefulShellBranch(
          routes: [GoRoute(path: '/history', builder: (context, state) => const HistoryScreen())],
        ),
        StatefulShellBranch(
          routes: [GoRoute(path: '/profile', builder: (context, state) => const ProfileScreen())],
        ),
      ],
    ),
  ],
);

class AuthRefreshNotifier extends ChangeNotifier {
  AuthRefreshNotifier._internal();
  static final AuthRefreshNotifier _instance = AuthRefreshNotifier._internal();
  factory AuthRefreshNotifier() => _instance;
}