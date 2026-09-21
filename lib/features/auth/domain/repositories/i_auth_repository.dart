import '../models/authentication_user.dart';

abstract class IAuthRepository {
  /// Emite cada vez que la sesion cambia: true al entrar, false al salir.
  Stream<bool> get sessionChanges;

  Future<bool> login(AuthenticationUser user);

  Future<bool> restoreSession();

  Future<AuthenticationUser?> getLoggedUser();

  Future<bool> signUp(AuthenticationUser user);

  Future<bool> logOut();

  Future<bool> validate(String email, String validationCode);

  Future<bool> validateToken();

  Future<void> forgotPassword(String email);
}
