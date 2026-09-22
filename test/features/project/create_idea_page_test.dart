import 'package:f_clean_template/core/app_catalogs.dart';
import 'package:f_clean_template/core/error_message.dart';
import 'package:f_clean_template/core/app_routes.dart';
import 'package:f_clean_template/core/app_tokens.dart';
import 'package:f_clean_template/core/app_theme.dart';
import 'package:f_clean_template/core/widgets/pill.dart';
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
import 'package:f_clean_template/features/project/ui/views/create_idea_page.dart';
import 'package:f_clean_template/features/project/ui/views/widgets/stage_chip.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../auth/fake_auth_repository.dart';
import 'package:get/get.dart';
import 'package:roble/roble.dart';

/// Repositorio que responde como Roble con el payload malo: 400.
class _RepositorioQueFalla implements IProjectRepository {
  static const fallo = RobleApiHttpException(
    400,
    'Conversión inválida. Revisa los valores actuales de la columna.',
  );

  @override
  Future<List<Project>> getProjects() async => [];

  @override
  Future<Project> createProject(Project project) async => throw fallo;

  @override
  Future<void> closeRecruitment(String projectId) async {}

  @override
  Future<void> addMember(String projectId) async {}
}

Future<ProjectController> _abrirCrearIdea(
  WidgetTester tester, {
  IProjectRepository? repositorio,
}) async {
  Get.testMode = true;
  await Get.deleteAll(force: true);

  tester.view.physicalSize = const Size(1400, 4000);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);

  Get.put<IProfileSource>(LocalProfileSource());
  Get.put<IProfileRepository>(ProfileRepository(Get.find()));
  Get.put(ProfileController(Get.find(), FakeAuthRepository()));
  Get.put<IProjectSource>(LocalProjectSource());
  Get.put<IProjectRepository>(repositorio ?? ProjectRepository(Get.find()));
  final controller = Get.put(ProjectController(Get.find(), Get.find(), FakeAuthRepository()));

  await tester.pumpWidget(
    GetMaterialApp(
      theme: AppTheme.light,
      home: const CreateIdeaPage(),
      getPages: AppRoutes.pages,
    ),
  );
  await tester.pumpAndSettle();
  return controller;
}

/// El color de fondo con el que se pinto la pildora de [label].
Color _fondoDe(WidgetTester tester, String label) {
  final pill = tester.widget<Pill>(
    find.ancestor(of: find.text(label), matching: find.byType(Pill)).first,
  );
  return pill.background;
}

