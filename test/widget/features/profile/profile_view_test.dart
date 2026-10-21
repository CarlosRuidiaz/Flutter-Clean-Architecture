import 'dart:async';

import 'package:f_clean_template/core/app_routes.dart';
import 'package:f_clean_template/core/app_theme.dart';
import 'package:f_clean_template/features/application/domain/models/application.dart';
import 'package:f_clean_template/features/application/domain/repositories/i_application_repository.dart';
import 'package:f_clean_template/features/auth/domain/models/authentication_user.dart';
import 'package:f_clean_template/features/auth/domain/repositories/i_auth_repository.dart';
import 'package:f_clean_template/features/auth/ui/viewmodels/authentication_controller.dart';
import 'package:f_clean_template/features/follow/data/datasources/local/local_follow_source.dart';
import 'package:f_clean_template/features/follow/data/repositories/follow_repository.dart';
import 'package:f_clean_template/features/follow/domain/repositories/i_follow_repository.dart';
import 'package:f_clean_template/features/follow/ui/viewmodels/follow_controller.dart';
import 'package:f_clean_template/features/my_projects/ui/viewmodels/my_projects_controller.dart';
import 'package:f_clean_template/features/poll/data/datasources/local/local_poll_source.dart';
import 'package:f_clean_template/features/poll/data/repositories/poll_repository.dart';
import 'package:f_clean_template/features/poll/domain/repositories/i_poll_repository.dart';
import 'package:f_clean_template/features/poll/ui/viewmodels/poll_controller.dart';
import 'package:f_clean_template/features/profile/domain/models/profile.dart';
import 'package:f_clean_template/features/profile/domain/repositories/i_profile_repository.dart';
import 'package:f_clean_template/features/profile/ui/viewmodels/profile_controller.dart';
import 'package:f_clean_template/features/profile/ui/views/profile_view.dart';
import 'package:f_clean_template/features/project/domain/models/project.dart';
import 'package:f_clean_template/features/project/domain/repositories/i_project_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

// ─── Fakes ──────────────────────────────────────────────────────────────────

class _FakeAuth implements IAuthRepository {
  bool _logged = true;
  final StreamController<bool> _ctrl = StreamController<bool>.broadcast();

  @override
  Stream<bool> get sessionChanges => _ctrl.stream;
  @override
  Future<AuthenticationUser?> getLoggedUser() async =>
      _logged ? AuthenticationUser(id: 'u1', email: 't@t.com', name: 'T', password: '') : null;
  @override
  Future<bool> login(AuthenticationUser u) async => true;
  @override
  Future<bool> restoreSession() async => true;
  @override
  Future<bool> signUp(AuthenticationUser u) async => true;
  @override
  Future<bool> logOut() async {
    _logged = false;
    _ctrl.add(false);
    return true;
  }
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
        fullName: 'Carlos Ruidíaz',
        academicProgram: 'Ing. de Sistemas',
        semester: 8,
        skills: const ['Flutter', 'Dart'],
      );
}

class _FakeProjects implements IProjectRepository {
  @override
  Future<List<Project>> getProjects() async => [
        Project(
          id: 'p1',
          title: 'App de movilidad',
          problem: '',
          description: '',
          stage: ProjectStage.idea,
          academicProgram: 'Ing. de Sistemas',
          currentMembers: 1,
          maxMembers: 4,
          skillsWanted: const [],
          leaderId: 'u1',
        ),
      ];
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
  @override
  Future<List<Application>> getMyApplications(String id) async => [];
  @override
  Future<List<Application>> getApplicationsFor(String id) async => [];
  @override
  Future<Application> apply(Application a) async => throw UnimplementedError();
  @override
  Future<void> withdraw(String id) async {}
  @override
  Future<void> leave(String id) async {}
  @override
  Future<void> decide(String id, ApplicationStatus d) async {}
}

// ─── Helpers ────────────────────────────────────────────────────────────────

