import 'package:f_clean_template/features/application/domain/models/application.dart';
import 'package:f_clean_template/features/application/domain/repositories/i_application_repository.dart';
import 'package:f_clean_template/features/management/ui/viewmodels/management_controller.dart';
import 'package:f_clean_template/features/project/domain/models/project.dart';
import 'package:f_clean_template/features/project/domain/repositories/i_project_repository.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeApplicationRepository implements IApplicationRepository {
  final List<Application> applications = [
    Application(
      id: '1',
      projectId: '2',
      applicantId: 'u7',
      applicantName: 'Mariana Pérez',
      applicantProgram: 'Diseño Industrial',
      applicantSemester: 7,
      skillsOffered: ['Diseño UX'],
      status: ApplicationStatus.pending,
    ),
    Application(
      id: '2',
      projectId: '2',
      applicantId: 'u8',
      applicantName: 'Felipe Gómez',
      applicantProgram: 'Ingeniería de Sistemas',
      applicantSemester: 5,
      skillsOffered: ['Flutter'],
      status: ApplicationStatus.pending,
    ),
  ];

  @override
  Future<List<Application>> getMyApplications(String applicantId) async =>
      throw UnimplementedError();

  @override
  Future<List<Application>> getApplicationsFor(String projectId) async =>
      applications.where((a) => a.projectId == projectId).toList();

  @override
  Future<Application> apply(Application application) async =>
      throw UnimplementedError();

  @override
  Future<void> withdraw(String applicationId) async =>
      throw UnimplementedError();

  @override
  Future<void> decide(String applicationId, ApplicationStatus decision) async {
    final index = applications.indexWhere((a) => a.id == applicationId);
    if (index != -1) {
      applications[index] = applications[index].copyWith(status: decision);
    }
  }
}

class _FakeProjectRepository implements IProjectRepository {
  bool recruitmentOpen = true;

  @override
  Future<List<Project>> getProjects() async => [
        Project(
          id: '2',
          title: 'Plataforma de tutorías entre pares',
          problem: 'Un problema',
          description: 'Una descripcion',
          stage: ProjectStage.idea,
          academicProgram: 'Ingeniería de Sistemas',
          currentMembers: 2,
          maxMembers: 4,
          skillsWanted: ['Flutter'],
          leaderId: '1',
          recruitmentOpen: recruitmentOpen,
        ),
      ];

  @override
  Future<Project> createProject(Project project) async =>
      throw UnimplementedError();

  @override
  Future<void> closeRecruitment(String projectId) async {
    recruitmentOpen = false;
  }
}

void main() {
  group('ManagementController', () {
    late _FakeApplicationRepository applicationRepository;
    late _FakeProjectRepository projectRepository;
    late ManagementController controller;

    setUp(() {
      applicationRepository = _FakeApplicationRepository();
      projectRepository = _FakeProjectRepository();
      controller = ManagementController(
        applicationRepository,
        projectRepository,
      );
    });

    test('getApplicants llena la lista con las del proyecto pedido', () async {
      await controller.getApplicants('2');

      expect(controller.applicants.length, 2);
      expect(controller.project?.id, '2');
    });

    test('pendingCount cuenta solo las pendientes', () async {
      await controller.getApplicants('2');
      await controller.decide('1', ApplicationStatus.accepted);

      expect(controller.pendingCount, 1);
    });

    test(
      'decide con accepted recarga y esa ya no esta pendiente',
      () async {
        await controller.getApplicants('2');
        await controller.decide('1', ApplicationStatus.accepted);

        final decidida = controller.applicants.firstWhere(
          (a) => a.id == '1',
        );
        expect(decidida.status, ApplicationStatus.accepted);
        expect(decidida.isPending, isFalse);
      },
    );

    test('closeRecruitment cierra el reclutamiento y recarga el proyecto', () async {
      await controller.getApplicants('2');
      await controller.closeRecruitment('2');

      expect(controller.project?.recruitmentOpen, isFalse);
    });

    test('isLoading se pone en true y vuelve a false', () async {
      expect(controller.isLoading.value, isFalse);
      final future = controller.getApplicants('2');
      expect(controller.isLoading.value, isTrue);
      await future;
      expect(controller.isLoading.value, isFalse);
    });
  });
}
