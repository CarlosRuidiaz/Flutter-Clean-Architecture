import 'package:f_clean_template/core/app_catalogs.dart';
import 'package:f_clean_template/core/app_theme.dart';
import 'package:f_clean_template/features/auth/domain/models/authentication_user.dart';
import 'package:f_clean_template/features/auth/domain/repositories/i_auth_repository.dart';
import 'package:f_clean_template/features/auth/ui/viewmodels/authentication_controller.dart';
import 'package:f_clean_template/features/auth/ui/views/signup_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

import 'fake_auth_repository.dart';

/// Apunta lo que se le manda a `register`, que es lo unico que importa aqui:
/// la cuenta se crea una sola vez, al final, y con el perfil dentro.
class _RepositorioQueApunta extends FakeAuthRepository {
  final List<AuthenticationUser> registrados = [];

  @override
  Future<bool> signUp(AuthenticationUser user) async {
    registrados.add(user);
    return true;
  }

  @override
  Future<bool> restoreSession() async => false;
}

Future<_RepositorioQueApunta> _abrirRegistro(WidgetTester tester) async {
  Get.testMode = true;
  await Get.deleteAll(force: true);

  tester.view.physicalSize = const Size(1400, 4000);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);

  final repository = _RepositorioQueApunta();
  Get.put<IAuthRepository>(repository);
  Get.put(AuthenticationController(Get.find<IAuthRepository>()));

  await tester.pumpWidget(
    GetMaterialApp(theme: AppTheme.light, home: const SignUpPage()),
  );
  await tester.pumpAndSettle();
  return repository;
}

Future<void> _llenarPaso1(
  WidgetTester tester, {
  String correo = 'ana@uninorte.edu.co',
  String clave = 'UnaClaveLarga1',
  String? confirmacion,
}) async {
  await tester.enterText(find.byType(TextFormField).at(0), correo);
  await tester.enterText(find.byType(TextFormField).at(1), clave);
  await tester.enterText(find.byType(TextFormField).at(2), confirmacion ?? clave);
  await tester.pumpAndSettle();
}

void main() {
  tearDown(() => Get.deleteAll(force: true));

  group('Registro en dos pasos', () {
    testWidgets('el paso 1 solo pide credenciales', (tester) async {
      await _abrirRegistro(tester);

      expect(find.text('Paso 1 de 2'), findsOneWidget);
      expect(find.text('Correo institucional'), findsOneWidget);
      expect(find.text('Contraseña'), findsOneWidget);
      // Nada del perfil todavia.
      expect(find.text('Nombre completo'), findsNothing);
      expect(find.text(AppCatalogs.programSystems), findsNothing);
      expect(find.text('Sobre ti (opcional)'), findsNothing);
    });

    testWidgets('el paso 1 no crea la cuenta: solo lleva al paso 2',
        (tester) async {
      final repository = await _abrirRegistro(tester);
      await _llenarPaso1(tester);

      await tester.tap(find.widgetWithText(ElevatedButton, 'Continuar'));
      await tester.pumpAndSettle();

      // extra solo se envia al registrarse: registrar aqui dejaria la cuenta
      // sin perfil para siempre.
      expect(repository.registrados, isEmpty);
      expect(find.text('Completa tu perfil'), findsOneWidget);
      expect(find.text('Paso 2 de 2'), findsOneWidget);
    });

    testWidgets('un correo de fuera no pasa del paso 1', (tester) async {
      await _abrirRegistro(tester);
      await _llenarPaso1(tester, correo: 'ana@gmail.com');

      await tester.tap(find.widgetWithText(ElevatedButton, 'Continuar'));
      await tester.pumpAndSettle();

      expect(find.textContaining('@uninorte.edu.co'), findsWidgets);
      expect(find.text('Completa tu perfil'), findsNothing);
    });

    testWidgets('las contrasenas que no coinciden no pasan del paso 1',
        (tester) async {
      await _abrirRegistro(tester);
      await _llenarPaso1(tester, confirmacion: 'OtraClaveLarga1');

      await tester.tap(find.widgetWithText(ElevatedButton, 'Continuar'));
      await tester.pumpAndSettle();

      expect(find.text('Las contraseñas no coinciden'), findsOneWidget);
      expect(find.text('Completa tu perfil'), findsNothing);
    });

    testWidgets('el registro se manda entero al terminar el paso 2',
        (tester) async {
      final repository = await _abrirRegistro(tester);
      await _llenarPaso1(tester);
      await tester.tap(find.widgetWithText(ElevatedButton, 'Continuar'));
      await tester.pumpAndSettle();

      // Sin programa ni habilidades el boton esta deshabilitado.
      final botonAntes = tester.widget<ElevatedButton>(
        find.widgetWithText(ElevatedButton, 'Crear cuenta'),
      );
      expect(botonAntes.onPressed, isNull);

      await tester.enterText(find.byType(TextFormField).at(0), 'Ana García');
      await tester.enterText(
        find.byType(TextFormField).at(1),
        'Me interesa la movilidad urbana.',
      );
      await tester.tap(find.text(AppCatalogs.programSystems));
      await tester.tap(find.text(AppCatalogs.skillPython));
      await tester.tap(find.text(AppCatalogs.skillUx));
      await tester.tap(find.byIcon(Icons.add));
      await tester.pumpAndSettle();

      await tester.tap(find.widgetWithText(ElevatedButton, 'Crear cuenta'));
      await tester.pumpAndSettle();

      // Una sola llamada, con credenciales y perfil juntos.
      final enviado = repository.registrados.single;
      expect(enviado.email, 'ana@uninorte.edu.co');
      expect(enviado.password, 'UnaClaveLarga1');
      expect(enviado.name, 'Ana García');
      expect(enviado.academicProgram, AppCatalogs.programSystems);
      expect(enviado.semester, 2);
      expect(enviado.skills, [AppCatalogs.skillPython, AppCatalogs.skillUx]);
      expect(enviado.bio, 'Me interesa la movilidad urbana.');
    });

    testWidgets('la biografia es opcional', (tester) async {
      final repository = await _abrirRegistro(tester);
      await _llenarPaso1(tester);
      await tester.tap(find.widgetWithText(ElevatedButton, 'Continuar'));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextFormField).at(0), 'Ana García');
      await tester.tap(find.text(AppCatalogs.programPsychology));
      await tester.tap(find.text(AppCatalogs.skillResearch));
      await tester.pumpAndSettle();

      await tester.tap(find.widgetWithText(ElevatedButton, 'Crear cuenta'));
      await tester.pumpAndSettle();

      expect(repository.registrados.single.bio, isEmpty);
    });
  });
}
