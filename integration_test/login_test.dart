import 'package:f_clean_template/core/app_catalogs.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'app_de_prueba.dart';
import 'ayudas.dart';
import 'fakes/fake_authentication_source.dart';

const String _email = 'ana.perez@uninorte.edu.co';
const String _contrasena = 'Clave!2026';

const UsuarioSembrado _ana = UsuarioSembrado(
  email: _email,
  password: _contrasena,
  name: 'Ana Pérez',
  academicProgram: AppCatalogs.programSystems,
  semester: 5,
  skills: [AppCatalogs.skillWeb],
);

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Flujo: login y cierre de sesion', () {
    testWidgets('una contrasena incorrecta se queda en el login con un '
        'mensaje, y la correcta entra al inicio', (tester) async {
      final auth = await arrancarAppDePrueba(tester, usuarios: const [_ana]);

      expect(porLlave('LoginPage'), findsOneWidget);

      // 1. Contrasena incorrecta: no entra y avisa.
      await iniciarSesion(tester, email: _email, password: 'Otra!Clave9');
      expect(porLlave('LoginPage'), findsOneWidget);
      expect(porLlave('HomePage'), findsNothing);
      expect(find.text('No se pudo entrar. Revisa tus datos.'), findsOneWidget);
      expect(auth.cuentaConSesion, isNull);

      // 2. Contrasena correcta: entra al inicio.
      await iniciarSesion(tester, email: _email, password: _contrasena);
      expect(porLlave('HomePage'), findsOneWidget);
      expect(porLlave('LoginPage'), findsNothing);
      expect(auth.cuentaConSesion?.email, _email);
    });

    testWidgets('el perfil muestra a quien entro y cerrar sesion devuelve '
        'al login', (tester) async {
      final auth = await arrancarAppDePrueba(tester, usuarios: const [_ana]);

      await iniciarSesion(tester, email: _email, password: _contrasena);
      expect(porLlave('HomePage'), findsOneWidget);

      // 3. El perfil es el de la cuenta que inicio sesion.
      await tocar(tester, porLlave('NavPerfil'));
      expect(porLlave('ProfileView'), findsOneWidget);
      expect(find.text('Ana Pérez'), findsWidgets);

      // 4. Cerrar sesion pide confirmacion y luego vuelve al login.
      await tocar(tester, porLlave('ButtonLogout'));
      expect(porLlave('ButtonLogoutConfirm'), findsOneWidget);
      await tocar(tester, porLlave('ButtonLogoutConfirm'));

      expect(porLlave('LoginPage'), findsOneWidget);
      expect(porLlave('HomePage'), findsNothing);
      expect(auth.cuentaConSesion, isNull);
    });
  });
}
