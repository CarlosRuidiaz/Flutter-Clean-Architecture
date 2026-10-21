import 'package:integration_test/integration_test.dart';

import 'crear_proyecto_test.dart' as crear_proyecto;
import 'crear_usuario_test.dart' as crear_usuario;
import 'login_test.dart' as login;

/// Los tres flujos en una sola ejecucion: es lo que corre `flutter test` en el
/// emulador y `flutter drive` en Chrome.
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  crear_usuario.main();
  login.main();
  crear_proyecto.main();
}
