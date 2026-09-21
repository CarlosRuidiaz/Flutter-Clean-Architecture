import 'dart:async';

import 'package:f_clean_template/features/auth/domain/models/authentication_user.dart';
import 'package:f_clean_template/features/auth/domain/repositories/i_auth_repository.dart';

/// Doble de `IAuthRepository` para las pruebas que solo necesitan que exista
/// una sesion.
///
/// `emitirSesion` deja empujar un cambio a mano, que es lo que permite probar
/// que quien cachea el perfil se entera de que entro otra persona.
class FakeAuthRepository implements IAuthRepository {
  final StreamController<bool> _sesion = StreamController<bool>.broadcast();

  void emitirSesion(bool haySesion) => _sesion.add(haySesion);

  Future<void> cerrar() => _sesion.close();

  @override
  Stream<bool> get sessionChanges => _sesion.stream;

  @override
  Future<bool> login(AuthenticationUser user) async => true;

  @override
  Future<bool> signUp(AuthenticationUser user) async => true;

  @override
  Future<bool> restoreSession() async => true;

  @override
  Future<AuthenticationUser?> getLoggedUser() async => null;

  @override
  Future<bool> logOut() async => true;

  @override
  Future<bool> validate(String email, String validationCode) async => true;

  @override
  Future<bool> validateToken() async => true;

  @override
  Future<void> forgotPassword(String email) async {}
}
