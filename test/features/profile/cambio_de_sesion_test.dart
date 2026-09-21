import 'package:f_clean_template/features/profile/domain/models/profile.dart';
import 'package:f_clean_template/features/profile/domain/repositories/i_profile_repository.dart';
import 'package:f_clean_template/features/profile/ui/viewmodels/profile_controller.dart';
import 'package:flutter_test/flutter_test.dart';

import '../auth/fake_auth_repository.dart';

/// Devuelve el perfil de quien tenga la sesion ahora mismo.
class _SesionFalsa implements IProfileRepository {
  String quien = 'ana';
  bool haySesion = true;

  @override
  Future<Profile> getCurrentProfile() async {
    if (!haySesion) {
      throw StateError('No hay sesion activa.');
    }
    return quien == 'ana'
        ? Profile(
            id: 'id-ana',
            fullName: 'Ana',
            academicProgram: 'Ing. de Sistemas',
            semester: 8,
            skills: const ['Python'],
          )
        : Profile(
            id: 'id-beto',
            fullName: 'Beto',
            academicProgram: 'Psicología',
            semester: 3,
            skills: const ['Marketing'],
          );
  }
}

void main() {
  group('ProfileController · cambio de sesion', () {
    late _SesionFalsa sesion;
    late FakeAuthRepository auth;
    late ProfileController controller;

    setUp(() async {
      sesion = _SesionFalsa();
      auth = FakeAuthRepository();
      controller = ProfileController(sesion, auth);
      controller.onInit();
      await controller.getCurrentProfile();
    });

    tearDown(() async {
      controller.onClose();
      await auth.cerrar();
    });

    test('al entrar otra cuenta, el perfil se recarga', () async {
      expect(controller.profile?.fullName, 'Ana');

      // Beto entra. Nadie llama al controlador a mano: se entera por el aviso.
      sesion.quien = 'beto';
      auth.emitirSesion(true);
      await Future<void>.delayed(Duration.zero);

      expect(controller.profile?.fullName, 'Beto');
      // El id es lo que decide quien lidera cada proyecto: si se quedara
      // pegado, Beto crearia ideas a nombre de Ana.
      expect(controller.profile?.id, 'id-beto');
    });

    test('al cerrar sesion, el perfil se limpia', () async {
      expect(controller.profile?.fullName, 'Ana');

      sesion.haySesion = false;
      auth.emitirSesion(false);
      await Future<void>.delayed(Duration.zero);

      expect(controller.profile, isNull);
    });

    test('sin sesion, pedir el perfil no revienta: lo deja vacio', () async {
      sesion.haySesion = false;

      await controller.getCurrentProfile();

      expect(controller.profile, isNull);
      expect(controller.isLoading.value, isFalse);
    });
  });
}
