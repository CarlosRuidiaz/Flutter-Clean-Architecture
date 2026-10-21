import 'package:f_clean_template/core/app_catalogs.dart';
import 'package:f_clean_template/features/auth/ui/viewmodels/authentication_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'app_de_prueba.dart';
import 'ayudas.dart';
import 'fakes/fake_authentication_source.dart';

const String _contrasenaValida = 'MiClave!1';

/// Del login al paso 1 del registro, con las credenciales ya escritas.
Future<void> _escribirCredenciales(
  WidgetTester tester, {
  required String email,
  String contrasena = _contrasenaValida,
}) async {
  await escribir(tester, 'TextFormFieldSignUpEmail', email);
  await escribir(tester, 'TextFormFieldSignUpPassword', contrasena);
  await escribir(tester, 'TextFormFieldSignUpPasswordConfirm', contrasena);
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Flujo: crear usuario', () {
    testWidgets('un correo que no es institucional no avanza, y uno '
        'institucional crea la cuenta y entra a la app', (tester) async {
      final auth = await arrancarAppDePrueba(tester);

      // 1. La app abre en el login y desde ahi se llega al registro.
      expect(porLlave('LoginPage'), findsOneWidget);
      await tocar(tester, porLlave('ButtonLoginCreateAccount'));
      expect(porLlave('SignUpPage'), findsOneWidget);

      // 2. Con un correo de fuera no pasa del paso 1.
      await _escribirCredenciales(tester, email: 'estudiante@gmail.com');
      await tocar(tester, porLlave('ButtonSignUpContinue'));
      expect(porLlave('SignUpPage'), findsOneWidget);
      expect(porLlave('CompleteProfilePage'), findsNothing);
      expect(
        find.text(
          'Usa tu correo ${AuthenticationController.dominioInstitucional}',
        ),
        findsOneWidget,
      );

      // 3. Con correo institucional y contrasena valida, llega al paso 2.
      const email = 'nuevo.estudiante@uninorte.edu.co';
      await _escribirCredenciales(tester, email: email);
      await tocar(tester, porLlave('ButtonSignUpContinue'));
      expect(porLlave('CompleteProfilePage'), findsOneWidget);

      // Sin programa ni habilidades todavia no se puede crear la cuenta.
      expect(
        tester
            .widget<ElevatedButton>(porLlave('ButtonProfileSubmit'))
            .onPressed,
        isNull,
      );

      // 4. Llena el perfil: nombre, programa, semestre, habilidades y bio.
      await escribir(tester, 'TextFormFieldProfileName', 'Nuevo Estudiante');
      await tocar(
        tester,
        find.descendant(
          of: porLlave('FieldProfileProgram'),
          matching: find.text(AppCatalogs.programSystems),
        ),
      );
      // El semestre arranca en 1: tres toques en "+" lo dejan en 4.
      for (var i = 0; i < 3; i++) {
        await tocar(
          tester,
          find.descendant(
            of: porLlave('FieldProfileSemester'),
            matching: find.byIcon(Icons.add),
          ),
        );
      }
      await tocar(tester, porLlave('ChipProfileSkill-${AppCatalogs.skillWeb}'));
      await tocar(
        tester,
        porLlave('ChipProfileSkill-${AppCatalogs.skillPython}'),
      );
      await escribir(
        tester,
        'TextFormFieldProfileBio',
        'Me interesa la movilidad sostenible.',
      );

      expect(
        tester
            .widget<ElevatedButton>(porLlave('ButtonProfileSubmit'))
            .onPressed,
        isNotNull,
      );
      await tocar(tester, porLlave('ButtonProfileSubmit'));

      // 5. La cuenta queda creada, con la sesion abierta, y llega al inicio.
      expect(porLlave('HomePage'), findsOneWidget);
      expect(porLlave('CompleteProfilePage'), findsNothing);
      expect(porLlave('LoginPage'), findsNothing);

      final cuenta = auth.cuentaDe(email);
      expect(cuenta, isNotNull);
      expect(cuenta!.name, 'Nuevo Estudiante');
      expect(cuenta.academicProgram, AppCatalogs.programSystems);
      expect(cuenta.semester, 4);
      expect(cuenta.skills, [AppCatalogs.skillWeb, AppCatalogs.skillPython]);
      expect(cuenta.bio, 'Me interesa la movilidad sostenible.');
      expect(auth.cuentaConSesion?.id, cuenta.id);
    });

    testWidgets('un correo que ya tiene cuenta no crea otra y se queda en el '
        'paso 2 con un mensaje', (tester) async {
      final auth = await arrancarAppDePrueba(
        tester,
        usuarios: const [
          UsuarioSembrado(
            email: 'ana.perez@uninorte.edu.co',
            password: 'Clave!2026',
            name: 'Ana Pérez',
            academicProgram: AppCatalogs.programSystems,
            semester: 5,
            skills: [AppCatalogs.skillWeb],
          ),
        ],
      );

      await tocar(tester, porLlave('ButtonLoginCreateAccount'));
      await _escribirCredenciales(tester, email: 'Ana.Perez@uninorte.edu.co');
      await tocar(tester, porLlave('ButtonSignUpContinue'));
      expect(porLlave('CompleteProfilePage'), findsOneWidget);

      await escribir(tester, 'TextFormFieldProfileName', 'Otra Ana');
      await tocar(
        tester,
        find.descendant(
          of: porLlave('FieldProfileProgram'),
          matching: find.text(AppCatalogs.programBusiness),
        ),
      );
      await tocar(tester, porLlave('ChipProfileSkill-${AppCatalogs.skillData}'));
      await tocar(tester, porLlave('ButtonProfileSubmit'));

      // No entra a la app, avisa, y la cuenta de antes sigue siendo una sola.
      expect(porLlave('CompleteProfilePage'), findsOneWidget);
      expect(porLlave('HomePage'), findsNothing);
      expect(
        find.text('No se pudo crear la cuenta. Intentalo de nuevo.'),
        findsOneWidget,
      );
      expect(auth.cuentas, hasLength(1));
      expect(auth.cuentaConSesion, isNull);
    });
  });
}
