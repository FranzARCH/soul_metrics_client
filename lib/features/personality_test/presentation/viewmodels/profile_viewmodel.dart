import 'dart:typed_data';

import 'package:flutter/material.dart';
import '../../domain/entities/personality_profile.dart';
import '../../domain/usecases/get_holistic_profile_usecase.dart';
import '../../domain/usecases/export_profile_pdf_usecase.dart';

class ProfileViewModel extends ChangeNotifier {
  final GetHolisticProfileUseCase getHolisticProfileUseCase;
  final ExportProfilePdfUseCase exportProfilePdfUseCase;

  ProfileViewModel({
    required this.getHolisticProfileUseCase,
    required this.exportProfilePdfUseCase,
  });

  PersonalityProfile? profile;
  bool isLoading = false;
  bool isExporting = false;
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

  Future<Uint8List?> exportPdf() async {
    isExporting = true;
    error = null;
    notifyListeners();

    try {
      final pdfBytes = await exportProfilePdfUseCase();
      return pdfBytes;
    } catch (e) {
      error = e.toString().replaceAll('Exception: ', '');
      return null;
    } finally {
      isExporting = false;
      notifyListeners();
    }
  }
}