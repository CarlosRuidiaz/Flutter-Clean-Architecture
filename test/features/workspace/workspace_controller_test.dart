import 'package:f_clean_template/features/application/domain/models/application.dart';
import 'package:f_clean_template/features/application/domain/repositories/i_application_repository.dart';
import 'package:f_clean_template/features/profile/domain/models/profile.dart';
import 'package:f_clean_template/features/profile/domain/repositories/i_profile_repository.dart';
import 'package:f_clean_template/features/project/domain/models/project.dart';
import 'package:f_clean_template/features/workspace/domain/models/milestone.dart';
import 'package:f_clean_template/features/workspace/domain/models/progress_update.dart';
import 'package:f_clean_template/features/workspace/domain/models/project_task.dart';
import 'package:f_clean_template/features/workspace/domain/repositories/i_workspace_repository.dart';
import 'package:f_clean_template/features/workspace/ui/viewmodels/workspace_controller.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeWorkspaceRepository implements IWorkspaceRepository {
  final List<Milestone> milestones = [];
  final List<ProgressUpdate> updates = [];
  final List<ProjectTask> tasks = [];
  int _nextId = 1;

  @override
  Future<List<Milestone>> getMilestones(String projectId) async =>
      milestones.where((m) => m.projectId == projectId).toList();

  @override
  Future<Milestone> addMilestone(Milestone milestone) async {
    final creado = Milestone(
      id: '${_nextId++}',
      projectId: milestone.projectId,
      title: milestone.title,
      dueDate: milestone.dueDate,
      done: milestone.done,
    );
    milestones.add(creado);
    return creado;
  }

  @override
  Future<void> setMilestoneDone(String milestoneId, bool done) async {
    final index = milestones.indexWhere((m) => m.id == milestoneId);
    if (index != -1) {
      milestones[index] = milestones[index].copyWith(done: done);
    }
  }

  @override
  Future<List<ProgressUpdate>> getUpdates(String projectId) async =>
      updates.where((u) => u.projectId == projectId).toList();

  @override
  Future<ProgressUpdate> publishUpdate(ProgressUpdate update) async {
    updates.add(update);
    final milestoneId = update.milestoneId;
    if (milestoneId != null) {
      await setMilestoneDone(milestoneId, true);
    }
    return update;
  }

  @override
  Future<List<ProjectTask>> getTasks(String projectId) async =>
      tasks.where((t) => t.projectId == projectId).toList();

  @override
  Future<ProjectTask> addTask(ProjectTask task) async {
    tasks.add(task);
    return task;
  }

  @override
  Future<void> setTaskDone(String taskId, bool done) async {
    final index = tasks.indexWhere((t) => t.id == taskId);
    if (index != -1) {
      tasks[index] = tasks[index].copyWith(done: done);
    }
  }
}

class _FakeApplicationRepository implements IApplicationRepository {
  List<Application> applications = [];

  @override
  Future<List<Application>> getApplicationsFor(String projectId) async =>
      applications.where((a) => a.projectId == projectId).toList();

  @override
  Future<List<Application>> getMyApplications(String applicantId) async =>
      throw UnimplementedError();

  @override
  Future<Application> apply(Application application) async =>
      throw UnimplementedError();

  @override
  Future<void> withdraw(String applicationId) async =>
      throw UnimplementedError();

  @override
  Future<void> decide(
    String applicationId,
    ApplicationStatus decision,
  ) async =>
      throw UnimplementedError();
}

class _FakeProfileRepository implements IProfileRepository {
  Profile current = _liderProfile;

  @override
  Future<Profile> getCurrentProfile() async => current;
}

const String _liderId = 'leader';
const String _miembroId = 'member1';

final Profile _liderProfile = Profile(
  id: _liderId,
  fullName: 'Ana Líder',
  academicProgram: 'Ingeniería de Sistemas',
  semester: 8,
  skills: const [],
);

final Profile _miembroProfile = Profile(
  id: _miembroId,
  fullName: 'Miembro Aceptado',
  academicProgram: 'Diseño Industrial',
  semester: 5,
  skills: const [],
);

final Profile _visitanteProfile = Profile(
  id: 'visitante',
  fullName: 'Alguien Mas',
  academicProgram: 'Psicología',
  semester: 3,
  skills: const [],
);

