import 'package:f_clean_template/core/app_routes.dart';
import 'package:f_clean_template/core/app_theme.dart';
import 'package:f_clean_template/features/application/data/datasources/i_application_source.dart';
import 'package:f_clean_template/features/application/data/datasources/local/local_application_source.dart';
import 'package:f_clean_template/features/application/data/repositories/application_repository.dart';
import 'package:f_clean_template/features/application/domain/repositories/i_application_repository.dart';
import 'package:f_clean_template/features/management/ui/viewmodels/management_controller.dart';
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
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

/// Monta la pantalla 18 sobre las fuentes locales. El proyecto '2' es el unico
/// cuyo leaderId es '1', el perfil de prueba: por eso es el que se puede
/// gestionar.
Future<ManagementController> _montarGestion(
  WidgetTester tester, {
  String projectId = '2',
}) async {
  Get.testMode = true;
  await Get.deleteAll(force: true);

  tester.view.physicalSize = const Size(1200, 3000);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);

  Get.put<IProfileSource>(LocalProfileSource());
  Get.put<IProfileRepository>(ProfileRepository(Get.find()));
  Get.put(ProfileController(Get.find()));
  Get.put<IProjectSource>(LocalProjectSource());
  Get.put<IProjectRepository>(ProjectRepository(Get.find()));
  Get.put<IApplicationSource>(LocalApplicationSource());
  Get.put<IApplicationRepository>(ApplicationRepository(Get.find()));
  final controller = Get.put(
    ManagementController(
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

  // La pantalla recibe el proyecto por Get.arguments, asi que hay que llegar
  // por la ruta de verdad y no montandola a mano.
  Get.toNamed(AppRoutes.applicants, arguments: project);
  await tester.pumpAndSettle();
  return controller;
}

/// Crea un proyecto liderado por el perfil de prueba y sin postulaciones, para
/// poder ver el estado vacio: de los seis de prueba, el unico con leaderId '1'
/// ya tiene dos postulantes.
Future<String> _proyectoPropioSinPostulantes() async {
  final creado = await Get.find<IProjectRepository>().createProject(
    Project(
      title: 'Proyecto recien publicado',
      problem: 'Un problema',
      description: 'Una descripcion',
      stage: ProjectStage.idea,
      academicProgram: 'Ingeniería de Sistemas',
      currentMembers: 1,
      maxMembers: 4,
      skillsWanted: const ['Flutter'],
      leaderId: '1',
    ),
  );
  return creado.id!;
}

void main() {
  tearDown(() => Get.deleteAll(force: true));

  group('ApplicantsPage · gestion de postulantes', () {
    testWidgets('10 · lista las postulaciones con nombre, programa, semestre '
        'y habilidades', (tester) async {
      await _montarGestion(tester);

      expect(find.text('2 postulaciones pendientes'), findsOneWidget);
      expect(find.text('Mariana Pérez'), findsOneWidget);
      expect(find.text('Diseño Industrial · 7.º semestre'), findsOneWidget);
      expect(find.text('Felipe Gómez'), findsOneWidget);
      expect(find.text('Ingeniería de Sistemas · 5.º semestre'), findsOneWidget);
      // Las habilidades ofrecidas, cada una en su pildora.
      expect(find.text('Diseño UX'), findsOneWidget);
      expect(find.text('Investigación'), findsOneWidget);
      expect(find.text('Flutter'), findsOneWidget);
      // Iniciales, no foto.
      expect(find.text('MP'), findsOneWidget);
      expect(find.text('FG'), findsOneWidget);
    });

    testWidgets('11 · aceptar saca de pendientes y baja el contador',
        (tester) async {
      final controller = await _montarGestion(tester);
      expect(controller.pendingCount, 2);

      await tester.tap(find.widgetWithText(ElevatedButton, 'Aceptar').first);
      await tester.pumpAndSettle();

      expect(controller.pendingCount, 1);
      expect(find.text('1 postulaciones pendientes'), findsOneWidget);
      // Sigue en la lista, con su estado visible y sin botones.
      expect(find.text('Mariana Pérez'), findsOneWidget);
      expect(find.text('Aceptada'), findsOneWidget);
      expect(find.widgetWithText(ElevatedButton, 'Aceptar'), findsOneWidget);
    });

    testWidgets('12 · rechazar hace lo mismo y queda visible con su estado',
        (tester) async {
      final controller = await _montarGestion(tester);

      await tester.tap(find.widgetWithText(OutlinedButton, 'Rechazar').first);
      await tester.pumpAndSettle();

      expect(controller.pendingCount, 1);
      expect(find.text('Mariana Pérez'), findsOneWidget);
      expect(find.text('Rechazada'), findsOneWidget);
    });

    testWidgets('13 · cerrar reclutamiento pide confirmacion y deja de '
        'aceptar postulaciones', (tester) async {
      final controller = await _montarGestion(tester);
      expect(controller.project?.acceptsApplications, isTrue);

      await tester.tap(
        find.widgetWithText(ElevatedButton, 'Cerrar reclutamiento'),
      );
      await tester.pumpAndSettle();

      // La hoja de confirmacion, con su explicacion.
      expect(find.text('¿Cerrar el reclutamiento?'), findsOneWidget);
      expect(
        find.text('El proyecto dejará de recibir postulaciones nuevas.'),
        findsWidgets,
      );

      // Volver no cierra nada.
      await tester.tap(find.widgetWithText(OutlinedButton, 'Volver'));
      await tester.pumpAndSettle();
      expect(controller.project?.recruitmentOpen, isTrue);

      await tester.tap(
        find.widgetWithText(ElevatedButton, 'Cerrar reclutamiento'),
      );
      await tester.pumpAndSettle();
      await tester.tap(
        find.widgetWithText(ElevatedButton, 'Sí, cerrar reclutamiento'),
      );
      await tester.pumpAndSettle();

      expect(controller.project?.recruitmentOpen, isFalse);
      expect(controller.project?.acceptsApplications, isFalse);
      // El boton queda deshabilitado y con el texto en pasado.
      expect(find.text('Reclutamiento cerrado'), findsOneWidget);
      final boton = tester.widget<ElevatedButton>(
        find.widgetWithText(ElevatedButton, 'Reclutamiento cerrado'),
      );
      expect(boton.onPressed, isNull);
    });

    testWidgets('14 · aceptar hasta llenar el equipo deja el proyecto lleno',
        (tester) async {
      final controller = await _montarGestion(tester);
      expect(controller.project?.currentMembers, 2);
      expect(controller.project?.maxMembers, 4);

      await tester.tap(find.widgetWithText(ElevatedButton, 'Aceptar').first);
      await tester.pumpAndSettle();
      expect(controller.project?.currentMembers, 3);

      await tester.tap(find.widgetWithText(ElevatedButton, 'Aceptar').first);
      await tester.pumpAndSettle();

      expect(controller.project?.currentMembers, 4);
      expect(controller.project?.isFull, isTrue);
      expect(controller.project?.acceptsApplications, isFalse);
      expect(controller.pendingCount, 0);
      expect(find.text('0 postulaciones pendientes'), findsOneWidget);
    });

    testWidgets('el proyecto sin postulantes muestra el estado vacio',
        (tester) async {
      await _montarGestion(tester);
      final String nuevoId = await _proyectoPropioSinPostulantes();

      Get.back();
      await tester.pumpAndSettle();
      final Project propio =
          (await Get.find<IProjectRepository>().getProjects())
              .firstWhere((p) => p.id == nuevoId);
      Get.toNamed(AppRoutes.applicants, arguments: propio);
      await tester.pumpAndSettle();

      expect(find.text('0 postulaciones pendientes'), findsOneWidget);
      expect(find.text('Todavía no hay postulantes.'), findsOneWidget);
    });

    testWidgets('9 · quien no lidera el proyecto no puede gestionarlo',
        (tester) async {
      // El '1' lo lidera 'u3', no el perfil de prueba.
      await _montarGestion(tester, projectId: '1');

      expect(find.textContaining('No tienes permiso'), findsOneWidget);
      expect(find.text('Mariana Pérez'), findsNothing);
    });
  });
}
