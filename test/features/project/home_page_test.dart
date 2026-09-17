import 'package:f_clean_template/core/app_theme.dart';
import 'package:f_clean_template/core/app_catalogs.dart';
import 'package:f_clean_template/features/profile/data/datasources/i_profile_source.dart';
import 'package:f_clean_template/features/profile/data/datasources/local/local_profile_source.dart';
import 'package:f_clean_template/features/profile/data/repositories/profile_repository.dart';
import 'package:f_clean_template/features/profile/domain/models/profile.dart';
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

/// Perfil a medida para los dos estados vacios de la pestania de habilidades:
/// uno sin habilidades registradas y otro con una que nadie pide.
class _FakeProfileSource implements IProfileSource {
  _FakeProfileSource(this.skills);

  final List<String> skills;

  @override
  Future<Profile> getCurrentProfile() async => Profile(
        id: '1',
        fullName: 'Carlos Ruidíaz',
        academicProgram: AppCatalogs.programSystems,
        semester: 8,
        skills: skills,
      );
}

/// Monta la cartelera con las fuentes locales de verdad, no con dobles: lo que
/// se quiere comprobar es justamente que las dos pestanias muestran listas
/// distintas sobre los mismos seis proyectos de prueba.
Future<ProjectController> _montarCartelera(
  WidgetTester tester, {
  List<String>? skillsDelPerfil,
}) async {
  Get.testMode = true;
  await Get.deleteAll(force: true);

  // Superficie alta a proposito: ListView.builder solo construye lo visible, y
  // estas pruebas cuentan tarjetas. En 600x800 cabrian tres.
  tester.view.physicalSize = const Size(1200, 4000);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);

  Get.put<IProfileSource>(
    skillsDelPerfil == null
        ? LocalProfileSource()
        : _FakeProfileSource(skillsDelPerfil),
  );
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

    testWidgets('6 · "Para tus habilidades" no tiene buscador ni boton de '
        'filtros, y si la linea de criterio', (tester) async {
      await _montarCartelera(tester);

      expect(find.byType(TextField), findsNothing);
      expect(find.widgetWithText(OutlinedButton, 'Filtros'), findsNothing);
      expect(
        find.textContaining('Proyectos que buscan:'),
        findsOneWidget,
      );
    });

    testWidgets('8 · "Explorar proyectos" tiene el buscador y el boton Filtros',
        (tester) async {
      await _montarCartelera(tester);
      await _irAExplorar(tester);

      expect(find.byType(TextField), findsOneWidget);
      expect(find.text('Buscar proyectos...'), findsOneWidget);
      expect(find.widgetWithText(OutlinedButton, 'Filtros'), findsOneWidget);
    });

    testWidgets('la busqueda por titulo filtra la lista de explorar',
        (tester) async {
      await _montarCartelera(tester);
      await _irAExplorar(tester);

      await tester.enterText(find.byType(TextField).first, 'movilidad');
      await tester.pumpAndSettle();

      expect(_tarjetas(), 1);
      expect(find.text('App de movilidad sostenible'), findsOneWidget);
    });

    testWidgets('13 · sin coincidencias sale el estado vacio y se limpia',
        (tester) async {
      await _montarCartelera(tester);
      await _irAExplorar(tester);

      await tester.enterText(find.byType(TextField).first, 'zzzz');
      await tester.pumpAndSettle();

      expect(_tarjetas(), 0);
      expect(find.text('Ningún proyecto coincide'), findsOneWidget);
      // La fila de busqueda sigue visible: si no, no habria como deshacerla.
      expect(find.text('Buscar proyectos...'), findsOneWidget);

      await tester.tap(find.widgetWithText(OutlinedButton, 'Limpiar filtros'));
      await tester.pumpAndSettle();

      expect(_tarjetas(), 6);
      // Limpiar tambien vacia el campo, no solo el estado del controlador.
      expect(
        tester.widget<TextField>(find.byType(TextField).first).controller?.text,
        isEmpty,
      );
    });

    testWidgets('14 · el proyecto lleno sigue en la lista y lo dice',
        (tester) async {
      await _montarCartelera(tester);
      await _irAExplorar(tester);

      // Ya no hay "solo abiertos" que los esconda.
      expect(_tarjetas(), 6);
      expect(find.text('Red comunitaria de reciclaje textil'), findsOneWidget);
      expect(
        find.text('Equipo completo · reclutamiento cerrado'),
        findsOneWidget,
      );

      // El '6' esta cerrado pero va 3 de 4: no esta completo, y la tarjeta no
      // dice que lo este.
      expect(find.text('Biblioteca digital accesible'), findsOneWidget);
      expect(find.text('Reclutamiento cerrado'), findsOneWidget);
    });

    testWidgets('la tarjeta lleva programa, miembros y habilidades buscadas',
        (tester) async {
      await _montarCartelera(tester);
      await _irAExplorar(tester);

      // El '1': Arquitectura, 4 de 6, y pide Análisis de datos y Diseño UX.
      expect(
        find.text('${AppCatalogs.programArchitecture} · 4 de 6 miembros'),
        findsOneWidget,
      );
      expect(
        find.text(
          'Busca: ${AppCatalogs.skillData} · ${AppCatalogs.skillUx}',
        ),
        findsOneWidget,
      );

      // El '5' no pide ninguna: no puede quedarse sin tercera linea.
      expect(find.text('Abierto a postulaciones'), findsOneWidget);
    });

    testWidgets('7 · sin habilidades en el perfil, el vacio lo explica y '
        'lleva a "Explorar proyectos"', (tester) async {
      await _montarCartelera(tester, skillsDelPerfil: const []);

      expect(_tarjetas(), 0);
      expect(
        find.text('Todavía no tienes habilidades registradas'),
        findsOneWidget,
      );

      await tester.tap(
        find.widgetWithText(OutlinedButton, 'Explorar proyectos'),
      );
      await tester.pumpAndSettle();

      // El boton salta de pestania de verdad.
      expect(find.text('Buscar proyectos...'), findsOneWidget);
      expect(_tarjetas(), 6);
    });

    testWidgets('7 · con habilidades que ningun proyecto pide, el vacio lo dice',
        (tester) async {
      // Ninguna de las siete del catalogo sirve: todas las pide algun proyecto
      // sembrado. Hace falta una de fuera para llegar a esta rama de la vista.
      await _montarCartelera(tester, skillsDelPerfil: const ['Soldadura']);

      expect(_tarjetas(), 0);
      expect(find.text('Ningún proyecto pide tus habilidades'), findsOneWidget);
    });

    testWidgets('los filtros de explorar no tocan la pestania de habilidades',
        (tester) async {
      final controller = await _montarCartelera(
        tester,
        skillsDelPerfil: const [AppCatalogs.skillMarketing],
      );

      // Solo el '4' pide Marketing, y esta en etapa "Formando equipo".
      expect(_tarjetas(), 1);
      expect(find.text('Red comunitaria de reciclaje textil'), findsOneWidget);

      // Un filtro que deja fuera al '4' vacia "Explorar" pero no esta pestania:
      // aqui no hay ningun control que lo explique ni que lo deshaga.
      controller.applyFilters(
        skills: const [],
        programs: const [],
        stages: const [ProjectStage.idea],
      );
      await tester.pumpAndSettle();

      expect(_tarjetas(), 1);
      expect(find.text('Red comunitaria de reciclaje textil'), findsOneWidget);

      await _irAExplorar(tester);
      expect(find.text('Red comunitaria de reciclaje textil'), findsNothing);
    });

    testWidgets('la idea nueva aparece de primera y en las dos si pide una '
        'habilidad del perfil', (tester) async {
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