void main() {
  tearDown(() => Get.deleteAll(force: true));

  group('CreateIdeaPage · chips del catalogo', () {
    testWidgets('1 · las habilidades son chips del catalogo, no un campo de '
        'texto, y se marcan y desmarcan', (tester) async {
      await _abrirCrearIdea(tester);

      // Los siete del catalogo estan pintados.
      for (final skill in AppCatalogs.skills) {
        expect(find.text(skill), findsWidgets, reason: 'falta el chip $skill');
      }
      // Ya no hay campo de texto de habilidades: quedan los tres de la
      // seccion 01 y ninguno mas.
      expect(find.byType(TextField), findsNWidgets(3));

      expect(_fondoDe(tester, AppCatalogs.skillPython), AppColors.card);

      await tester.tap(find.text(AppCatalogs.skillPython).first);
      await tester.pumpAndSettle();
      expect(_fondoDe(tester, AppCatalogs.skillPython), AppColors.persimmon);

      // Volver a tocarlo lo desmarca.
      await tester.tap(find.text(AppCatalogs.skillPython).first);
      await tester.pumpAndSettle();
      expect(_fondoDe(tester, AppCatalogs.skillPython), AppColors.card);
    });

    testWidgets('2 · la etapa deja marcar solo una, con su color',
        (tester) async {
      await _abrirCrearIdea(tester);

      final String idea = StageChip.labelOf(ProjectStage.idea);
      final String pruebas = StageChip.labelOf(ProjectStage.testing);

      await tester.tap(find.text(idea).first);
      await tester.pumpAndSettle();
      expect(_fondoDe(tester, idea), StageChip.colorOf(ProjectStage.idea));

      // Marcar otra reemplaza a la anterior: seleccion unica.
      await tester.tap(find.text(pruebas).first);
      await tester.pumpAndSettle();
      expect(
        _fondoDe(tester, pruebas),
        StageChip.colorOf(ProjectStage.testing),
      );
      expect(_fondoDe(tester, idea), AppColors.card);
    });

    testWidgets('3 · los tags son chips de seleccion multiple',
        (tester) async {
      await _abrirCrearIdea(tester);

      for (final tag in AppCatalogs.tags) {
        expect(find.text(tag), findsWidgets, reason: 'falta el chip $tag');
      }

      await tester.tap(find.text(AppCatalogs.tagSocial).first);
      await tester.tap(find.text(AppCatalogs.tagCommunity).first);
      await tester.pumpAndSettle();

      // Los dos a la vez: multiple, no unica.
      expect(_fondoDe(tester, AppCatalogs.tagSocial), AppColors.petrol);
      expect(_fondoDe(tester, AppCatalogs.tagCommunity), AppColors.petrol);
    });

    testWidgets('4 · el contador sube al marcar el primer chip de habilidades',
        (tester) async {
      await _abrirCrearIdea(tester);

      // El programa academico sale del perfil, asi que ya cuenta uno.
      expect(find.text('1 de 6 campos obligatorios'), findsOneWidget);

      await tester.tap(find.text(AppCatalogs.skillUx).first);
      await tester.pumpAndSettle();

      expect(find.text('2 de 6 campos obligatorios'), findsOneWidget);
    });

    testWidgets('5 · al publicar, la idea entra de primera en la cartelera',
        (tester) async {
      final controller = await _abrirCrearIdea(tester);
      expect(controller.projects.length, 6);

      await tester.enterText(
        find.byType(TextField).at(0),
        'Huerta urbana en la terraza',
      );
      await tester.enterText(find.byType(TextField).at(1), 'Un problema real.');
      await tester.enterText(find.byType(TextField).at(2), 'Una descripcion.');
      await tester.tap(find.text(StageChip.labelOf(ProjectStage.idea)).first);
      await tester.tap(find.text(AppCatalogs.skillUx).first);
      await tester.pumpAndSettle();

      expect(find.text('6 de 6 campos obligatorios'), findsOneWidget);

      await tester.tap(find.widgetWithText(ElevatedButton, 'Publicar'));
      await tester.pumpAndSettle();

      expect(controller.projects.length, 7);
      final creado = controller.projects.first;
      expect(creado.title, 'Huerta urbana en la terraza');
      expect(creado.skillsWanted, [AppCatalogs.skillUx]);
      // El programa sale del perfil, asi que tambien esta en el catalogo.
      expect(AppCatalogs.academicPrograms, contains(creado.academicProgram));
    });

    testWidgets('si Roble rechaza la idea, se avisa y no se congela',
        (tester) async {
      final controller = await _abrirCrearIdea(
        tester,
        repositorio: _RepositorioQueFalla(),
      );

      await tester.enterText(find.byType(TextField).at(0), 'Huerta urbana');
      await tester.enterText(find.byType(TextField).at(1), 'Un problema real.');
      await tester.enterText(find.byType(TextField).at(2), 'Una descripcion.');
      await tester.tap(find.text(StageChip.labelOf(ProjectStage.idea)).first);
      await tester.tap(find.text(AppCatalogs.skillUx).first);
      await tester.pumpAndSettle();

      await tester.tap(find.widgetWithText(ElevatedButton, 'Publicar'));
      await tester.pumpAndSettle();

      // Sin excepcion suelta, el mensaje traducido en pantalla, y la persona
      // sigue en el formulario con lo que escribio.
      expect(tester.takeException(), isNull);
      expect(
        find.text(errorMessage(_RepositorioQueFalla.fallo)),
        findsOneWidget,
      );
      expect(find.text('Nueva idea de proyecto'), findsOneWidget);
      expect(find.text('Huerta urbana'), findsOneWidget);
      expect(controller.isLoading.value, isFalse);

      // El boton vuelve a estar disponible para reintentar.
      final boton = tester.widget<ElevatedButton>(
        find.widgetWithText(ElevatedButton, 'Publicar'),
      );
      expect(boton.onPressed, isNotNull);

      // Deja que el aviso se cierre solo, para no dejar temporizadores vivos.
      await tester.pump(const Duration(seconds: 5));
      await tester.pumpAndSettle();
    });
  });
}
