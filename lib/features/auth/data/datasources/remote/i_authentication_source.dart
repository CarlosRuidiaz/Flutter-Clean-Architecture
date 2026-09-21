import '../../../domain/models/authentication_user.dart';

abstract class IAuthenticationSource {
  /// Emite cada vez que la sesion cambia: true al entrar, false al salir.
  ///
  /// Existe para que quien cachea datos del usuario se entere de que ahora hay
  /// otra persona. Sin esto, cerrar sesion y entrar con otra cuenta deja el
  /// perfil anterior pegado en pantalla.
  Stream<bool> get sessionChanges;

  Future<bool> login(AuthenticationUser user);

  Future<bool> restoreSession();

  Future<AuthenticationUser?> getLoggedUser();

  Future<bool> signUp(AuthenticationUser user);

  Future<bool> logOut();

  Future<bool> validate(String email, String validationCode);

  Future<bool> refreshToken();

  Future<bool> forgotPassword(String email);

  Future<bool> resetPassword(
    String email,
    String newPassword,
    String validationCode,
  );

  Future<bool> verifyToken();
}
