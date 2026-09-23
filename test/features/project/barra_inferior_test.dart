import 'package:f_clean_template/core/app_routes.dart';
import 'package:f_clean_template/core/app_theme.dart';
import 'package:f_clean_template/features/application/data/datasources/local/local_application_source.dart';
import 'package:f_clean_template/features/application/data/repositories/application_repository.dart';
import 'package:f_clean_template/features/application/domain/repositories/i_application_repository.dart';
import 'package:f_clean_template/features/auth/domain/repositories/i_auth_repository.dart';
import 'package:f_clean_template/features/auth/ui/viewmodels/authentication_controller.dart';
import 'package:f_clean_template/features/my_projects/ui/viewmodels/my_projects_controller.dart';
import 'package:f_clean_template/features/profile/data/datasources/i_profile_source.dart';
import 'package:f_clean_template/features/profile/data/datasources/local/local_profile_source.dart';
import 'package:f_clean_template/features/profile/data/repositories/profile_repository.dart';
import 'package:f_clean_template/features/profile/domain/repositories/i_profile_repository.dart';
import 'package:f_clean_template/features/profile/ui/viewmodels/profile_controller.dart';
import 'package:f_clean_template/features/project/data/datasources/i_project_source.dart';
import 'package:f_clean_template/features/project/data/datasources/local/local_project_source.dart';
import 'package:f_clean_template/features/project/data/repositories/project_repository.dart';
import 'package:f_clean_template/features/project/domain/repositories/i_project_repository.dart';
import 'package:f_clean_template/features/project/ui/viewmodels/project_controller.dart';
import 'package:f_clean_template/features/project/ui/views/home_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

import '../auth/fake_auth_repository.dart';

/// Monta la cartelera completa con las fuentes locales.
Future<void> _montarHome(WidgetTester tester) async {
  Get.testMode = true;
  await Get.deleteAll(force: true);

  tester.view.physicalSize = const Size(1200, 4000);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);

  final authRepo = FakeAuthRepository();
  Get.put<IAuthRepository>(authRepo);
  Get.put(AuthenticationController(authRepo));
  Get.put<IProfileSource>(LocalProfileSource());
  Get.put<IProfileRepository>(ProfileRepository(Get.find()));
  Get.put(ProfileController(Get.find(), authRepo));
  Get.put<IProjectSource>(LocalProjectSource());
  Get.put<IProjectRepository>(ProjectRepository(Get.find()));
  Get.put<IApplicationRepository>(
      ApplicationRepository(LocalApplicationSource()));
  Get.put(MyProjectsController(
      Get.find(), Get.find(), Get.find(), Get.find()));
  Get.put(ProjectController(Get.find(), Get.find(), authRepo));

  await tester.pumpWidget(
    GetMaterialApp(
      theme: AppTheme.light,
      home: const HomePage(),
      getPages: AppRoutes.pages,
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  tearDown(() => Get.deleteAll(force: true));

  group('Barra inferior', () {
    testWidgets('arranca en la cartelera', (tester) async {
      await _montarHome(tester);

      // La cartelera tiene la pestaña "Para tus habilidades".
      expect(find.text('Para tus habilidades'), findsOneWidget);
    });

    testWidgets('los cinco destinos están visibles', (tester) async {
      await _montarHome(tester);

      expect(find.text('Inicio'), findsOneWidget);
      expect(find.text('Mis proyectos'), findsWidgets); // tab + nav bar
      expect(find.text('Crear'), findsOneWidget);
      expect(find.text('Notificaciones'), findsWidgets); // title + nav bar
      expect(find.text('Perfil'), findsWidgets); // title + nav bar
    });

    testWidgets('"Crear" no cambia de pestaña', (tester) async {
      await _montarHome(tester);

      // La cartelera sigue visible después de tocar "Crear".
      await tester.tap(find.text('Crear'));
      await tester.pumpAndSettle();

      // Seguimos en la cartelera (el IndexedStack sigue en index 0).
      expect(find.text('Para tus habilidades'), findsOneWidget);
    });

    testWidgets('el IndexedStack conserva el estado al ir y volver',
        (tester) async {
      await _montarHome(tester);

      // Ir a "Mis proyectos".
      await tester.tap(find.text('Mis proyectos').last);
      await tester.pumpAndSettle();

      expect(find.text('Creados por mí'), findsOneWidget);

      // Ir a "Perfil".
      await tester.tap(find.text('Perfil').last);
      await tester.pumpAndSettle();

      // Volver a "Mis proyectos": la pestaña sigue donde estaba.
      await tester.tap(find.text('Mis proyectos').last);
      await tester.pumpAndSettle();

      expect(find.text('Creados por mí'), findsOneWidget);
    });
  });
}
