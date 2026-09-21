import 'package:loggy/loggy.dart';
import 'package:roble/roble.dart';

import '../../../domain/models/authentication_user.dart';
import 'i_authentication_source.dart';

/// Autenticacion contra Roble, el backend del curso.
///
/// Recibe la instancia por constructor y no crea ninguna: cada copia tendria
/// su propia sesion. El paquete renueva los tokens por dentro, asi que aqui no
/// hay nada que refrescar a mano.
///
/// El perfil del estudiante no tiene tabla: viaja en el `extra` del registro.
class RobleAuthenticationSource with UiLoggy implements IAuthenticationSource {
  RobleAuthenticationSource(this.roble);

  final RobleApiDataBase roble;

  @override
  Future<bool> login(AuthenticationUser user) async {
    loggy.debug('RobleAuthenticationSource: login ${user.email}');
    await roble.login(email: user.email.trim(), password: user.password);
    return true;
  }

  @override
  Future<bool> signUp(AuthenticationUser user) async {
    loggy.debug('RobleAuthenticationSource: signUp ${user.email}');
    await roble.register(
      email: user.email.trim(),
      password: user.password,
      name: user.name.trim(),
      extra: {
        if (user.academicProgram != null)
          'academicProgram': user.academicProgram,
        if (user.semester != null) 'semester': user.semester,
        if (user.skills != null) 'skills': user.skills,
      },
      // Activacion directa: no se pide codigo por correo.
      autoLogin: true,
    );
    return true;
  }

  @override
  Future<bool> restoreSession() async {
    loggy.debug('RobleAuthenticationSource: restoreSession');
    return await roble.restoreSession();
  }

  @override
  Future<AuthenticationUser?> getLoggedUser() async {
    loggy.debug('RobleAuthenticationSource: getLoggedUser');
    if (!roble.isLoggedIn) return null;

    final usuario = await roble.currentUser();
    return AuthenticationUser(
      // userId, no id: el `id` del mapa es la fila del perfil, y de este valor
      // depende quien es el lider de cada proyecto.
      id: usuario['userId'] as String?,
      email: (usuario['email'] as String?) ?? '',
      name: (usuario['name'] as String?) ?? '',
      // Roble nunca devuelve la contrasena, y aqui no hace falta.
      password: '',
    );
  }

  @override
  Future<bool> logOut() async {
    loggy.debug('RobleAuthenticationSource: logOut');
    await roble.logout();
    return true;
  }

  @override
  Future<bool> validate(String email, String validationCode) async {
    loggy.debug('RobleAuthenticationSource: validate $email');
    await roble.verifyEmail(email: email.trim(), code: validationCode);
    return true;
  }

  @override
  Future<bool> refreshToken() async {
    loggy.debug('RobleAuthenticationSource: refreshToken');
    // El paquete renueva solo. Lo unico util que se puede responder es si la
    // sesion sigue viva.
    return await roble.restoreSession();
  }

  @override
  Future<bool> forgotPassword(String email) async {
    loggy.debug('RobleAuthenticationSource: forgotPassword $email');
    await roble.forgotPassword(email: email.trim());
    return true;
  }

  @override
  Future<bool> resetPassword(
    String email,
    String newPassword,
    String validationCode,
  ) async {
    loggy.debug('RobleAuthenticationSource: resetPassword $email');
    // Roble identifica el restablecimiento por el token del correo, no por el
    // correo: el codigo que llega aqui es ese token.
    await roble.resetPassword(
      token: validationCode,
      newPassword: newPassword,
    );
    return true;
  }

  @override
  Future<bool> verifyToken() async {
    loggy.debug('RobleAuthenticationSource: verifyToken');
    return roble.isLoggedIn;
  }
}
