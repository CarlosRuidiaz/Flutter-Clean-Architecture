import 'package:f_clean_template/features/application/domain/models/application.dart';
import 'package:f_clean_template/features/application/domain/repositories/i_application_repository.dart';
import 'package:f_clean_template/features/auth/domain/models/authentication_user.dart';
import 'package:f_clean_template/features/auth/domain/repositories/i_auth_repository.dart';
import 'package:f_clean_template/features/profile/domain/models/profile.dart';
import 'package:f_clean_template/features/profile/domain/repositories/i_profile_repository.dart';
import 'package:f_clean_template/features/project/domain/models/project.dart';
import 'package:f_clean_template/features/project/domain/repositories/i_project_repository.dart';
import 'package:f_clean_template/features/my_projects/ui/viewmodels/my_projects_controller.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'dart:async';

class _FakeAuthRepository implements IAuthRepository {
  bool isLogged = true;

  final StreamController<bool> _sessionController = StreamController<bool>.broadcast();

  @override
  Stream<bool> get sessionChanges => _sessionController.stream;

  @override
  Future<AuthenticationUser?> getLoggedUser() async {
    return isLogged ? const AuthenticationUser(id: 'u1', email: 'test@test.com') : null;
  }

  void changeSession(bool logged) {
    isLogged = logged;
    _sessionController.add(logged);
  }

  @override
  Future<bool> login(AuthenticationUser user) async => throw UnimplementedError();
  @override
  Future<bool> restoreSession() async => throw UnimplementedError();
  @override
  Future<bool> signUp(AuthenticationUser user) async => throw UnimplementedError();
  @override
  Future<bool> logOut() async => throw UnimplementedError();
  @override
  Future<bool> validate(String email, String validationCode) async => throw UnimplementedError();
  @override
  Future<bool> validateToken() async => throw UnimplementedError();
  @override
  Future<void> forgotPassword(String email) async => throw UnimplementedError();
}

class _FakeProfileRepository implements IProfileRepository {
  @override
  Future<Profile> getCurrentProfile() async => Profile(
        id: 'u1',
        fullName: 'Test User',
        academicProgram: 'Test',
        semester: 1,
        skills: [],
      );

  @override
  Future<void> saveProfile(Profile profile) async => throw UnimplementedError();
}

class _FakeProjectRepository implements IProjectRepository {
  final projects = [
    Project(id: 'p1', title: 'Liderado', problem: '', description: '', stage: ProjectStage.idea, academicProgram: '', currentMembers: 1, maxMembers: 3, skillsWanted: [], leaderId: 'u1'),
    Project(id: 'p2', title: 'Participa', problem: '', description: '', stage: ProjectStage.idea, academicProgram: '', currentMembers: 1, maxMembers: 3, skillsWanted: [], leaderId: 'u2'),
    Project(id: 'p3', title: 'Rechazado/Pendiente', problem: '', description: '', stage: ProjectStage.idea, academicProgram: '', currentMembers: 1, maxMembers: 3, skillsWanted: [], leaderId: 'u2'),
  ];

  @override
  Future<List<Project>> getProjects() async => projects;

  @override
  Future<Project> createProject(Project project) async => throw UnimplementedError();
  @override
  Future<void> closeRecruitment(String projectId) async => throw UnimplementedError();
  @override
  Future<void> addMember(String projectId) async => throw UnimplementedError();
}

class _FakeApplicationRepository implements IApplicationRepository {
  final List<Application> applications = [
    Application(id: 'a1', projectId: 'p1', applicantId: 'u3', applicantName: 'x', applicantProgram: 'x', applicantSemester: 1, skillsOffered: [], status: ApplicationStatus.pending),
    Application(id: 'a2', projectId: 'p2', applicantId: 'u1', applicantName: 'x', applicantProgram: 'x', applicantSemester: 1, skillsOffered: [], status: ApplicationStatus.accepted),
    Application(id: 'a3', projectId: 'p3', applicantId: 'u1', applicantName: 'x', applicantProgram: 'x', applicantSemester: 1, skillsOffered: [], status: ApplicationStatus.pending),
  ];

  @override
  Future<List<Application>> getMyApplications(String applicantId) async =>
      applications.where((a) => a.applicantId == applicantId).toList();

  @override
  Future<List<Application>> getApplicationsFor(String projectId) async =>
      applications.where((a) => a.projectId == projectId).toList();

  @override
  Future<Application> apply(Application application) async => throw UnimplementedError();
  @override
  Future<void> withdraw(String applicationId) async => throw UnimplementedError();
  @override
  Future<void> decide(String applicationId, ApplicationStatus decision) async => throw UnimplementedError();
}

void main() {
  group('MyProjectsController', () {
    late _FakeAuthRepository authRepo;
    late _FakeProfileRepository profileRepo;
    late _FakeProjectRepository projectRepo;
    late _FakeApplicationRepository appRepo;
    late MyProjectsController controller;

    setUp(() {
      authRepo = _FakeAuthRepository();
      profileRepo = _FakeProfileRepository();
      projectRepo = _FakeProjectRepository();
      appRepo = _FakeApplicationRepository();
      
      controller = MyProjectsController(projectRepo, appRepo, profileRepo, authRepo);
    });

    tearDown(() {
      controller.onClose();
    });

    test('carga inicial separa creados y participando', () async {
      controller.onInit();
      // Esperar a que _loadData termine
      await Future.delayed(const Duration(milliseconds: 50));

      expect(controller.createdProjects.length, 1);
      expect(controller.createdProjects.first.id, 'p1');
      expect(controller.pendingApplicationsCount['p1'], 1);

      expect(controller.participatingProjects.length, 1);
      expect(controller.participatingProjects.first.id, 'p2');
    });

    test('limpia los datos al cerrar sesion y recarga al iniciar', () async {
      controller.onInit();
      await Future.delayed(const Duration(milliseconds: 50));

      expect(controller.createdProjects.isNotEmpty, isTrue);

      authRepo.changeSession(false);
      await Future.delayed(const Duration(milliseconds: 50));

      expect(controller.createdProjects.isEmpty, isTrue);
      expect(controller.participatingProjects.isEmpty, isTrue);

      authRepo.changeSession(true);
      await Future.delayed(const Duration(milliseconds: 50));

      expect(controller.createdProjects.isNotEmpty, isTrue);
    });
  });
}
