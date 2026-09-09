import '../../domain/models/profile.dart';
import '../../domain/repositories/i_profile_repository.dart';
import '../datasources/i_profile_source.dart';

class ProfileRepository implements IProfileRepository {
  ProfileRepository(this.source);

  final IProfileSource source;

  @override
  Future<Profile> getCurrentProfile() async => await source.getCurrentProfile();
}
