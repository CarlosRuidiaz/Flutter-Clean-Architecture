import 'package:f_clean_template/core/app_catalogs.dart';
import 'package:f_clean_template/core/app_routes.dart';
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
import 'package:f_clean_template/features/project/ui/views/widgets/stage_chip.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../auth/fake_auth_repository.dart';
import 'package:get/get.dart';

/// Arranca en la cartelera, no en la pantalla de filtros: lo que se prueba es
/// el viaje entero, ida, seleccion y vuelta.
Future<ProjectController> _enExplorar(WidgetTester tester) async {
  Get.testMode = true;
  await Get.deleteAll(force: true);

  tester.view.physicalSize = const Size(1200, 4000);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);

  Get.put<IProfileSource>(LocalProfileSource());
  Get.put<IProfileRepository>(ProfileRepository(Get.find()));
  Get.put(ProfileController(Get.find(), FakeAuthRepository()));
  Get.put<IProjectSource>(LocalProjectSource());
  Get.put<IProjectRepository>(ProjectRepository(Get.find()));
  final controller = Get.put(ProjectController(Get.find(), Get.find(), FakeAuthRepository()));

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

Future<void> _abrirFiltros(WidgetTester tester) async {
  // Por el icono y no por el texto: con filtros puestos el boton dice
  // "Filtros (1)" y un buscador por texto exacto ya no lo encontraria.
  await tester.tap(find.byIcon(Icons.tune).first);
  await tester.pumpAndSettle();
}

int _tarjetas() => find.byType(ProjectCard).evaluate().length;

/// Acota la busqueda a un grupo. Hace falta porque "Investigación" es a la vez
/// una habilidad del catalogo y la traduccion de la etapa `research`.
Finder _en(String grupo, String texto) => find.descendant(
      of: find.byKey(ValueKey('grupo-$grupo')),
      matching: find.text(texto),
    );