final Project _project = Project(
  id: 'p1',
  title: 'Proyecto de prueba',
  problem: 'Un problema',
  description: 'Una descripcion',
  stage: ProjectStage.idea,
  academicProgram: 'Ingeniería de Sistemas',
  currentMembers: 2,
  maxMembers: 4,
  skillsWanted: const [],
  leaderId: _liderId,
);

void main() {
  group('WorkspaceController', () {
    late _FakeWorkspaceRepository workspaceRepository;
    late _FakeApplicationRepository applicationRepository;
    late _FakeProfileRepository profileRepository;
    late WorkspaceController controller;

    setUp(() {
      workspaceRepository = _FakeWorkspaceRepository();
      applicationRepository = _FakeApplicationRepository()
        ..applications = [
          Application(
            id: 'a1',
            projectId: 'p1',
            applicantId: _miembroId,
            applicantName: _miembroProfile.fullName,
            applicantProgram: _miembroProfile.academicProgram,
            applicantSemester: _miembroProfile.semester,
            skillsOffered: const [],
            status: ApplicationStatus.accepted,
          ),
        ];
      profileRepository = _FakeProfileRepository();
      controller = WorkspaceController(
        workspaceRepository,
        applicationRepository,
        profileRepository,
      );
    });

    test('sin hitos el porcentaje es 0', () async {
      await controller.open(_project);

      expect(controller.totalMilestones, 0);
      expect(controller.progressPercent, 0);
    });

    test('con algunos hitos cumplidos el porcentaje es proporcional', () async {
      await controller.open(_project);
      await controller.addMilestone('Hito 1', DateTime(2026, 1, 1));
      await controller.addMilestone('Hito 2', DateTime(2026, 2, 1));
      await controller.addMilestone('Hito 3', DateTime(2026, 3, 1));

      await controller.setMilestoneDone(controller.milestones.first.id!, true);

      expect(controller.progressPercent, 33);
    });

    test('con todos los hitos cumplidos el porcentaje es 100', () async {
      await controller.open(_project);
      await controller.addMilestone('Hito 1', DateTime(2026, 1, 1));
      await controller.addMilestone('Hito 2', DateTime(2026, 2, 1));

      for (final hito in controller.milestones) {
        await controller.setMilestoneDone(hito.id!, true);
      }

      expect(controller.progressPercent, 100);
    });

    test('solo el lider puede marcar un hito como cumplido', () async {
      await controller.open(_project);
      await controller.addMilestone('Hito 1', DateTime(2026, 1, 1));
      final String hitoId = controller.milestones.first.id!;

      // El miembro aceptado no es el lider: no puede marcarlo.
      profileRepository.current = _miembroProfile;
      await controller.open(_project);
      await controller.setMilestoneDone(hitoId, true);
      expect(controller.milestones.first.done, isFalse);

      // El lider si puede.
      profileRepository.current = _liderProfile;
      await controller.open(_project);
      await controller.setMilestoneDone(hitoId, true);
      expect(controller.milestones.first.done, isTrue);
    });

    test(
      'publicar un avance que cumple un hito lo marca y sube el porcentaje',
      () async {
        await controller.open(_project);
        await controller.addMilestone('Hito 1', DateTime(2026, 1, 1));
        await controller.addMilestone('Hito 2', DateTime(2026, 2, 1));
        final String hitoId = controller.milestones.first.id!;
        expect(controller.progressPercent, 0);

        await controller.publishUpdate(
          title: 'Primer avance',
          description: 'Se completo el primer hito',
          milestoneId: hitoId,
        );

        expect(controller.updates.length, 1);
        expect(
          controller.milestones.firstWhere((m) => m.id == hitoId).done,
          isTrue,
        );
        expect(controller.progressPercent, 50);
      },
    );

    test('canEnter es true para el lider y para un miembro aceptado', () async {
      await controller.open(_project);
      expect(controller.isLeader, isTrue);
      expect(controller.canEnter, isTrue);

      profileRepository.current = _miembroProfile;
      await controller.open(_project);
      expect(controller.isLeader, isFalse);
      expect(controller.canEnter, isTrue);
    });

    test('canEnter es false para quien no lidera ni fue aceptado', () async {
      profileRepository.current = _visitanteProfile;
      await controller.open(_project);

      expect(controller.canEnter, isFalse);
    });

    test('addMilestone no hace nada si quien llama no es el lider', () async {
      profileRepository.current = _miembroProfile;
      await controller.open(_project);

      await controller.addMilestone('Hito intruso', DateTime(2026, 1, 1));

      expect(controller.milestones, isEmpty);
    });
  });
}
