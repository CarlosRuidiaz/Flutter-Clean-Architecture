import 'dart:async';

import 'package:f_clean_template/features/application/domain/models/application.dart';
import 'package:f_clean_template/features/application/domain/repositories/i_application_repository.dart';
import 'package:f_clean_template/features/auth/domain/models/authentication_user.dart';
import 'package:f_clean_template/features/auth/domain/repositories/i_auth_repository.dart';
import 'package:f_clean_template/features/my_projects/ui/viewmodels/my_projects_controller.dart';
import 'package:f_clean_template/features/my_projects/ui/views/my_projects_view.dart';
import 'package:f_clean_template/features/profile/domain/models/profile.dart';
import 'package:f_clean_template/features/profile/domain/repositories/i_profile_repository.dart';
import 'package:f_clean_template/features/project/domain/models/project.dart';
import 'package:f_clean_template/features/project/domain/repositories/i_project_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

// ───────────────────────────────────────────────────────────────────────────
// Fakes
// ───────────────────────────────────────────────────────────────────────────

class _FakeAuthRepository implements IAuthRepository {
  bool isLogged = true;
  final StreamController<bool> _session = StreamController<bool>.broadcast();

  @override
  Stream<bool> get sessionChanges => _session.stream;

  @override
  Future<AuthenticationUser?> getLoggedUser() async {
    return isLogged
        ? AuthenticationUser(
            id: 'u1', email: 't@t.com', name: 'T', password: '')
        : null;
  }

  @override
  Future<bool> login(AuthenticationUser u) async => true;
  @override
  Future<bool> restoreSession() async => true;
  @override
  Future<bool> signUp(AuthenticationUser u) async => true;
  @override
  Future<bool> logOut() async => true;
  @override
  Future<bool> validate(String e, String c) async => true;
  @override
  Future<bool> validateToken() async => true;
  @override
  Future<void> forgotPassword(String e) async {}
}

class _FakeProfileRepository implements IProfileRepository {
  @override
  Future<Profile> getCurrentProfile() async => Profile(
        id: 'u1',
        fullName: 'Ana García',
        academicProgram: 'Diseño',
        semester: 3,
        skills: [],
      );
}

class _FakeProjectRepository implements IProjectRepository {
  final List<Project> projects;
  _FakeProjectRepository([List<Project>? p])
      : projects = p ??
            [
              Project(
                id: 'p1',
                title: 'Mi primer proyecto',
                problem: '',
                description: '',
                stage: ProjectStage.idea,
                academicProgram: 'Diseño',
                currentMembers: 1,
                maxMembers: 4,
                skillsWanted: [],
                leaderId: 'u1',
              ),
            ];

  @override
  Future<List<Project>> getProjects() async => projects;
  @override
  Future<Project> createProject(Project p) async => throw UnimplementedError();
  @override
  Future<void> closeRecruitment(String id) async {}
  @override
  Future<void> addMember(String id) async {}
}

class _FakeAppRepository implements IApplicationRepository {
  final List<Application> apps;
  _FakeAppRepository([List<Application>? a]) : apps = a ?? [];

  @override
  Future<List<Application>> getMyApplications(String id) async =>
      apps.where((a) => a.applicantId == id).toList();
  @override
  Future<List<Application>> getApplicationsFor(String id) async =>
      apps.where((a) => a.projectId == id).toList();
  @override
  Future<Application> apply(Application a) async => throw UnimplementedError();
  @override
  Future<void> withdraw(String id) async {}
  @override
  Future<void> decide(String id, ApplicationStatus d) async {}
}

class _FailingProjectRepository implements IProjectRepository {
  @override
  Future<List<Project>> getProjects() async =>
      throw Exception('Error de red simulado');
  @override
  Future<Project> createProject(Project p) async => throw UnimplementedError();
  @override
  Future<void> closeRecruitment(String id) async {}
  @override
  Future<void> addMember(String id) async {}
}

// ───────────────────────────────────────────────────────────────────────────
// Helpers
// ───────────────────────────────────────────────────────────────────────────

Future<MyProjectsController> _montar(
  WidgetTester tester, {
  IProjectRepository? projectRepo,
  IApplicationRepository? appRepo,
  VoidCallback? onExplore,
}) async {
  await Get.deleteAll(force: true);
  Get.testMode = true;

  final authRepo = _FakeAuthRepository();
  final profileRepo = _FakeProfileRepository();
  final pRepo = projectRepo ?? _FakeProjectRepository();
  final aRepo = appRepo ?? _FakeAppRepository();

  final controller = Get.put<MyProjectsController>(
    MyProjectsController(pRepo, aRepo, profileRepo, authRepo),
  );

  await controller.reload();

  await tester.pumpWidget(
    GetMaterialApp(home: MyProjectsView(onExplore: onExplore)),
  );
  await tester.pumpAndSettle();

  return controller;
}

// ───────────────────────────────────────────────────────────────────────────
// Tests
// ───────────────────────────────────────────────────────────────────────────

void main() {
  tearDown(() => Get.deleteAll(force: true));

  group('MyProjectsView', () {
    testWidgets('muestra las dos pestañas', (tester) async {
      await _montar(tester);

      expect(find.text('Creados por mí'), findsOneWidget);
      expect(find.text('Donde participo'), findsOneWidget);
    });

    testWidgets('pestaña creados muestra tarjeta con pendientes',
        (tester) async {
      final appRepo = _FakeAppRepository([
        Application(
          id: 'a1',
          projectId: 'p1',
          applicantId: 'u2',
          applicantName: 'x',
          applicantProgram: 'x',
          applicantSemester: 1,
          skillsOffered: [],
          status: ApplicationStatus.pending,
        ),
      ]);

      await _montar(tester, appRepo: appRepo);

      expect(find.text('Mi primer proyecto'), findsOneWidget);
      expect(find.text('1 pendiente'), findsOneWidget);
    });

    testWidgets('pestaña creados vacía muestra mensaje y botón',
        (tester) async {
      await _montar(tester, projectRepo: _FakeProjectRepository([]));

      expect(find.text('Todavía no has creado proyectos'), findsOneWidget);
      expect(find.text('Publicar una idea'), findsOneWidget);
    });

    testWidgets('pestaña donde participo vacía muestra mensaje',
        (tester) async {
      await _montar(tester);

      // Ir a la segunda pestaña.
      await tester.tap(find.text('Donde participo'));
      await tester.pumpAndSettle();

      expect(
        find.text('Todavía no participas en ningún proyecto'),
        findsOneWidget,
      );
      expect(find.text('Explorar proyectos'), findsOneWidget);
    });

    testWidgets('el botón "Explorar proyectos" llama a onExplore',
        (tester) async {
      bool called = false;
      await _montar(tester, onExplore: () => called = true);

      await tester.tap(find.text('Donde participo'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Explorar proyectos'));
      await tester.pumpAndSettle();

      expect(called, isTrue);
    });

    testWidgets('estado de error muestra mensaje y reintentar',
        (tester) async {
      await _montar(tester, projectRepo: _FailingProjectRepository());

      expect(
        find.text('No pudimos cargar tus proyectos'),
        findsOneWidget,
      );
      expect(find.text('Reintentar'), findsOneWidget);
    });

    testWidgets('pendientes cero muestra "0 pendientes"', (tester) async {
      await _montar(tester);

      expect(find.text('0 pendientes'), findsOneWidget);
    });
  });
}
