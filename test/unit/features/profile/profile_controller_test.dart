import 'package:flutter_test/flutter_test.dart';
import 'package:f_clean_template/features/profile/domain/models/profile.dart';
import 'package:f_clean_template/features/profile/domain/repositories/i_profile_repository.dart';
import 'package:f_clean_template/features/profile/ui/viewmodels/profile_controller.dart';

import '../auth/fake_auth_repository.dart';

class _FakeRepository implements IProfileRepository {
  bool shouldThrow = false;
  int callCount = 0;

  @override
  Future<Profile> getCurrentProfile() async {
    callCount++;
    if (shouldThrow) {
      throw Exception('Fallo al cargar perfil');
    }
    return Profile(
      id: 'u1',
      fullName: 'Prueba',
      academicProgram: 'Ingenieria',
      semester: 3,
      skills: ['Dart'],
    );
  }
}

void main() {
  group('ProfileController', () {
    late _FakeRepository profileRepo;
    late FakeAuthRepository authRepo;
    late ProfileController controller;

    setUp(() {
      profileRepo = _FakeRepository();
      authRepo = FakeAuthRepository();
      controller = ProfileController(profileRepo, authRepo);
    });

    tearDown(() {
      controller.onClose();
    });

    test('el controlador expone el perfil del repositorio y apaga isLoading', () async {
      await controller.getCurrentProfile();
      expect(controller.profile?.fullName, 'Prueba');
      expect(controller.profile?.id, 'u1');
      expect(controller.isLoading.value, isFalse);
    });

    test('isLoading vuelve a false y profile queda en null cuando el repositorio falla', () async {
      profileRepo.shouldThrow = true;

      await controller.getCurrentProfile();

      expect(controller.profile, isNull);
      expect(controller.isLoading.value, isFalse);
    });

    test('reacciona a cambios de sesion: limpia con sesion false y recarga con true', () async {
      controller.onInit();
      await Future<void>.delayed(const Duration(milliseconds: 50));
      expect(controller.profile, isNotNull);

      // Cerrar sesion
      authRepo.emitirSesion(false);
      await Future<void>.delayed(const Duration(milliseconds: 50));
      expect(controller.profile, isNull);

      // Abrir sesion
      authRepo.emitirSesion(true);
      await Future<void>.delayed(const Duration(milliseconds: 50));
      expect(controller.profile?.fullName, 'Prueba');
    });
  });
}
