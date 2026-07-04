import 'dart:typed_data';

import '../entities/personality_profile.dart';
import '../repositories/iprofile_repository.dart';

class ExportProfilePdfUseCase {
  final IProfileRepository repository;

  ExportProfilePdfUseCase(this.repository);

  Future<Uint8List> call() async {
    return await repository.exportPersonalityProfilePdf();
  }
}