import 'package:flutter/material.dart';
import '../../domain/entities/personality_profile.dart';
import '../../domain/usecases/get_holistic_profile_usecase.dart';

class ProfileViewModel extends ChangeNotifier {
  final GetHolisticProfileUseCase getHolisticProfileUseCase;

  ProfileViewModel({required this.getHolisticProfileUseCase});

  PersonalityProfile? profile;
  bool isLoading = false;
  String? error;

  Future<void> loadProfileData() async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      profile = await getHolisticProfileUseCase();
    } catch (e) {
      error = e.toString().replaceAll('Exception: ', '');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}