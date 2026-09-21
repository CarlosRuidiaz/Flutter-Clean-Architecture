import 'package:flutter_test/flutter_test.dart';

import '../auth/fake_auth_repository.dart';

import 'package:f_clean_template/features/profile/domain/models/profile.dart';
import 'package:f_clean_template/features/profile/domain/repositories/i_profile_repository.dart';
import 'package:f_clean_template/features/profile/ui/viewmodels/profile_controller.dart';

class _FakeRepository implements IProfileRepository {
  @override
  Future<Profile> getCurrentProfile() async => Profile(
        fullName: 'Prueba',
        academicProgram: 'X',
        semester: 1,
        skills: ['A'],
      );
}

void main() {
  test('el controlador expone el perfil del repositorio', () async {
    final controller = ProfileController(_FakeRepository(), FakeAuthRepository());
    await controller.getCurrentProfile();
    expect(controller.profile?.fullName, 'Prueba');
    expect(controller.isLoading.value, isFalse);
  });
}