void main() {
  tearDown(() => Get.deleteAll(force: true));

  group('ProjectFiltersPage', () {
    testWidgets('9 · "Filtros" abre una pantalla propia con los tres grupos',
        (tester) async {
      await _enExplorar(tester);
      await _abrirFiltros(tester);

      expect(find.text('Filtros'), findsWidgets);
      expect(find.text('Habilidades'), findsOneWidget);
      expect(find.text('Programa académico'), findsOneWidget);
      expect(find.text('Etapa del proyecto'), findsOneWidget);

      for (final skill in AppCatalogs.skills) {
        expect(_en('habilidades', skill), findsOneWidget);
      }
      for (final program in AppCatalogs.academicPrograms) {
        expect(_en('programas', program), findsOneWidget);
      }
      for (final stage in ProjectStage.values) {
        expect(_en('etapas', StageChip.labelOf(stage)), findsOneWidget);
      }

      // Sin nada marcado el boton sigue activo: aplicar cero limpia.
      expect(find.text('Aplicar filtros'), findsOneWidget);
      final boton = tester.widget<ElevatedButton>(
        find.widgetWithText(ElevatedButton, 'Aplicar filtros'),
      );
      expect(boton.onPressed, isNotNull);
    });

    testWidgets('10 · dos habilidades y un programa dicen "Aplicar 2 filtros"',
        (tester) async {
      await _enExplorar(tester);
      await _abrirFiltros(tester);

      await tester.tap(_en('habilidades', AppCatalogs.skillUx));
      await tester.pumpAndSettle();
      expect(find.text('Aplicar 1 filtro'), findsOneWidget);

      await tester.tap(_en('habilidades', AppCatalogs.skillResearch));
      await tester.pumpAndSettle();
      // Dos chips del mismo grupo siguen siendo un filtro.
      expect(find.text('Aplicar 1 filtro'), findsOneWidget);

      await tester.tap(_en('programas', AppCatalogs.programPsychology));
      await tester.pumpAndSettle();
      expect(find.text('Aplicar 2 filtros'), findsOneWidget);
    });

    testWidgets('11 · al aplicar se vuelve a la cartelera filtrada y el boton '
        'muestra el contador', (tester) async {
      final controller = await _enExplorar(tester);
      expect(_tarjetas(), 6);

      await _abrirFiltros(tester);
      await tester.tap(_en('programas', AppCatalogs.programPsychology));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(ElevatedButton, 'Aplicar 1 filtro'));
      await tester.pumpAndSettle();

      // De vuelta en la cartelera, ya filtrada.
      expect(find.text('Buscar proyectos...'), findsOneWidget);
      expect(_tarjetas(), 1);
      expect(find.text('Biblioteca digital accesible'), findsOneWidget);
      expect(controller.programFilters, [AppCatalogs.programPsychology]);
      expect(find.widgetWithText(OutlinedButton, 'Filtros (1)'), findsOneWidget);
    });

    testWidgets('12 · volver sin aplicar deja los filtros como estaban',
        (tester) async {
      final controller = await _enExplorar(tester);

      // Se parte de un filtro ya puesto, para comprobar que no se pierde.
      await _abrirFiltros(tester);
      await tester.tap(_en('etapas', StageChip.labelOf(ProjectStage.idea)));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(ElevatedButton, 'Aplicar 1 filtro'));
      await tester.pumpAndSettle();
      expect(controller.stageFilters, [ProjectStage.idea]);
      final int conFiltro = _tarjetas();

      // Ahora se entra, se toquetea y se sale con el boton de volver.
      await _abrirFiltros(tester);
      await tester.tap(_en('habilidades', AppCatalogs.skillUx));
      await tester.tap(_en('programas', AppCatalogs.programArchitecture));
      await tester.tap(_en('etapas', StageChip.labelOf(ProjectStage.finished)));
      await tester.pumpAndSettle();
      expect(find.text('Aplicar 3 filtros'), findsOneWidget);

      await tester.pageBack();
      await tester.pumpAndSettle();

      // Nada de lo tocado se aplico.
      expect(controller.stageFilters, [ProjectStage.idea]);
      expect(controller.skillFilters, isEmpty);
      expect(controller.programFilters, isEmpty);
      expect(controller.activeFilterCount, 1);
      expect(_tarjetas(), conFiltro);
    });

    testWidgets('13 · filtros sin coincidencias dan el estado vacio, y '
        '"Limpiar filtros" los quita', (tester) async {
      final controller = await _enExplorar(tester);

      await _abrirFiltros(tester);
      // Psicología no tiene ningun proyecto en etapa Idea.
      await tester.tap(_en('programas', AppCatalogs.programPsychology));
      await tester.tap(_en('etapas', StageChip.labelOf(ProjectStage.idea)));
      await tester.pumpAndSettle();
      await tester.tap(
        find.widgetWithText(ElevatedButton, 'Aplicar 2 filtros'),
      );
      await tester.pumpAndSettle();

      expect(_tarjetas(), 0);
      expect(find.text('Ningún proyecto coincide'), findsOneWidget);

      await tester.tap(find.widgetWithText(OutlinedButton, 'Limpiar filtros'));
      await tester.pumpAndSettle();

      expect(controller.activeFilterCount, 0);
      expect(_tarjetas(), 6);
      expect(find.widgetWithText(OutlinedButton, 'Filtros'), findsOneWidget);
    });

    testWidgets('marcar dos etapas suma, no cruza', (tester) async {
      await _enExplorar(tester);
      await _abrirFiltros(tester);

      await tester.tap(_en('etapas', StageChip.labelOf(ProjectStage.idea)));
      await tester.tap(_en('etapas', StageChip.labelOf(ProjectStage.finished)));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(ElevatedButton, 'Aplicar 1 filtro'));
      await tester.pumpAndSettle();

      expect(_tarjetas(), 2);
      expect(find.text('Plataforma de tutorías entre pares'), findsOneWidget);
      expect(find.text('Biblioteca digital accesible'), findsOneWidget);
    });
  });
}
