import '../entities/personality_profile.dart';
import '../repositories/iprofile_repository.dart';

class GetHolisticProfileUseCase {
  final IProfileRepository repository;

  GetHolisticProfileUseCase(this.repository);

  Future<PersonalityProfile> call() async {
    return await repository.getHolisticProfile();
  }
}