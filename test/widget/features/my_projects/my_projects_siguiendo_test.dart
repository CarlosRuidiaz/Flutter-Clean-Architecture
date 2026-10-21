import 'dart:async';

import 'package:f_clean_template/features/application/domain/models/application.dart';
import 'package:f_clean_template/features/application/domain/repositories/i_application_repository.dart';
import 'package:f_clean_template/features/auth/domain/models/authentication_user.dart';
import 'package:f_clean_template/features/auth/domain/repositories/i_auth_repository.dart';
import 'package:f_clean_template/features/follow/data/datasources/local/local_follow_source.dart';
import 'package:f_clean_template/features/follow/data/repositories/follow_repository.dart';
import 'package:f_clean_template/features/follow/domain/repositories/i_follow_repository.dart';
import 'package:f_clean_template/features/follow/ui/viewmodels/follow_controller.dart';
import 'package:f_clean_template/features/my_projects/ui/viewmodels/my_projects_controller.dart';
import 'package:f_clean_template/features/my_projects/ui/views/my_projects_view.dart';
import 'package:f_clean_template/features/poll/data/datasources/local/local_poll_source.dart';
import 'package:f_clean_template/features/poll/data/repositories/poll_repository.dart';
import 'package:f_clean_template/features/poll/domain/repositories/i_poll_repository.dart';
import 'package:f_clean_template/features/poll/ui/viewmodels/poll_controller.dart';
import 'package:f_clean_template/features/profile/domain/models/profile.dart';
import 'package:f_clean_template/features/profile/domain/repositories/i_profile_repository.dart';
import 'package:f_clean_template/features/project/domain/models/project.dart';
import 'package:f_clean_template/features/project/domain/repositories/i_project_repository.dart';
import 'package:f_clean_template/features/project/ui/viewmodels/project_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

// ─── Fakes ──────────────────────────────────────────────────────────────────

class _FakeAuth implements IAuthRepository {
  final StreamController<bool> _session = StreamController<bool>.broadcast();
  @override
  Stream<bool> get sessionChanges => _session.stream;
  @override
  Future<AuthenticationUser?> getLoggedUser() async =>
      AuthenticationUser(id: 'u1', email: 't@t.com', name: 'T', password: '');
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

class _FakeProfile implements IProfileRepository {
  @override
  Future<Profile> getCurrentProfile() async => Profile(
        id: 'u1',
        fullName: 'Ana García',
        academicProgram: 'Diseño',
        semester: 3,
        skills: const [],
      );
}

class _FakeProjects implements IProjectRepository {
  final List<Project> _projects;
  _FakeProjects([List<Project>? p])
      : _projects = p ??
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
                skillsWanted: const [],
                leaderId: 'u1',
              ),
            ];
  @override
  Future<List<Project>> getProjects() async => _projects;
  @override
  Future<Project> createProject(Project p) async => throw UnimplementedError();
  @override
  Future<void> closeRecruitment(String id) async {}
  @override
  Future<void> addMember(String id) async {}
  @override
  Future<void> removeMember(String id) async {}
  @override
  Future<void> updateStage(String id, ProjectStage s) async {}
}

class _FakeApps implements IApplicationRepository {
  final List<Application> apps;
  _FakeApps([List<Application>? a]) : apps = a ?? [];
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
  Future<void> leave(String id) async {}
  @override
  Future<void> decide(String id, ApplicationStatus d) async {}
}

// ─── Helper ─────────────────────────────────────────────────────────────────

Future<FollowController> _montar(
  WidgetTester tester, {
  IProjectRepository? projectRepo,
  IApplicationRepository? appRepo,
  VoidCallback? onExplore,
}) async {
  await Get.deleteAll(force: true);
  Get.testMode = true;

  final authRepo = _FakeAuth();
  final profileRepo = _FakeProfile();
  final pRepo = projectRepo ?? _FakeProjects();
  final aRepo = appRepo ?? _FakeApps();

  final myProjectsCtrl = Get.put<MyProjectsController>(
    MyProjectsController(pRepo, aRepo, profileRepo, authRepo),
  );

  // ProjectController hace falta para _FollowingTab.
  Get.put<IProjectRepository>(pRepo);
  Get.put<IProfileRepository>(profileRepo);
  Get.put(ProjectController(pRepo, profileRepo, authRepo));

  final followRepo = FollowRepository(LocalFollowSource());
  Get.put<IFollowRepository>(followRepo);
  final followCtrl = Get.put(FollowController(followRepo, authRepo));

  Get.put<IPollRepository>(PollRepository(LocalPollSource()));
  Get.put(PollController(
    Get.find<IPollRepository>(),
    authRepo,
    profileRepo,
    pRepo,
    aRepo,
  ));

  await myProjectsCtrl.reload();
  await followCtrl.reload();

  await tester.pumpWidget(
    GetMaterialApp(home: MyProjectsView(onExplore: onExplore)),
  );
  await tester.pumpAndSettle();

  return followCtrl;
}

// ─── Tests ──────────────────────────────────────────────────────────────────

void main() {
  tearDown(() => Get.deleteAll(force: true));

  group('MyProjectsView · pestaña Siguiendo', () {
    testWidgets('las tres pestañas son visibles', (tester) async {
      await _montar(tester);

      expect(find.byKey(const Key('TabCreados')), findsOneWidget);
      expect(find.byKey(const Key('TabParticipo')), findsOneWidget);
      expect(find.byKey(const Key('TabSiguiendo')), findsOneWidget);
    });

    testWidgets('la pestaña Siguiendo vacía muestra el estado vacío correcto',
        (tester) async {
      await _montar(tester);

      await tester.tap(find.byKey(const Key('TabSiguiendo')));
      await tester.pumpAndSettle();

      expect(find.text('No sigues ningún proyecto'), findsOneWidget);
      expect(find.text('Explorar proyectos'), findsOneWidget);
    });

    testWidgets('el botón Explorar en Siguiendo llama a onExplore',
        (tester) async {
      bool called = false;
      await _montar(tester, onExplore: () => called = true);

      await tester.tap(find.byKey(const Key('TabSiguiendo')));
      await tester.pumpAndSettle();

      // En el estado vacío de Siguiendo hay un botón "Explorar proyectos".
      await tester.tap(find.text('Explorar proyectos').last);
      await tester.pumpAndSettle();

      expect(called, isTrue);
    });

    testWidgets('cuando se sigue un proyecto aparece su tarjeta en Siguiendo',
        (tester) async {
      final followCtrl = await _montar(tester);

      // Usar toggleFollow para registrar el seguimiento, igual que la pantalla.
      await followCtrl.toggleFollow('p1', true);
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('TabSiguiendo')));
      await tester.pumpAndSettle();

      // La tarjeta del proyecto seguido aparece.
      expect(find.text('Mi primer proyecto'), findsOneWidget);
    });
  });
}
