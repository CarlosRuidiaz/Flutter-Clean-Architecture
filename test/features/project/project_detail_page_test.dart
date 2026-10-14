import 'package:f_clean_template/core/app_routes.dart';
import 'package:f_clean_template/core/app_theme.dart';
import 'package:f_clean_template/features/application/data/datasources/i_application_source.dart';
import 'package:f_clean_template/features/application/data/datasources/local/local_application_source.dart';
import 'package:f_clean_template/features/application/data/repositories/application_repository.dart';
import 'package:f_clean_template/features/application/domain/repositories/i_application_repository.dart';
import 'package:f_clean_template/features/application/ui/viewmodels/application_controller.dart';
import 'package:f_clean_template/features/application/domain/models/application.dart';
import 'package:f_clean_template/features/profile/data/datasources/i_profile_source.dart';
import 'package:f_clean_template/features/profile/domain/models/profile.dart';
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
import '../seguir_y_encuestas_de_prueba.dart';

/// Un repositorio de perfil que no logra cargar nada: como cuando todavia no
/// hay sesion. `ProfileController` lo traga y deja el perfil en null.
class _PerfilQueNoCarga implements IProfileRepository {
  @override
  Future<Profile> getCurrentProfile() async =>
      throw StateError('todavia no hay sesion');
}

class _PerfilFijo implements IProfileRepository {
  _PerfilFijo(this.perfil);

  final Profile perfil;

  @override
  Future<Profile> getCurrentProfile() async => perfil;
}

