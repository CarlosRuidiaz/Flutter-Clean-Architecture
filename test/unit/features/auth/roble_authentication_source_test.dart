import 'dart:async';

import 'package:f_clean_template/features/auth/data/datasources/remote/roble_authentication_source.dart';
import 'package:f_clean_template/features/auth/domain/models/authentication_user.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:roble/roble.dart';

/// Roble con el estado de sesion y metodos de autenticacion simulados en memoria.
class _RobleConSesion extends RobleApiDataBase {
  _RobleConSesion(this._actual)
    : super(
        config: RobleApiConfig.fromContract(
          baseUrl: 'https://roble.test-openlab.uninorte.edu.co',
          contractId: 'proyecto_test_12345678',
        ),
      );

  RobleAuthState _actual;
  final _cambios = StreamController<RobleAuthState>.broadcast();

  bool loggedIn = false;
  Map<String, dynamic> usuarioActual = {};
  String? ultimoEmailLogin;
  String? ultimoPasswordLogin;
  String? ultimoEmailRegistro;
  Map<String, dynamic>? ultimoExtraRegistro;
  bool shouldThrow = false;

  @override
  bool get isLoggedIn => loggedIn;

  @override
  Stream<RobleAuthState> get authStateChanges async* {
    yield _actual;
    yield* _cambios.stream;
  }

  void cambiar(RobleAuthReason motivo) {
    _actual = RobleAuthState(user: null, reason: motivo);
    _cambios.add(_actual);
  }

  @override
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
    bool persistSession = true,
  }) async {
    if (shouldThrow) throw Exception('Credenciales invalidas');
    ultimoEmailLogin = email;
    ultimoPasswordLogin = password;
    loggedIn = true;
    return {'accessToken': 'test_token', 'refreshToken': 'test_refresh'};
  }

  @override
  Future<Map<String, dynamic>> register({
    required String email,
    required String password,
    required String name,
    Map<String, dynamic>? extra,
    bool autoLogin = false,
    bool persistSession = true,
  }) async {
    if (shouldThrow) throw Exception('Email ya registrado');
    ultimoEmailRegistro = email;
    ultimoExtraRegistro = extra;
    if (autoLogin) loggedIn = true;
    return {'id': 'user_new'};
  }

  @override
  Future<Map<String, dynamic>> currentUser() async {
    if (shouldThrow) throw Exception('Error obteniendo usuario');
    return usuarioActual;
  }

  @override
  Future<void> logout() async {
    loggedIn = false;
  }

  @override
  Future<bool> restoreSession({bool verify = true}) async {
    return loggedIn;
  }
}

void main() {
  group('RobleAuthenticationSource', () {
    test('sessionChanges no repite el estado actual al suscribirse', () async {
      final roble = _RobleConSesion(
        const RobleAuthState(user: null, reason: RobleAuthReason.restored),
      );
      final avisos = <bool>[];
      final sub = RobleAuthenticationSource(
        roble,
      ).sessionChanges.listen(avisos.add);
      await Future<void>.delayed(Duration.zero);

      // Ya habia sesion: no es un cambio, y avisarlo hacia cargar dos veces.
      expect(avisos, isEmpty);

      roble.cambiar(RobleAuthReason.signedOut);
      await Future<void>.delayed(Duration.zero);
      roble.cambiar(RobleAuthReason.signedIn);
      await Future<void>.delayed(Duration.zero);

      expect(avisos, [false, true]);
      await sub.cancel();
    });

    test('login llama a roble.login con correo y contrasena limpios', () async {
      final roble = _RobleConSesion(
        const RobleAuthState(user: null, reason: RobleAuthReason.signedOut),
      );
      final source = RobleAuthenticationSource(roble);

      final user = AuthenticationUser(
        email: '  test@uninorte.edu.co  ',
        name: 'Carlos',
        password: 'password123',
      );

      final resultado = await source.login(user);

      expect(resultado, isTrue);
      expect(roble.ultimoEmailLogin, 'test@uninorte.edu.co');
      expect(roble.ultimoPasswordLogin, 'password123');
      expect(roble.isLoggedIn, isTrue);
    });

    test('login propaga excepcion cuando Roble rechaza las credenciales', () async {
      final roble = _RobleConSesion(
        const RobleAuthState(user: null, reason: RobleAuthReason.signedOut),
      );
      roble.shouldThrow = true;
      final source = RobleAuthenticationSource(roble);

      final user = AuthenticationUser(
        email: 'error@uninorte.edu.co',
        name: 'Test',
        password: 'wrong',
      );

      expect(() => source.login(user), throwsA(isA<Exception>()));
    });

    test('signUp manda el perfil en el extra con autoLogin true', () async {
      final roble = _RobleConSesion(
        const RobleAuthState(user: null, reason: RobleAuthReason.signedOut),
      );
      final source = RobleAuthenticationSource(roble);

      final user = AuthenticationUser(
        email: 'nuevo@uninorte.edu.co',
        name: 'Nuevo Usuario',
        password: 'pass',
        academicProgram: 'Ingenieria de Sistemas',
        semester: 7,
        skills: const ['Flutter', 'Python'],
        bio: 'Interesado en IA',
      );

      final resultado = await source.signUp(user);

      expect(resultado, isTrue);
      expect(roble.ultimoEmailRegistro, 'nuevo@uninorte.edu.co');
      expect(roble.ultimoExtraRegistro?['academicProgram'], 'Ingenieria de Sistemas');
      expect(roble.ultimoExtraRegistro?['semester'], 7);
      expect(roble.ultimoExtraRegistro?['skills'], ['Flutter', 'Python']);
      expect(roble.ultimoExtraRegistro?['bio'], 'Interesado en IA');
      expect(roble.isLoggedIn, isTrue);
    });

    test('getLoggedUser devuelve null si no hay sesion en Roble', () async {
      final roble = _RobleConSesion(
        const RobleAuthState(user: null, reason: RobleAuthReason.signedOut),
      );
      roble.loggedIn = false;
      final source = RobleAuthenticationSource(roble);

      final user = await source.getLoggedUser();
      expect(user, isNull);
    });

    test('getLoggedUser toma userId de Roble para el id del usuario', () async {
      final roble = _RobleConSesion(
        const RobleAuthState(user: null, reason: RobleAuthReason.signedIn),
      );
      roble.loggedIn = true;
      roble.usuarioActual = {
        'id': 'fila_id_perfil',
        'userId': 'usr_123_identificador',
        'email': 'ana@uninorte.edu.co',
        'name': 'Ana Silva',
      };
      final source = RobleAuthenticationSource(roble);

      final user = await source.getLoggedUser();
      expect(user, isNotNull);
      expect(user!.id, 'usr_123_identificador');
      expect(user.email, 'ana@uninorte.edu.co');
      expect(user.name, 'Ana Silva');
    });

    test('logOut cierra la sesion en Roble', () async {
      final roble = _RobleConSesion(
        const RobleAuthState(user: null, reason: RobleAuthReason.signedIn),
      );
      roble.loggedIn = true;
      final source = RobleAuthenticationSource(roble);

      final resultado = await source.logOut();
      expect(resultado, isTrue);
      expect(roble.isLoggedIn, isFalse);
    });
  });
}