Future<void> _montar(WidgetTester tester) async {
  Get.testMode = true;
  await Get.deleteAll(force: true);

  tester.view.physicalSize = const Size(1200, 3000);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);

  final authRepo = _FakeAuth();
  final profileRepo = _FakeProfile();
  final projectRepo = _FakeProjects();
  final appRepo = _FakeApps();

  Get.put<IAuthRepository>(authRepo);
  Get.put<AuthenticationController>(AuthenticationController(authRepo));
  Get.put<IProfileRepository>(profileRepo);
  Get.put<IProjectRepository>(projectRepo);
  Get.put<IApplicationRepository>(appRepo);

  Get.put<IFollowRepository>(FollowRepository(LocalFollowSource()));
  Get.put(FollowController(Get.find<IFollowRepository>(), authRepo));
  Get.put<IPollRepository>(PollRepository(LocalPollSource()));
  Get.put(PollController(Get.find<IPollRepository>(), authRepo, profileRepo, projectRepo, appRepo));

  final myProjectsCtrl = Get.put(
    MyProjectsController(projectRepo, appRepo, profileRepo, authRepo),
  );
  await myProjectsCtrl.reload();

  Get.put(ProfileController(profileRepo, authRepo));

  await tester.pumpWidget(
    GetMaterialApp(
      theme: AppTheme.light,
      home: const ProfileView(),
      getPages: AppRoutes.pages,
    ),
  );
  await tester.pumpAndSettle();
}

// ─── Tests ──────────────────────────────────────────────────────────────────

void main() {
  tearDown(() => Get.deleteAll(force: true));

  group('ProfileView', () {
    testWidgets('muestra nombre, programa, semestre y habilidades del perfil',
        (tester) async {
      await _montar(tester);

      expect(find.byKey(const Key('ProfileView')), findsOneWidget);
      expect(find.text('Carlos Ruidíaz'), findsOneWidget);
      expect(find.text('Ing. de Sistemas · 8.º semestre'), findsOneWidget);
      expect(find.text('Flutter'), findsOneWidget);
      expect(find.text('Dart'), findsOneWidget);
    });

    testWidgets('muestra el boton de cerrar sesion', (tester) async {
      await _montar(tester);

      expect(find.byKey(const Key('ButtonLogout')), findsOneWidget);
      expect(find.text('Cerrar sesión'), findsOneWidget);
    });

    testWidgets('cerrar sesion pide confirmacion antes de actuar',
        (tester) async {
      await _montar(tester);

      await tester.tap(find.byKey(const Key('ButtonLogout')));
      await tester.pumpAndSettle();

      // La hoja de confirmacion aparece.
      expect(find.text('¿Cerrar sesión?'), findsOneWidget);
      expect(find.byKey(const Key('ButtonLogoutConfirm')), findsOneWidget);
    });

    testWidgets('volver desde confirmacion no cierra la sesion', (tester) async {
      await _montar(tester);

      await tester.tap(find.byKey(const Key('ButtonLogout')));
      await tester.pumpAndSettle();

      await tester.tap(find.widgetWithText(OutlinedButton, 'Volver'));
      await tester.pumpAndSettle();

      expect(find.text('¿Cerrar sesión?'), findsNothing);
      expect(Get.find<AuthenticationController>().isLogged, isTrue);
    });

    testWidgets('confirmar cierre de sesion llama a logOut', (tester) async {
      await _montar(tester);

      await tester.tap(find.byKey(const Key('ButtonLogout')));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('ButtonLogoutConfirm')));
      await tester.pumpAndSettle();

      // La sesion quedo cerrada.
      expect(Get.find<AuthenticationController>().isLogged, isFalse);
    });

    testWidgets('proyectos activos del usuario aparecen listados', (tester) async {
      await _montar(tester);

      expect(find.text('1 proyecto activo'), findsOneWidget);
      expect(find.text('App de movilidad'), findsOneWidget);
      expect(find.text('Líder'), findsOneWidget);
    });
  });
}
