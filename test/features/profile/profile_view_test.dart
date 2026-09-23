import 'dart:async';
import 'package:f_clean_template/features/application/domain/models/application.dart';
import 'package:f_clean_template/features/application/domain/repositories/i_application_repository.dart';
import 'package:f_clean_template/features/auth/domain/models/authentication_user.dart';
import 'package:f_clean_template/features/auth/domain/repositories/i_auth_repository.dart';
import 'package:f_clean_template/features/auth/ui/viewmodels/authentication_controller.dart';
import 'package:f_clean_template/features/my_projects/ui/viewmodels/my_projects_controller.dart';
import 'package:f_clean_template/features/profile/domain/models/profile.dart';
import 'package:f_clean_template/features/profile/domain/repositories/i_profile_repository.dart';
import 'package:f_clean_template/features/profile/ui/viewmodels/profile_controller.dart';
import 'package:f_clean_template/features/profile/ui/views/profile_view.dart';
import 'package:f_clean_template/features/project/domain/models/project.dart';
import 'package:f_clean_template/features/project/domain/repositories/i_project_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

class _FakeAuthRepository implements IAuthRepository {
  bool isLogged = true;
  final StreamController<bool> _sessionController = StreamController<bool>.broadcast();

  @override
  Stream<bool> get sessionChanges => _sessionController.stream;

  @override
  Future<AuthenticationUser?> getLoggedUser() async {
    return isLogged ? AuthenticationUser(id: 'u1', email: 'test@test.com', name: 'Test', password: '') : null;
  }

  @override
  Future<bool> login(AuthenticationUser user) async => true;
  @override
  Future<bool> restoreSession() async => true;
  @override
  Future<bool> signUp(AuthenticationUser user) async => true;
  @override
  Future<bool> logOut() async {
    isLogged = false;
    _sessionController.add(false);
    return true;
  }
  @override
  Future<bool> validate(String email, String validationCode) async => true;
  @override
  Future<bool> validateToken() async => true;
  @override
  Future<void> forgotPassword(String email) async {}
}

class _FakeProfileRepository implements IProfileRepository {
  @override
  Future<Profile> getCurrentProfile() async => Profile(
        id: '1',
        fullName: 'Juan Pérez',
        academicProgram: 'Ingeniería',
        semester: 5,
        skills: ['Flutter', 'Dart'],
      );
}

class _FakeProjectRepo implements IProjectRepository {
  @override
  Future<List<Project>> getProjects() async => [
    Project(id: 'p1', title: 'Proyecto 1', problem: '', description: '', stage: ProjectStage.idea, academicProgram: 'Ingeniería', currentMembers: 1, maxMembers: 3, skillsWanted: [], leaderId: '1')
  ];
  @override
  Future<Project> createProject(Project project) async => throw UnimplementedError();
  @override
  Future<void> closeRecruitment(String projectId) async {}
  @override
  Future<void> addMember(String projectId) async {}
}

class _FakeAppRepo implements IApplicationRepository {
  @override
  Future<List<Application>> getMyApplications(String applicantId) async => [];
  @override
  Future<List<Application>> getApplicationsFor(String projectId) async => [];
  @override
  Future<Application> apply(Application application) async => throw UnimplementedError();
  @override
  Future<void> withdraw(String applicationId) async {}
  @override
  Future<void> decide(String applicationId, ApplicationStatus decision) async {}
}

void main() {
  group('ProfileView', () {
    setUp(() {
      final authRepo = _FakeAuthRepository();
      Get.put<IAuthRepository>(authRepo);
      Get.put<AuthenticationController>(AuthenticationController(authRepo));

      final profileRepo = _FakeProfileRepository();
      Get.put<ProfileController>(ProfileController(profileRepo, authRepo));

      final projectRepo = _FakeProjectRepo();
      final appRepo = _FakeAppRepo();
      Get.put<MyProjectsController>(MyProjectsController(
        projectRepo, appRepo, profileRepo, authRepo,
      ));
    });

    tearDown(() {
      Get.deleteAll(force: true);
    });

    testWidgets('muestra nombre, inicial, programa y contador de proyectos', (tester) async {
      await Get.find<MyProjectsController>().reload();

      await tester.pumpWidget(const GetMaterialApp(home: ProfileView()));
      await tester.pumpAndSettle();

      expect(find.text('JP'), findsOneWidget); // Iniciales (dos letras)
      expect(find.text('Juan Pérez'), findsOneWidget); // Nombre
      expect(find.text('Ingeniería · 5.º semestre'), findsOneWidget);
      expect(find.text('1 proyecto activo'), findsOneWidget);
      expect(find.text('Flutter'), findsOneWidget); // Pill de habilidad
      expect(find.text('Dart'), findsOneWidget); // Pill de habilidad
      expect(find.text('Proyecto 1'), findsOneWidget); // Tarjeta compacta
      expect(find.text('Líder · 1 de 3 miembros'), findsOneWidget); // Rol
    });
  });
}
