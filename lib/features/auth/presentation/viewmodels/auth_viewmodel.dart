import 'package:flutter/material.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/register_usecase.dart';
import '../../domain/entities/user_entity.dart';

class AuthViewModel extends ChangeNotifier {
  final LoginUseCase loginUseCase;
  final RegisterUseCase registerUseCase;

  AuthViewModel({required this.loginUseCase, required this.registerUseCase});

  bool isLoading = false;
  String? errorMessage;
  User? currentUser;

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
      isLoading = false;
      notifyListeners();
      return false; 
    }
  }

  Future<bool> register(String username, String firstName, String lastName, String email, String password) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      currentUser = await registerUseCase(username, firstName, lastName, email, password);
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
}