/// [preparar] corre despues de registrar las fuentes y antes de abrir la
/// pantalla: sirve para dejar una postulacion en el estado que se quiere ver.
Future<void> _abrirDetalle(
  WidgetTester tester,
  String projectId, {
  bool conPerfil = true,
  Profile? perfil,
  Future<void> Function(IApplicationRepository postulaciones)? preparar,
}) async {
  Get.testMode = true;
  await Get.deleteAll(force: true);

  tester.view.physicalSize = const Size(1200, 3000);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);

  if (perfil != null) {
    Get.put<IProfileRepository>(_PerfilFijo(perfil));
  } else if (conPerfil) {
    Get.put<IProfileSource>(LocalProfileSource());
    Get.put<IProfileRepository>(ProfileRepository(Get.find()));
  } else {
    Get.put<IProfileRepository>(_PerfilQueNoCarga());
  }
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
  registrarSeguirYEncuestas(
    auth: FakeAuthRepository(),
    perfiles: Get.find(),
    proyectos: Get.find(),
    postulaciones: Get.find(),
  );

  await preparar?.call(Get.find<IApplicationRepository>());

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

    testWidgets('un miembro aceptado ve el espacio de trabajo aunque no lidere',
        (tester) async {
      // El perfil de prueba tiene aceptada su postulacion al '3'.
      await _abrirDetalle(tester, '3');
      await tester.pumpAndSettle();

      expect(
        find.widgetWithText(ElevatedButton, 'Espacio de trabajo'),
        findsOneWidget,
      );
      expect(
        find.widgetWithText(OutlinedButton, 'Gestionar postulantes'),
        findsNothing,
      );
    });

    testWidgets('quien salio del proyecto ya no ve el espacio de trabajo y '
        'puede volver a postularse', (tester) async {
      await _abrirDetalle(
        tester,
        '3',
        preparar: (postulaciones) => postulaciones.leave('4'),
      );
      await tester.pumpAndSettle();

      expect(
        find.widgetWithText(ElevatedButton, 'Espacio de trabajo'),
        findsNothing,
      );
      expect(find.widgetWithText(ElevatedButton, 'Postularme'), findsOneWidget);
    });

    testWidgets('a quien el lider removio no se le ofrece postularse',
        (tester) async {
      // La postulacion '3' del perfil de prueba es al proyecto '1'.
      await _abrirDetalle(
        tester,
        '1',
        preparar: (postulaciones) =>
            postulaciones.decide('3', ApplicationStatus.removed),
      );
      await tester.pumpAndSettle();

      expect(find.widgetWithText(ElevatedButton, 'Postularme'), findsNothing);
      expect(find.text('Te removieron de este proyecto.'), findsOneWidget);
      expect(
        find.widgetWithText(ElevatedButton, 'Espacio de trabajo'),
        findsNothing,
      );
    });

    testWidgets('sin perfil cargado el detalle no ofrece postularse',
        (tester) async {
      await _abrirDetalle(tester, '5', conPerfil: false);
      await tester.pumpAndSettle();

      final boton = find.widgetWithText(ElevatedButton, 'Postularme');
      expect(boton, findsOneWidget);
      expect(tester.widget<ElevatedButton>(boton).onPressed, isNull);

      // Pulsarlo no crea nada a nombre de nadie.
      final antes = (await Get.find<IApplicationRepository>()
              .getApplicationsFor('5'))
          .length;
      await tester.tap(boton, warnIfMissed: false);
      await tester.pumpAndSettle();
      expect(
        (await Get.find<IApplicationRepository>().getApplicationsFor('5'))
            .length,
        antes,
      );
    });

    testWidgets('sin perfil tampoco se ven los botones del lider ni del equipo',
        (tester) async {
      // Aunque el proyecto sea el '2', cuyo lider es el perfil de prueba: sin
      // saber quien mira no se adivina que es el lider.
      await _abrirDetalle(tester, '2', conPerfil: false);
      await tester.pumpAndSettle();

      expect(
        find.widgetWithText(OutlinedButton, 'Gestionar postulantes'),
        findsNothing,
      );
      expect(
        find.widgetWithText(ElevatedButton, 'Espacio de trabajo'),
        findsNothing,
      );
    });

    testWidgets('postularse guarda los datos del perfil, no unos de prueba',
        (tester) async {
      // Un perfil que no se parece en nada a los datos de prueba de antes
      // (Carlos Ruidíaz, Ingeniería de Sistemas, semestre 8).
      final perfil = Profile(
        id: 'u99',
        fullName: 'Valentina Mora',
        academicProgram: 'Psicología',
        semester: 3,
        skills: const ['Python'],
      );
      await _abrirDetalle(tester, '5', perfil: perfil);
      await tester.pumpAndSettle();

      await tester.tap(find.widgetWithText(ElevatedButton, 'Postularme'));
      await tester.pumpAndSettle();

      final nueva = (await Get.find<IApplicationRepository>()
              .getApplicationsFor('5'))
          .single;
      expect(nueva.applicantId, 'u99');
      expect(nueva.applicantName, 'Valentina Mora');
      expect(nueva.applicantProgram, 'Psicología');
      expect(nueva.applicantSemester, 3);
      expect(nueva.skillsOffered, ['Python']);
    });
  });

  group('ProjectDetailPage · seguir', () {
    testWidgets('un visitante con perfil puede seguir el proyecto',
        (tester) async {
      // El '5' lo lidera 'u4': el perfil de prueba es solo un visitante.
      await _abrirDetalle(tester, '5');

      expect(find.widgetWithText(OutlinedButton, 'Seguir'), findsOneWidget);
    });

    testWidgets('sin perfil no se ofrece seguir ni postularse',
        (tester) async {
      await _abrirDetalle(tester, '5', conPerfil: false);
      await tester.pumpAndSettle();

      expect(find.text('Seguir'), findsNothing);
      expect(find.text('Siguiendo'), findsNothing);
      final postularme = find.widgetWithText(ElevatedButton, 'Postularme');
      expect(tester.widget<ElevatedButton>(postularme).onPressed, isNull);
    });

    testWidgets('el lider no ve "Seguir" ni "Postularme" en su proyecto',
        (tester) async {
      // El '2' lo lidera '1', el perfil de prueba, y sigue reclutando.
      await _abrirDetalle(tester, '2');

      expect(find.text('Seguir'), findsNothing);
      expect(find.text('Postularme'), findsNothing);
    });
  });
}
