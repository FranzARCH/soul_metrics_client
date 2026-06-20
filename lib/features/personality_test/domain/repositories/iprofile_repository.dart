import '../entities/personality_profile.dart';

abstract class IProfileRepository {
  Future<PersonalityProfile> getHolisticProfile();
}