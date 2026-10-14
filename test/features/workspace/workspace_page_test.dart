import 'dart:async';

import 'package:f_clean_template/core/app_routes.dart';
import 'package:f_clean_template/core/app_theme.dart';
import 'package:f_clean_template/features/application/data/datasources/i_application_source.dart';
import 'package:f_clean_template/features/application/data/datasources/local/local_application_source.dart';
import 'package:f_clean_template/features/application/data/repositories/application_repository.dart';
import 'package:f_clean_template/features/application/domain/models/application.dart';
import 'package:f_clean_template/features/application/domain/repositories/i_application_repository.dart';
import 'package:f_clean_template/features/poll/ui/views/widgets/workspace_polls_block.dart';
import 'package:f_clean_template/features/profile/domain/models/profile.dart';
import 'package:f_clean_template/features/profile/domain/repositories/i_profile_repository.dart';
import 'package:f_clean_template/features/project/data/datasources/i_project_source.dart';
import 'package:f_clean_template/features/project/data/datasources/local/local_project_source.dart';
import 'package:f_clean_template/features/project/data/repositories/project_repository.dart';
import 'package:f_clean_template/features/project/domain/models/project.dart';
import 'package:f_clean_template/features/project/domain/repositories/i_project_repository.dart';
import 'package:f_clean_template/features/workspace/data/datasources/i_workspace_source.dart';
import 'package:f_clean_template/features/workspace/data/datasources/local/local_workspace_source.dart';
import 'package:f_clean_template/features/workspace/data/repositories/workspace_repository.dart';
import 'package:f_clean_template/features/workspace/domain/models/progress_update.dart';
import 'package:f_clean_template/features/workspace/domain/repositories/i_workspace_repository.dart';
import 'package:f_clean_template/features/workspace/ui/viewmodels/workspace_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import '../auth/fake_auth_repository.dart';
import '../seguir_y_encuestas_de_prueba.dart';

class _PerfilFijo implements IProfileRepository {
  _PerfilFijo(this.perfil);

  final Profile perfil;

  /// Mientras tenga un completer sin completar, pedir el perfil espera. Deja
  /// una recarga "en vuelo" para poder mirar la pantalla en ese momento.
  Completer<void>? pausa;

  @override
  Future<Profile> getCurrentProfile() async {
    await pausa?.future;
    return perfil;
  }
}

Profile _perfil(String id, String nombre) => Profile(
  id: id,
  fullName: nombre,
  academicProgram: 'Ing. de Sistemas',
  semester: 5,
  skills: const ['Python'],
);

/// El proyecto '2' lo lidera el perfil '1'. Sus postulantes de prueba son u7
/// (Mariana Pérez) y u8 (Felipe Gómez), los dos pendientes: [preparar] acepta a
/// quien haga falta.
final Profile _lider = _perfil('1', 'Carlos Ruidíaz');
final Profile _mariana = _perfil('u7', 'Mariana Pérez');

Future<void> _aceptarAMariana(IApplicationRepository postulaciones) =>
    postulaciones.decide('1', ApplicationStatus.accepted);

