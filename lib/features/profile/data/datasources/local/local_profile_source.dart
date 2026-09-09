import '../../../domain/models/profile.dart';
import '../i_profile_source.dart';

class LocalProfileSource implements IProfileSource {
  @override
  Future<Profile> getCurrentProfile() async {
    return Profile(
      id: '1',
      fullName: 'Carlos Ruidíaz',
      academicProgram: 'Ingeniería de Sistemas',
      semester: 8,
      skills: ['Investigación', 'Diseño UX'],
    );
  }
}
