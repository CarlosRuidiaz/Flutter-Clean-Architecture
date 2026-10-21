import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:f_clean_template/core/app_catalogs.dart';
import 'package:f_clean_template/core/app_routes.dart';
import 'package:f_clean_template/core/app_theme.dart';
import 'package:f_clean_template/features/application/data/datasources/local/local_application_source.dart';
import 'package:f_clean_template/features/application/data/repositories/application_repository.dart';
import 'package:f_clean_template/features/application/domain/repositories/i_application_repository.dart';
import 'package:f_clean_template/features/auth/domain/repositories/i_auth_repository.dart';
import 'package:f_clean_template/features/my_projects/ui/viewmodels/my_projects_controller.dart';
import 'package:f_clean_template/features/profile/data/datasources/local/local_profile_source.dart';
import 'package:f_clean_template/features/profile/data/repositories/profile_repository.dart';
import 'package:f_clean_template/features/profile/domain/repositories/i_profile_repository.dart';
import 'package:f_clean_template/features/profile/ui/viewmodels/profile_controller.dart';
import 'package:f_clean_template/features/project/data/datasources/local/local_project_source.dart';
import 'package:f_clean_template/features/project/data/repositories/project_repository.dart';
import 'package:f_clean_template/features/project/domain/repositories/i_project_repository.dart';
import 'package:f_clean_template/features/project/ui/viewmodels/project_controller.dart';
import 'package:f_clean_template/features/project/ui/views/home_page.dart';
import 'package:f_clean_template/features/project/ui/views/widgets/project_card.dart';

import '../auth/fake_auth_repository.dart';
import '../seguir_y_encuestas_de_prueba.dart';

Future<ProjectController> _montar(
  WidgetTester tester, {
  required FakeAuthRepository authRepo,
}) async {
  Get.testMode = true;
  await Get.deleteAll(force: true);

  tester.view.physicalSize = const Size(1200, 4000);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);

  Get.put<IAuthRepository>(authRepo);
  Get.put<IProfileRepository>(ProfileRepository(LocalProfileSource()));
  Get.put(ProfileController(Get.find(), authRepo));
  Get.put<IProjectRepository>(ProjectRepository(LocalProjectSource()));
  Get.put<IApplicationRepository>(
    ApplicationRepository(LocalApplicationSource()),
  );
  Get.put(
    MyProjectsController(Get.find(), Get.find(), Get.find(), Get.find()),
  );
  final controller = Get.put(
    ProjectController(Get.find(), Get.find(), authRepo),
  );
  registrarSeguirYEncuestas(
    auth: authRepo,
    perfiles: Get.find(),
    proyectos: Get.find(),
    postulaciones: Get.find(),
  );

  await tester.pumpWidget(
    GetMaterialApp(
      theme: AppTheme.light,
      home: const HomePage(),
      getPages: AppRoutes.pages,
    ),
  );
  await tester.pumpAndSettle();
  await tester.tap(find.text('Explorar proyectos').first);
  await tester.pumpAndSettle();
  return controller;
}

void main() {
  tearDown(() => Get.deleteAll(force: true));

  group('Filtro por tags en la cartelera', () {
    testWidgets('Pantalla de filtros tiene grupo Categoría y filtra la lista',
        (tester) async {
      final auth = FakeAuthRepository();
      final controller = await _montar(tester, authRepo: auth);

      // Abrir filtros
      await tester.tap(find.widgetWithText(OutlinedButton, 'Filtros'));
      await tester.pumpAndSettle();

      // Debe estar el grupo con título Categoría
      expect(find.byKey(const ValueKey('grupo-categorias')), findsOneWidget);
      expect(find.text('Categoría'), findsOneWidget);

      // Marcar el tag de Educación y aplicar
      await tester.tap(find.text(AppCatalogs.tagEducation).last);
      await tester.pumpAndSettle();

      expect(find.text('Aplicar 1 filtro'), findsOneWidget);
      await tester.tap(find.widgetWithText(ElevatedButton, 'Aplicar 1 filtro'));
      await tester.pumpAndSettle();

      // De vuelta en la cartelera, debe mostrar el botón con contador de filtros
      expect(find.widgetWithText(OutlinedButton, 'Filtros (1)'), findsOneWidget);
      expect(controller.tagFilters.contains(AppCatalogs.tagEducation), isTrue);

      // Tarjetas mostradas tienen que coincidir con el tag aplicado
      final cards = tester.widgetList<ProjectCard>(find.byType(ProjectCard));
      for (final card in cards) {
        expect(card.project.tags.contains(AppCatalogs.tagEducation), isTrue);
      }
    });
  });
}