Future<void> _abrir(
  WidgetTester tester, {
  required Profile perfil,
  Future<void> Function(IApplicationRepository postulaciones)? preparar,
}) async {
  Get.testMode = true;
  await Get.deleteAll(force: true);

  tester.view.physicalSize = const Size(1200, 3000);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);

  Get.put<IProfileRepository>(_PerfilFijo(perfil));
  Get.put<IProjectSource>(LocalProjectSource());
  Get.put<IProjectRepository>(ProjectRepository(Get.find()));
  Get.put<IApplicationSource>(LocalApplicationSource());
  Get.put<IApplicationRepository>(ApplicationRepository(Get.find()));
  Get.put<IWorkspaceSource>(LocalWorkspaceSource());
  Get.put<IWorkspaceRepository>(WorkspaceRepository(Get.find()));
  Get.put(
    WorkspaceController(
      Get.find<IWorkspaceRepository>(),
      Get.find<IApplicationRepository>(),
      Get.find<IProfileRepository>(),
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
      .firstWhere((p) => p.id == '2');

  await tester.pumpWidget(
    GetMaterialApp(
      theme: AppTheme.light,
      home: const Scaffold(body: Text('pantalla principal')),
      getPages: AppRoutes.pages,
    ),
  );
  await tester.pumpAndSettle();
  Get.toNamed(AppRoutes.workspace, arguments: project);
  await tester.pumpAndSettle();
}

Future<Project> _proyecto() async =>
    (await Get.find<IProjectRepository>().getProjects()).firstWhere(
      (p) => p.id == '2',
    );

Future<ApplicationStatus> _estadoDeMariana() async =>
    (await Get.find<IApplicationRepository>().getApplicationsFor('2'))
        .firstWhere((a) => a.id == '1')
        .status;

void main() {
  tearDown(() => Get.deleteAll(force: true));

  group('WorkspacePage · quien entra', () {
    testWidgets('un visitante que no lidera ni fue aceptado no entra',
        (tester) async {
      await _abrir(tester, perfil: _perfil('visitante', 'Alguien Más'));

      expect(find.textContaining('No tienes acceso'), findsOneWidget);
      expect(find.text('Miembros del equipo'), findsNothing);
    });

    testWidgets('abrir el espacio de trabajo no deja el spinner puesto',
        (tester) async {
      await _abrir(tester, perfil: _lider);

      expect(find.byType(CircularProgressIndicator), findsNothing);
      expect(find.text('Miembros del equipo'), findsOneWidget);
    });
  });

  group('WorkspacePage · salir del proyecto', () {
    testWidgets('un miembro ve "Salir del proyecto" y no "Remover"',
        (tester) async {
      await _abrir(tester, perfil: _mariana, preparar: _aceptarAMariana);

      expect(
        find.widgetWithText(OutlinedButton, 'Salir del proyecto'),
        findsOneWidget,
      );
      expect(find.text('Remover'), findsNothing);
    });

    testWidgets('el lider no tiene "Salir del proyecto"', (tester) async {
      await _abrir(tester, perfil: _lider, preparar: _aceptarAMariana);

      expect(find.text('Salir del proyecto'), findsNothing);
    });

    testWidgets('pide confirmacion, y "Quedarme" no cambia nada',
        (tester) async {
      await _abrir(tester, perfil: _mariana, preparar: _aceptarAMariana);

      await tester.tap(find.widgetWithText(OutlinedButton, 'Salir del proyecto'));
      await tester.pumpAndSettle();
      expect(find.text('¿Salir del proyecto?'), findsOneWidget);

      await tester.tap(find.widgetWithText(OutlinedButton, 'Quedarme'));
      await tester.pumpAndSettle();

      expect(await _estadoDeMariana(), ApplicationStatus.accepted);
      expect((await _proyecto()).currentMembers, 2);
      expect(find.text('Miembros del equipo'), findsOneWidget);
    });

    testWidgets('al confirmar: left, el contador baja y vuelve al inicio',
        (tester) async {
      await _abrir(tester, perfil: _mariana, preparar: _aceptarAMariana);

      await tester.tap(find.widgetWithText(OutlinedButton, 'Salir del proyecto'));
      await tester.pumpAndSettle();
      await tester.tap(
        find.widgetWithText(ElevatedButton, 'Sí, salir del proyecto'),
      );
      await tester.pumpAndSettle();

      expect(await _estadoDeMariana(), ApplicationStatus.left);
      expect((await _proyecto()).currentMembers, 1);
      // De vuelta a la pantalla principal, no en el espacio de trabajo.
      expect(find.text('pantalla principal'), findsOneWidget);
      expect(find.text('Miembros del equipo'), findsNothing);
    });
  });

  group('WorkspacePage · remover y cambiar la etapa', () {
    testWidgets('el lider ve "Remover" junto al miembro y no junto a si mismo',
        (tester) async {
      await _abrir(tester, perfil: _lider, preparar: _aceptarAMariana);

      expect(find.text('Remover'), findsOneWidget);
    });

    testWidgets('remover pide confirmacion y deja al miembro en removed',
        (tester) async {
      await _abrir(tester, perfil: _lider, preparar: _aceptarAMariana);

      await tester.tap(find.text('Remover'));
      await tester.pumpAndSettle();
      expect(find.text('¿Remover a Mariana Pérez?'), findsOneWidget);

      await tester.tap(find.widgetWithText(ElevatedButton, 'Sí, remover'));
      await tester.pumpAndSettle();

      expect(await _estadoDeMariana(), ApplicationStatus.removed);
      expect((await _proyecto()).currentMembers, 1);
      // El equipo de la pantalla ya no la incluye.
      expect(find.text('Mariana Pérez'), findsNothing);
      expect(find.text('Remover'), findsNothing);
    });

    testWidgets('cancelar no remueve a nadie', (tester) async {
      await _abrir(tester, perfil: _lider, preparar: _aceptarAMariana);

      await tester.tap(find.text('Remover'));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(OutlinedButton, 'Cancelar'));
      await tester.pumpAndSettle();

      expect(await _estadoDeMariana(), ApplicationStatus.accepted);
      expect(find.text('Mariana Pérez'), findsOneWidget);
    });

    testWidgets('el lider elige entre las seis etapas y el proyecto cambia',
        (tester) async {
      await _abrir(tester, perfil: _lider);

      // Las seis etapas a la vista como pildoras.
      for (final etapa in [
        'Idea',
        'Formando equipo',
        'Investigación',
        'Prototipo',
        'Pruebas',
        'Terminado',
      ]) {
        expect(find.text(etapa), findsWidgets, reason: etapa);
      }

      await tester.tap(find.text('Prototipo'));
      await tester.pumpAndSettle();

      expect((await _proyecto()).stage, ProjectStage.prototype);
      // La cabecera de la pantalla ya muestra la etapa nueva.
      expect(find.text('Prototipo'), findsNWidgets(2));
    });

    testWidgets('un miembro ve la etapa pero no puede cambiarla',
        (tester) async {
      await _abrir(tester, perfil: _mariana, preparar: _aceptarAMariana);

      // Solo la etiqueta actual (en la cabecera y en "Estado actual").
      expect(find.text('Idea'), findsNWidgets(2));
      expect(find.text('Prototipo'), findsNothing);
      expect(find.text('Terminado'), findsNothing);
    });
  });

  group('WorkspacePage · deslizar para refrescar', () {
    testWidgets('las tres pestanias tienen su RefreshIndicator', (tester) async {
      await _abrir(tester, perfil: _lider);

      for (final pestania in ['Resumen', 'Avances', 'Tareas']) {
        await tester.tap(find.text(pestania));
        await tester.pumpAndSettle();
        expect(find.byType(RefreshIndicator), findsOneWidget, reason: pestania);
      }
    });

    testWidgets('refrescar no reemplaza la pantalla por un spinner',
        (tester) async {
      await _abrir(tester, perfil: _lider, preparar: _aceptarAMariana);
      final controller = Get.find<WorkspaceController>();
      final perfil = Get.find<IProfileRepository>() as _PerfilFijo;

      // La recarga queda en vuelo, esperando el perfil.
      perfil.pausa = Completer<void>();
      final refrescando = controller.reload();
      await tester.pump();

      // Mientras se pide, lo que ya estaba sigue a la vista y no hay spinner.
      expect(controller.isLoading.value, isTrue);
      expect(find.text('Miembros del equipo'), findsOneWidget);
      expect(find.text('Mariana Pérez'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsNothing);

      perfil.pausa!.complete();
      await refrescando;
      await tester.pumpAndSettle();
      expect(controller.isLoading.value, isFalse);
      expect(find.text('Mariana Pérez'), findsOneWidget);
    });

    testWidgets('deslizar hacia abajo en una lista vacia tambien refresca',
        (tester) async {
      await _abrir(tester, perfil: _lider);
      await tester.tap(find.text('Avances'));
      await tester.pumpAndSettle();
      expect(find.textContaining('Todavía no hay avances'), findsOneWidget);

      // Un avance llega "desde fuera" (otro miembro lo publica).
      final controller = Get.find<WorkspaceController>();
      await controller.repository.publishUpdate(
        ProgressUpdate(
          projectId: '2',
          authorId: 'u7',
          authorName: 'Mariana Pérez',
          title: 'Avance de otro miembro',
          description: 'Lo publicó otra persona',
          createdAt: DateTime(2026, 9, 23),
          completionPercentage: 0,
        ),
      );

      // La pantalla de prueba es alta: RefreshIndicator pide arrastrar un
      // cuarto de su alto antes de refrescar.
      await tester.drag(find.byType(ListView), const Offset(0, 1500));
      await tester.pumpAndSettle();

      expect(find.text('Avance de otro miembro'), findsOneWidget);
    });
  });

  group('WorkspacePage · encuestas en el resumen', () {
    testWidgets('un miembro ve "Salir del proyecto" y el bloque de encuestas',
        (tester) async {
      await _abrir(tester, perfil: _mariana, preparar: _aceptarAMariana);

      expect(
        find.widgetWithText(OutlinedButton, 'Salir del proyecto'),
        findsOneWidget,
      );
      expect(find.byType(WorkspacePollsBlock), findsOneWidget);
    });

    testWidgets('el lider ve el bloque de encuestas pero no "Salir"',
        (tester) async {
      await _abrir(tester, perfil: _lider, preparar: _aceptarAMariana);

      expect(find.byType(WorkspacePollsBlock), findsOneWidget);
      expect(find.text('Salir del proyecto'), findsNothing);
    });
  });
}
