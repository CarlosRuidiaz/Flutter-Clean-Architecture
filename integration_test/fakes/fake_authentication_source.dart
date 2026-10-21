import 'dart:async';

import 'package:f_clean_template/features/auth/data/datasources/remote/i_authentication_source.dart';
import 'package:f_clean_template/features/auth/domain/models/authentication_user.dart';

/// Un usuario que ya existe cuando arranca la prueba.
///
/// Lleva programa, semestre y habilidades porque "Publicar" solo se habilita
/// si el perfil tiene programa: sin ellos el flujo de crear proyecto no avanza.
class UsuarioSembrado {
  const UsuarioSembrado({
    required this.email,
    required this.password,
    required this.name,
    required this.academicProgram,
    required this.semester,
    required this.skills,
    this.bio,
    this.id,
  });

  final String email;
  final String password;
  final String name;
  final String academicProgram;
  final int semester;
  final List<String> skills;
  final String? bio;

  /// Si no se pasa, la fuente le asigna uno.
  final String? id;
}

/// Una cuenta guardada en la fuente falsa: lo que Roble tendria en su tabla de
/// usuarios, con el perfil del registro en lo que alli es el `extra`.
class CuentaFalsa {
  const CuentaFalsa({
    required this.id,
    required this.email,
    required this.password,
    required this.name,
    required this.academicProgram,
    required this.semester,
    required this.skills,
    this.bio,
  });

  /// Es el `userId` de Roble, y de el sale el `leaderId` de cada proyecto.
  final String id;
  final String email;
  final String password;
  final String name;
  final String academicProgram;
  final int semester;
  final List<String> skills;
  final String? bio;
}

/// `IAuthenticationSource` en memoria: no hay red ni servidor.
///
/// Imita las reglas de Roble que se notan desde la app: solo correos
/// `@uninorte.edu.co`, contrasena con mayuscula, minuscula, numero y simbolo, y
/// un correo no se registra dos veces. Cuando una regla falla devuelve `false`
/// en vez de lanzar, asi el controlador muestra su mensaje de siempre.
class FakeAuthenticationSource implements IAuthenticationSource {
  FakeAuthenticationSource({List<UsuarioSembrado> usuarios = const []}) {
    for (final usuario in usuarios) {
      _cuentas.add(
        CuentaFalsa(
          id: usuario.id ?? _nuevoId(),
          email: _normalizar(usuario.email),
          password: usuario.password,
          name: usuario.name,
          academicProgram: usuario.academicProgram,
          semester: usuario.semester,
          skills: List<String>.unmodifiable(usuario.skills),
          bio: usuario.bio,
        ),
      );
    }
  }

  static const String dominioInstitucional = '@uninorte.edu.co';

  /// Los simbolos que Roble acepta en una contrasena.
  static final RegExp _simbolo = RegExp(r'[!@#$_\-]');

  final List<CuentaFalsa> _cuentas = [];
  final StreamController<bool> _sesion = StreamController<bool>.broadcast();
  CuentaFalsa? _conSesion;
  int _siguienteId = 1;

  /// Todas las cuentas guardadas, las sembradas y las creadas en la prueba.
  List<CuentaFalsa> get cuentas => List.unmodifiable(_cuentas);

  /// Quien tiene la sesion abierta, o null.
  CuentaFalsa? get cuentaConSesion => _conSesion;

  /// La cuenta de [email], sin distinguir mayusculas, o null.
  CuentaFalsa? cuentaDe(String email) {
    final buscado = _normalizar(email);
    for (final cuenta in _cuentas) {
      if (cuenta.email == buscado) return cuenta;
    }
    return null;
  }

  /// La regla de Roble: al menos 8 caracteres, con mayuscula, minuscula,
  /// numero y uno de `! @ # $ _ -`.
  static bool contrasenaValida(String contrasena) =>
      contrasena.length >= 8 &&
      contrasena.contains(RegExp(r'[A-Z]')) &&
      contrasena.contains(RegExp(r'[a-z]')) &&
      contrasena.contains(RegExp(r'[0-9]')) &&
      contrasena.contains(_simbolo);

  String _nuevoId() => 'usuario-falso-${_siguienteId++}';

  static String _normalizar(String email) => email.trim().toLowerCase();

  void _abrirSesion(CuentaFalsa cuenta) {
    _conSesion = cuenta;
    _sesion.add(true);
  }

  /// Solo avisa de cambios, igual que la de Roble: no repite el estado actual
  /// al suscribirse. Si lo repitiera, cada controlador cargaria dos veces.
  @override
  Stream<bool> get sessionChanges => _sesion.stream;

  @override
  Future<bool> login(AuthenticationUser user) async {
    final cuenta = cuentaDe(user.email);
    if (cuenta == null || cuenta.password != user.password) return false;

    _abrirSesion(cuenta);
    return true;
  }

  @override
  Future<bool> signUp(AuthenticationUser user) async {
    final email = _normalizar(user.email);
    if (!email.endsWith(dominioInstitucional)) return false;
    if (!contrasenaValida(user.password)) return false;
    if (cuentaDe(email) != null) return false;

    final cuenta = CuentaFalsa(
      id: _nuevoId(),
      email: email,
      password: user.password,
      name: user.name.trim(),
      academicProgram: user.academicProgram ?? '',
      semester: user.semester ?? 0,
      skills: List<String>.unmodifiable(user.skills ?? const <String>[]),
      bio: user.bio,
    );
    _cuentas.add(cuenta);

    // Como `register` de Roble con `autoLogin: true`: la sesion queda abierta.
    _abrirSesion(cuenta);
    return true;
  }

  @override
  Future<bool> restoreSession() async => _conSesion != null;

  @override
  Future<AuthenticationUser?> getLoggedUser() async {
    final cuenta = _conSesion;
    if (cuenta == null) return null;

    return AuthenticationUser(
      id: cuenta.id,
      email: cuenta.email,
      name: cuenta.name,
      // Roble nunca devuelve la contrasena.
      password: '',
    );
  }

  @override
  Future<bool> logOut() async {
    _conSesion = null;
    _sesion.add(false);
    return true;
  }

  @override
  Future<bool> validate(String email, String validationCode) async => true;

  @override
  Future<bool> refreshToken() async => _conSesion != null;

  @override
  Future<bool> forgotPassword(String email) async => true;

  @override
  Future<bool> resetPassword(
    String email,
    String newPassword,
    String validationCode,
  ) async => true;

  @override
  Future<bool> verifyToken() async => _conSesion != null;
}
