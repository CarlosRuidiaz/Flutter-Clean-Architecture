import 'package:f_clean_template/core/app_theme.dart';
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
import 'package:f_clean_template/features/project/ui/views/home_page.dart';
import 'package:f_clean_template/features/project/ui/views/widgets/project_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

/// Monta la cartelera con las fuentes locales de verdad, no con dobles: lo que
/// se quiere comprobar es justamente que las dos pestanias muestran listas
/// distintas sobre los mismos seis proyectos de prueba.
Future<ProjectController> _montarCartelera(WidgetTester tester) async {
  Get.testMode = true;
  await Get.deleteAll(force: true);

  // Superficie alta a proposito: ListView.builder solo construye lo visible, y
  // estas pruebas cuentan tarjetas. En 600x800 cabrian tres.
  tester.view.physicalSize = const Size(1200, 4000);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);

  Get.put<IProfileSource>(LocalProfileSource());
  Get.put<IProfileRepository>(ProfileRepository(Get.find()));
  Get.put(ProfileController(Get.find()));
  Get.put<IProjectSource>(LocalProjectSource());
  Get.put<IProjectRepository>(ProjectRepository(Get.find()));
  final controller = Get.put(ProjectController(Get.find(), Get.find()));

  await tester.pumpWidget(
    GetMaterialApp(theme: AppTheme.light, home: const HomePage()),
  );
  await tester.pumpAndSettle();
  return controller;
}

Future<void> _irAExplorar(WidgetTester tester) async {
  await tester.tap(find.text('Explorar proyectos').first);
  await tester.pumpAndSettle();
}

int _tarjetas() => find.byType(ProjectCard).evaluate().length;

void main() {
  tearDown(() => Get.deleteAll(force: true));

  group('HomePage · la cartelera', () {
    testWidgets('1 · las dos pestanias muestran listas distintas',
        (tester) async {
      await _montarCartelera(tester);

      // El perfil de prueba tiene Investigación y Diseño UX: los proyectos
      // '1' y '6' piden alguna de las dos.
      final int enHabilidades = _tarjetas();
      await _irAExplorar(tester);
      final int enExplorar = _tarjetas();

      expect(enHabilidades, 2);
      expect(enExplorar, 6);
      expect(enHabilidades, isNot(enExplorar));
    });

    testWidgets('2 · "Para tus habilidades" solo muestra los que piden alguna',
        (tester) async {
      await _montarCartelera(tester);

      expect(find.text('App de movilidad sostenible'), findsOneWidget);
      expect(find.text('Biblioteca digital accesible'), findsOneWidget);
      // El '2' pide Desarrollo web y Gestión: ninguna es del perfil.
      expect(find.text('Plataforma de tutorías entre pares'), findsNothing);
    });

    testWidgets('3 · buscar por titulo filtra en las dos pestanias',
        (tester) async {
      await _montarCartelera(tester);

      await tester.enterText(find.byType(TextField).first, 'movilidad');
      await tester.pumpAndSettle();
      expect(_tarjetas(), 1);
      expect(find.text('App de movilidad sostenible'), findsOneWidget);

      await _irAExplorar(tester);
      // El filtro es del controlador, asi que la otra pestania ya lo tiene
      // puesto sin que nadie lo vuelva a escribir.
      expect(_tarjetas(), 1);
      expect(find.text('App de movilidad sostenible'), findsOneWidget);
    });

    testWidgets('4 · filtrar por etapa deja solo esa, y "Todas" las devuelve',
        (tester) async {
      await _montarCartelera(tester);
      await _irAExplorar(tester);
      expect(_tarjetas(), 6);

      await tester.tap(find.text('Idea').first);
      await tester.pumpAndSettle();
      expect(_tarjetas(), 1);
      expect(find.text('Plataforma de tutorías entre pares'), findsOneWidget);

      await tester.tap(find.text('Todas').first);
      await tester.pumpAndSettle();
      expect(_tarjetas(), 6);
    });

    testWidgets('5 · "Solo abiertos" esconde el lleno y el cerrado',
        (tester) async {
      await _montarCartelera(tester);
      await _irAExplorar(tester);

      await tester.tap(find.text('Solo abiertos a postulación').first);
      await tester.pumpAndSettle();

      // Se caen el '4' (5 de 5, lleno) y el '6' (reclutamiento cerrado).
      expect(_tarjetas(), 4);
      expect(find.text('Red comunitaria de reciclaje textil'), findsNothing);
      expect(find.text('Biblioteca digital accesible'), findsNothing);
    });

    testWidgets('6 · cuando un filtro no deja nada sale el estado vacio',
        (tester) async {
      await _montarCartelera(tester);
      await _irAExplorar(tester);

      await tester.enterText(find.byType(TextField).first, 'zzzz');
      await tester.pumpAndSettle();

      expect(_tarjetas(), 0);
      expect(find.text('Ningún proyecto pasa los filtros'), findsOneWidget);

      await tester.tap(find.widgetWithText(OutlinedButton, 'Limpiar filtros'));
      await tester.pumpAndSettle();
      expect(_tarjetas(), 6);
    });

    testWidgets(
        '6b · el estado vacio de habilidades lleva a "Explorar proyectos"',
        (tester) async {
      final controller = await _montarCartelera(tester);

      // Ningun proyecto en etapa Idea pide una habilidad del perfil.
      controller.setStageFilter(ProjectStage.idea);
      await tester.pumpAndSettle();
      expect(find.text('Ningún proyecto pide tus habilidades'), findsOneWidget);

      await tester.tap(find.widgetWithText(OutlinedButton, 'Explorar proyectos'));
      await tester.pumpAndSettle();

      // Ya en la otra pestania, con el mismo filtro de etapa puesto.
      expect(find.text('Plataforma de tutorías entre pares'), findsOneWidget);
    });

    testWidgets('7 y 8 · la idea nueva aparece de primera y en las dos si '
        'pide una habilidad del perfil', (tester) async {
      final controller = await _montarCartelera(tester);
      await _irAExplorar(tester);
      expect(_tarjetas(), 6);

      await controller.createProject(
        Project(
          title: 'Huerta urbana en la terraza',
          problem: 'La terraza del bloque B lleva tres anios sin uso.',
          description: 'Una huerta que abastezca la cafeteria.',
          stage: ProjectStage.idea,
          academicProgram: 'Ingeniería Ambiental',
          currentMembers: 1,
          maxMembers: 5,
          skillsWanted: const ['Diseño UX'],
          leaderId: '1',
        ),
      );
      await tester.pumpAndSettle();

      // 7: aparece sin reiniciar nada, y de primera.
      expect(_tarjetas(), 7);
      expect(
        tester.widget<ProjectCard>(find.byType(ProjectCard).first).project.title,
        'Huerta urbana en la terraza',
      );

      // 8: pide Diseño UX, que el perfil tiene, asi que tambien esta en la otra.
      await tester.tap(find.text('Para tus habilidades').first);
      await tester.pumpAndSettle();
      expect(_tarjetas(), 3);
      expect(find.text('Huerta urbana en la terraza'), findsOneWidget);
    });
  });
}
