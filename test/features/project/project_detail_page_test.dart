import 'package:f_clean_template/core/app_routes.dart';
import 'package:f_clean_template/core/app_theme.dart';
import 'package:f_clean_template/features/application/data/datasources/i_application_source.dart';
import 'package:f_clean_template/features/application/data/datasources/local/local_application_source.dart';
import 'package:f_clean_template/features/application/data/repositories/application_repository.dart';
import 'package:f_clean_template/features/application/domain/repositories/i_application_repository.dart';
import 'package:f_clean_template/features/application/ui/viewmodels/application_controller.dart';
import 'package:f_clean_template/features/profile/data/datasources/i_profile_source.dart';
import 'package:f_clean_template/features/profile/data/datasources/local/local_profile_source.dart';
import 'package:f_clean_template/features/profile/data/repositories/profile_repository.dart';
import 'package:f_clean_template/features/profile/domain/repositories/i_profile_repository.dart';
import 'package:f_clean_template/features/profile/ui/viewmodels/profile_controller.dart';
import 'package:f_clean_template/features/project/data/datasources/i_project_source.dart';
import 'package:f_clean_template/features/project/data/datasources/local/local_project_source.dart';
import 'package:f_clean_template/features/project/data/repositories/project_repository.dart';
import 'package:f_clean_template/features/project/domain/models/project.dart';
import 'package:f_clean_template/features/project/domain/repositories/i_project_repository.dart';
import 'package:f_clean_template/features/project/ui/viewmodels/project_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../auth/fake_auth_repository.dart';
import 'package:get/get.dart';

Future<void> _abrirDetalle(WidgetTester tester, String projectId) async {
  Get.testMode = true;
  await Get.deleteAll(force: true);

  tester.view.physicalSize = const Size(1200, 3000);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);

  Get.put<IProfileSource>(LocalProfileSource());
  Get.put<IProfileRepository>(ProfileRepository(Get.find()));
  Get.put(ProfileController(Get.find(), FakeAuthRepository()));
  Get.put<IProjectSource>(LocalProjectSource());
  Get.put<IProjectRepository>(ProjectRepository(Get.find()));
  Get.put(ProjectController(Get.find(), Get.find(), FakeAuthRepository()));
  Get.put<IApplicationSource>(LocalApplicationSource());
  Get.put<IApplicationRepository>(ApplicationRepository(Get.find()));
  Get.put(
    ApplicationController(
      Get.find<IApplicationRepository>(),
      Get.find<IProjectRepository>(),
    ),
  );

  final Project project = (await Get.find<IProjectRepository>().getProjects())
      .firstWhere((p) => p.id == projectId);

  await tester.pumpWidget(
    GetMaterialApp(
      theme: AppTheme.light,
      home: const Scaffold(),
      getPages: AppRoutes.pages,
    ),
  );
  await tester.pumpAndSettle();
  Get.toNamed(AppRoutes.projectDetail, arguments: project);
  await tester.pumpAndSettle();
}

void main() {
  tearDown(() => Get.deleteAll(force: true));

  group('ProjectDetailPage', () {
    testWidgets('9 · el boton de gestionar postulantes sale en el proyecto que '
        'uno lidera', (tester) async {
      // El '2' tiene leaderId '1', que es el perfil de prueba.
      await _abrirDetalle(tester, '2');

      expect(
        find.widgetWithText(OutlinedButton, 'Gestionar postulantes'),
        findsOneWidget,
      );
    });

    testWidgets('el lider no puede postularse a su propio proyecto',
        (tester) async {
      // El '2' tiene leaderId '1', el perfil de prueba, y sigue reclutando.
      await _abrirDetalle(tester, '2');

      expect(find.widgetWithText(ElevatedButton, 'Postularme'), findsNothing);
    });

    testWidgets('9 · y no sale en los que lidera otra persona', (tester) async {
      // El '5' lo lidera 'u4', y el perfil de prueba no se ha postulado a el.
      await _abrirDetalle(tester, '5');

      expect(
        find.widgetWithText(OutlinedButton, 'Gestionar postulantes'),
        findsNothing,
      );
      expect(find.widgetWithText(ElevatedButton, 'Postularme'), findsOneWidget);
    });

    testWidgets('14 · al llenarse el equipo el detalle deja de ofrecer '
        'Postularme', (tester) async {
      await _abrirDetalle(tester, '5');
      expect(find.text('2 de 4 miembros'), findsOneWidget);
      expect(find.widgetWithText(ElevatedButton, 'Postularme'), findsOneWidget);

      // Se llenan los dos cupos que faltan, como haria el lider al aceptar.
      final repository = Get.find<IProjectRepository>();
      await repository.addMember('5');
      await repository.addMember('5');
      await Get.find<ProjectController>().getProjects();
      await tester.pumpAndSettle();

      // El detalle lee la copia viva del controlador, no la foto del argumento.
      expect(find.text('4 de 4 miembros'), findsOneWidget);
      expect(find.widgetWithText(ElevatedButton, 'Postularme'), findsNothing);
    });

    testWidgets('el proyecto con reclutamiento cerrado tampoco ofrece '
        'Postularme', (tester) async {
      // El '6' nace con recruitmentOpen en false.
      await _abrirDetalle(tester, '6');

      expect(find.widgetWithText(ElevatedButton, 'Postularme'), findsNothing);
    });

    testWidgets('el boton de espacio de trabajo sale en el proyecto que uno '
        'lidera', (tester) async {
      // El '2' tiene leaderId '1', que es el perfil de prueba.
      await _abrirDetalle(tester, '2');
      await tester.pumpAndSettle();

      expect(
        find.widgetWithText(ElevatedButton, 'Espacio de trabajo'),
        findsOneWidget,
      );
    });

    testWidgets('y no sale para un visitante que ni lidera ni fue aceptado',
        (tester) async {
      // El '5' lo lidera 'u4', y el perfil de prueba no se ha postulado a el.
      await _abrirDetalle(tester, '5');
      await tester.pumpAndSettle();

      expect(
        find.widgetWithText(ElevatedButton, 'Espacio de trabajo'),
        findsNothing,
      );
    });
  });
}
