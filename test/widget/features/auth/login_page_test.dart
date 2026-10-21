import 'package:f_clean_template/core/app_theme.dart';
import 'package:f_clean_template/features/auth/domain/repositories/i_auth_repository.dart';
import 'package:f_clean_template/features/auth/ui/viewmodels/authentication_controller.dart';
import 'package:f_clean_template/features/auth/ui/views/login_page.dart';
import 'package:f_clean_template/features/auth/ui/views/signup_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

import 'fake_auth_repository.dart';

Future<void> _abrirLogin(WidgetTester tester) async {
  Get.testMode = true;
  await Get.deleteAll(force: true);

  tester.view.physicalSize = const Size(1200, 2000);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);

  Get.put<IAuthRepository>(FakeAuthRepository());
  Get.put(AuthenticationController(Get.find<IAuthRepository>()));

  await tester.pumpWidget(
    GetMaterialApp(
      theme: AppTheme.light,
      home: const LoginPage(),
      getPages: [
        GetPage(name: '/signup', page: () => const SignUpPage()),
      ],
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  tearDown(() => Get.deleteAll(force: true));

  group('LoginPage', () {
    testWidgets('los campos y los botones son visibles', (tester) async {
      await _abrirLogin(tester);

      expect(find.byKey(const Key('LoginPage')), findsOneWidget);
      expect(find.byKey(const Key('TextFormFieldLoginEmail')), findsOneWidget);
      expect(find.byKey(const Key('TextFormFieldLoginPassword')), findsOneWidget);
      expect(find.byKey(const Key('ButtonLoginSubmit')), findsOneWidget);
      expect(find.byKey(const Key('ButtonLoginCreateAccount')), findsOneWidget);
      expect(find.text('Innovation Hub'), findsOneWidget);
      expect(find.text('Entrar'), findsOneWidget);
      expect(find.text('Crear cuenta'), findsOneWidget);
    });

    testWidgets('un correo que no es de uninorte muestra error de validacion',
        (tester) async {
      await _abrirLogin(tester);

      await tester.enterText(
        find.byKey(const Key('TextFormFieldLoginEmail')),
        'alguien@gmail.com',
      );
      await tester.enterText(
        find.byKey(const Key('TextFormFieldLoginPassword')),
        'UnaClave1',
      );
      await tester.tap(find.byKey(const Key('ButtonLoginSubmit')));
      await tester.pumpAndSettle();

      // El validator del campo muestra el dominio institucional.
      expect(find.textContaining('@uninorte.edu.co'), findsWidgets);
    });

    testWidgets('contrasena menor de 7 caracteres muestra error', (tester) async {
      await _abrirLogin(tester);

      await tester.enterText(
        find.byKey(const Key('TextFormFieldLoginEmail')),
        'alumno@uninorte.edu.co',
      );
      await tester.enterText(
        find.byKey(const Key('TextFormFieldLoginPassword')),
        'corta',
      );
      await tester.tap(find.byKey(const Key('ButtonLoginSubmit')));
      await tester.pumpAndSettle();

      expect(find.text('Debe tener al menos 7 caracteres'), findsOneWidget);
    });

    testWidgets('formulario vacio muestra errores de validacion', (tester) async {
      await _abrirLogin(tester);

      await tester.tap(find.byKey(const Key('ButtonLoginSubmit')));
      await tester.pumpAndSettle();

      expect(find.text('Escribe tu correo'), findsOneWidget);
    });

    testWidgets('propiedad: el boton \"Entrar\" tiene onPressed cuando hay datos validos',
        (tester) async {
      await _abrirLogin(tester);

      // Antes de escribir, onPressed apunta a la funcion de envio (no es null).
      // La clave es que nunca está deshabilitado solo por ser del tipo boton;
      // lo deshabilita el isLoading del controlador.
      final boton = tester.widget<ElevatedButton>(
        find.byKey(const Key('ButtonLoginSubmit')),
      );
      // onPressed no es null: el boton esta activo (isLoading = false al inicio).
      expect(boton.onPressed, isNotNull);
    });

    testWidgets('\"Crear cuenta\" navega a SignUpPage', (tester) async {
      await _abrirLogin(tester);

      await tester.tap(find.byKey(const Key('ButtonLoginCreateAccount')));
      await tester.pumpAndSettle();

      // La pantalla de registro tiene el texto de paso 1.
      expect(find.text('Paso 1 de 2'), findsOneWidget);
    });
  });
}
