import 'dart:async';

import 'package:f_clean_template/features/auth/domain/models/authentication_user.dart';
import 'package:f_clean_template/features/auth/domain/repositories/i_auth_repository.dart';
import 'package:f_clean_template/features/auth/ui/viewmodels/authentication_controller.dart';
import 'package:flutter_test/flutter_test.dart';

/// Repositorio falso que apunta lo que le piden. Ninguna prueba de aqui debe
/// llegar a el: la validacion del dominio corta antes de salir a la red.
class _FakeAuthRepository implements IAuthRepository {
  final List<AuthenticationUser> registrados = [];
  final StreamController<bool> _sesion = StreamController<bool>.broadcast();

  @override
  Stream<bool> get sessionChanges => _sesion.stream;

  final List<AuthenticationUser> entradas = [];

  @override
  Future<bool> signUp(AuthenticationUser user) async {
    registrados.add(user);
    return true;
  }

  @override
  Future<bool> login(AuthenticationUser user) async {
    entradas.add(user);
    return true;
  }

  @override
  Future<AuthenticationUser?> getLoggedUser() async =>
      entradas.isEmpty && registrados.isEmpty
          ? null
          : AuthenticationUser(
              id: '9c1e',
              email: 'ana@uninorte.edu.co',
              name: 'Ana García',
              password: '',
            );

  @override
  Future<bool> restoreSession() async => false;

  @override
  Future<bool> logOut() async => true;

  @override
  Future<bool> validate(String email, String validationCode) async => true;

  @override
  Future<bool> validateToken() async => true;

  @override
  Future<void> forgotPassword(String email) async {}
}

void main() {
  group('AuthenticationController · correo institucional', () {
    late _FakeAuthRepository repository;
    late AuthenticationController controller;

    setUp(() {
      repository = _FakeAuthRepository();
      controller = AuthenticationController(repository);
    });

    test('esCorreoInstitucional acepta el dominio de la universidad', () {
      expect(
        AuthenticationController.esCorreoInstitucional('ana@uninorte.edu.co'),
        isTrue,
      );
      // Sin distinguir mayusculas ni espacios de sobra: se escribe a mano.
      expect(
        AuthenticationController.esCorreoInstitucional(
          '  Ana@UniNorte.Edu.Co  ',
        ),
        isTrue,
      );
    });

    test('esCorreoInstitucional rechaza cualquier otro dominio', () {
      for (final correo in [
        'ana@gmail.com',
        'ana@uninorte.edu', // le falta el .co
        'ana@uninorte.edu.co.attacker.com', // no termina en el dominio
        'ana@otrauninorte.edu.co.mx',
        'ana',
        '',
      ]) {
        expect(
          AuthenticationController.esCorreoInstitucional(correo),
          isFalse,
          reason: '"$correo" no deberia pasar',
        );
      }
    });

    test('signUp con correo de fuera no sale a la red y explica por que',
        () async {
      final creado = await controller.signUp(
        'ana@gmail.com',
        'UnaClaveLarga1',
        name: 'Ana García',
        academicProgram: 'Ing. de Sistemas',
        semester: 8,
        skills: const ['Python'],
      );

      expect(creado, isFalse);
      expect(repository.registrados, isEmpty);
      expect(controller.error.value, contains('@uninorte.edu.co'));
    });

    test('login con correo de fuera tampoco sale a la red', () async {
      final entro = await controller.login('ana@gmail.com', 'UnaClaveLarga1');

      expect(entro, isFalse);
      expect(repository.entradas, isEmpty);
      expect(controller.error.value, contains('@uninorte.edu.co'));
    });

    test('signUp institucional manda el perfil completo al repositorio',
        () async {
      final creado = await controller.signUp(
        'ana@uninorte.edu.co',
        'UnaClaveLarga1',
        name: 'Ana García',
        academicProgram: 'Ing. de Sistemas',
        semester: 8,
        skills: const ['Python', 'Diseño UX'],
      );

      expect(creado, isTrue);
      final enviado = repository.registrados.single;
      expect(enviado.email, 'ana@uninorte.edu.co');
      expect(enviado.name, 'Ana García');
      expect(enviado.academicProgram, 'Ing. de Sistemas');
      expect(enviado.semester, 8);
      expect(enviado.skills, ['Python', 'Diseño UX']);
      // register con autoLogin deja la sesion abierta.
      expect(controller.isLogged, isTrue);
    });

    test('una contrasena corta se corta antes que el dominio', () async {
      final creado = await controller.signUp(
        'ana@uninorte.edu.co',
        '123',
        name: 'Ana',
        academicProgram: 'Ing. de Sistemas',
        semester: 1,
        skills: const ['Python'],
      );

      expect(creado, isFalse);
      expect(repository.registrados, isEmpty);
      expect(controller.error.value, contains('caracteres'));
    });
  });
}
