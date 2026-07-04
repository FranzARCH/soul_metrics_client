import 'dart:typed_data';

import '../entities/personality_profile.dart';

abstract class IProfileRepository {
  Future<PersonalityProfile> getHolisticProfile();
  Future<Uint8List> exportPersonalityProfilePdf();
}
