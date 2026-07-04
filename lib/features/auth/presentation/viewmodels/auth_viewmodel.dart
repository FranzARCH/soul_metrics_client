import 'package:flutter/material.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/register_usecase.dart';
import '../../domain/usecases/get_profile_usecase.dart';
import '../../domain/usecases/update_profile_usecase.dart';
import '../../domain/usecases/logout_usecase.dart';
import '../../domain/usecases/restore_session_usecase.dart';
import '../../domain/entities/user_entity.dart';

class AuthViewModel extends ChangeNotifier {
  final LoginUseCase loginUseCase;
  final RegisterUseCase registerUseCase;
  final GetProfileUseCase getProfileUseCase;
  final UpdateProfileUseCase updateProfileUseCase;
  final LogoutUseCase logoutUseCase;
  final RestoreSessionUseCase restoreSessionUseCase;

  AuthViewModel({
    required this.loginUseCase,
    required this.registerUseCase,
    required this.getProfileUseCase,
    required this.updateProfileUseCase,
    required this.logoutUseCase,
    required this.restoreSessionUseCase,
  });

  bool isLoading = false;
  bool isBootstrapping = false;
  String? errorMessage;
  User? currentUser;

  bool get isAuthenticated => currentUser != null;

  Future<bool> restoreSession() async {
    isBootstrapping = true;
    errorMessage = null;
    notifyListeners();

    try {
      final restored = await restoreSessionUseCase();
      if (restored) {
        currentUser = await getProfileUseCase();
      }
      isBootstrapping = false;
      notifyListeners();
      return restored;
    } catch (_) {
      currentUser = null;
      isBootstrapping = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> login(String usernameOrEmail, String password) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      currentUser = await loginUseCase(usernameOrEmail, password);
      isLoading = false;
      notifyListeners();
      return true; 
    } catch (e) {
      errorMessage = e.toString().replaceAll('Exception: ', '');
      if (errorMessage!.contains('401') || errorMessage!.toLowerCase().contains('unauthorized')) {
        errorMessage = 'Credenciales inválidas. En este backend debes iniciar sesión con el nombre de usuario y la contraseña, no con el correo.';
      }
      isLoading = false;
      notifyListeners();
      return false; 
    }
  }

  Future<bool> register(String username, String email, String password, int age, String occupation) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      currentUser = await registerUseCase(username, email, password, age, occupation);
      isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      errorMessage = e.toString().replaceAll('Exception: ', '');
      isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> loadProfile() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      currentUser = await getProfileUseCase();
      isLoading = false;
      notifyListeners();
    } catch (e) {
      errorMessage = e.toString().replaceAll('Exception: ', '');
      if (errorMessage!.contains('401') || errorMessage!.toLowerCase().contains('unauthorized')) {
        errorMessage = 'Credenciales inválidas. En este backend debes iniciar sesión con el nombre de usuario y la contraseña, no con el correo.';
      }
      if (errorMessage!.toLowerCase().contains('sesión expirada') || errorMessage!.toLowerCase().contains('sesion expirada')) {
        currentUser = null;
      }
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateProfile(String username, String email, int age, String occupation) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      currentUser = await updateProfileUseCase(username, email, age, occupation);
      isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      errorMessage = e.toString().replaceAll('Exception: ', '');
      if (errorMessage!.toLowerCase().contains('sesión expirada') || errorMessage!.toLowerCase().contains('sesion expirada')) {
        currentUser = null;
      }
      isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    await logoutUseCase();
    currentUser = null;
    errorMessage = null;
    notifyListeners();
  }
}