import 'package:f_clean_template/features/auth/domain/models/authentication_user.dart';
import 'package:f_clean_template/features/auth/domain/repositories/i_auth_repository.dart';
import 'package:get/get.dart';

import 'package:loggy/loggy.dart';

import '../../../../core/error_message.dart';

class AuthenticationController extends GetxController with UiLoggy {
  /// El enunciado pide credenciales institucionales: solo correos de la
  /// universidad entran.
  static const String dominioInstitucional = '@uninorte.edu.co';

  /// True si el correo es institucional. Se comprueba antes de salir a la red:
  /// el servidor lo aceptaria igual y tendriamos cuentas que no deberian
  /// existir.
  static bool esCorreoInstitucional(String email) =>
      email.trim().toLowerCase().endsWith(dominioInstitucional);

  final IAuthRepository repoAuthentication;
  final _logged = false.obs;
  final _loggedUser = Rxn<AuthenticationUser>();
  final _isLoading = false.obs;

  /// Empty while the latest authentication request completed successfully.
  final RxString error = ''.obs;

  AuthenticationController(this.repoAuthentication);

  bool get isLoading => _isLoading.value;
  bool get isLogged => _logged.value;
  String get loggedEmail => _loggedUser.value?.email ?? '';
  AuthenticationUser? get loggedUser => _loggedUser.value;

  @override
  void onInit() {
    super.onInit();
    _restoreSession();
  }

  Future<void> _restoreSession() async {
    try {
      _logged.value = await repoAuthentication.restoreSession();
      _loggedUser.value = _logged.value
          ? await repoAuthentication.getLoggedUser()
          : null;
    } catch (exception) {
      loggy.warning(
        'AuthenticationController: Could not restore session: $exception',
      );
      _logged.value = false;
      _loggedUser.value = null;
    }
  }

  Future<bool> login(String email, String password) async {
    loggy.debug('AuthenticationController: Login $email');
    error.value = '';
    if (!_validate(email, password)) {
      loggy.warning('AuthenticationController: Invalid email or password');
      error.value =
          'Escribe un correo valido y una contrasena de mas de 6 caracteres.';
      return false;
    }
    if (!esCorreoInstitucional(email)) {
      loggy.warning('AuthenticationController: correo no institucional');
      error.value = 'Usa tu correo institucional $dominioInstitucional.';
      return false;
    }
    _isLoading.value = true;
    try {
      final loggedIn = await repoAuthentication.login(
        AuthenticationUser(email: email, name: email, password: password),
      );
      _logged.value = loggedIn;
      _loggedUser.value = loggedIn
          ? await repoAuthentication.getLoggedUser()
          : null;
      if (!loggedIn) error.value = 'No se pudo entrar. Revisa tus datos.';
      return loggedIn;
    } catch (exception) {
      loggy.error('AuthenticationController: Login error $exception');
      error.value = errorMessage(exception);
      return false;
    } finally {
      _isLoading.value = false;
    }
  }

  Future<bool> signUp(
    String email,
    String password, {
    required String name,
    required String academicProgram,
    required int semester,
    required List<String> skills,
  }) async {
    loggy.debug('AuthenticationController: Sign Up $email');
    error.value = '';
    if (!_validate(email, password)) {
      loggy.warning('AuthenticationController: Invalid email or password');
      error.value =
          'Escribe un correo valido y una contrasena de mas de 6 caracteres.';
      return false;
    }
    if (!esCorreoInstitucional(email)) {
      loggy.warning('AuthenticationController: correo no institucional');
      error.value = 'Usa tu correo institucional $dominioInstitucional.';
      return false;
    }
    _isLoading.value = true;
    try {
      final created = await repoAuthentication.signUp(
        AuthenticationUser(
          email: email,
          name: name.trim().isEmpty ? email : name.trim(),
          password: password,
          academicProgram: academicProgram,
          semester: semester,
          skills: skills,
        ),
      );
      if (!created) {
        error.value = 'No se pudo crear la cuenta. Intentalo de nuevo.';
      } else {
        // register con autoLogin deja la sesion abierta: la app ya puede
        // entrar sin pasar por el login.
        _logged.value = true;
        _loggedUser.value = await repoAuthentication.getLoggedUser();
      }
      return created;
    } catch (exception) {
      loggy.error('AuthenticationController: Sign up error $exception');
      error.value = errorMessage(exception);
      return false;
    } finally {
      _isLoading.value = false;
    }
  }

  Future<bool> logOut() async {
    loggy.debug('AuthenticationController: Log Out');
    error.value = '';
    try {
      final loggedOut = await repoAuthentication.logOut();
      _logged.value = false;
      _loggedUser.value = null;
      if (!loggedOut) error.value = 'No se pudo cerrar sesion. Intentalo de nuevo.';
      return loggedOut;
    } catch (exception) {
      loggy.error('AuthenticationController: Logout error $exception');
      error.value = errorMessage(exception);
      // A failed remote request should not keep a user in a local session that
      // is no longer trustworthy.
      _logged.value = false;
      _loggedUser.value = null;
      return false;
    }
  }

  bool _validate(String email, String password) =>
      email.isNotEmpty && password.length > 6;
}
