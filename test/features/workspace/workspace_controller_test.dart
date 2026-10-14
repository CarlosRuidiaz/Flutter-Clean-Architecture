import 'package:f_clean_template/features/application/domain/models/application.dart';
import 'package:f_clean_template/features/application/domain/repositories/i_application_repository.dart';
import 'package:f_clean_template/features/profile/domain/models/profile.dart';
import 'package:f_clean_template/features/profile/domain/repositories/i_profile_repository.dart';
import 'package:f_clean_template/features/project/domain/models/project.dart';
import 'package:f_clean_template/features/project/domain/repositories/i_project_repository.dart';
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

  void _cambiar(String applicationId, ApplicationStatus status) {
    final index = applications.indexWhere((a) => a.id == applicationId);
    if (index != -1) {
      applications[index] = applications[index].copyWith(status: status);
    }
  }

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
  Future<void> leave(String applicationId) async =>
      _cambiar(applicationId, ApplicationStatus.left);

  @override
  Future<void> decide(
    String applicationId,
    ApplicationStatus decision,
  ) async => _cambiar(applicationId, decision);
}

class _FakeProfileRepository implements IProfileRepository {
  Profile current = _liderProfile;

  @override
  Future<Profile> getCurrentProfile() async => current;
}

class _FakeProjectRepository implements IProjectRepository {
  _FakeProjectRepository(this.project);

  Project project;

  @override
  Future<List<Project>> getProjects() async => [project];

  @override
  Future<Project> createProject(Project project) async =>
      throw UnimplementedError();

  @override
  Future<void> closeRecruitment(String projectId) async =>
      throw UnimplementedError();

  @override
  Future<void> addMember(String projectId) async =>
      throw UnimplementedError();

  @override
  Future<void> removeMember(String projectId) async {
    if (project.currentMembers > 1) {
      project = project.copyWith(currentMembers: project.currentMembers - 1);
    }
  }

  @override
  Future<void> updateStage(String projectId, ProjectStage stage) async {
    project = Project(
      id: project.id,
      title: project.title,
      problem: project.problem,
      description: project.description,
      stage: stage,
      academicProgram: project.academicProgram,
      currentMembers: project.currentMembers,
      maxMembers: project.maxMembers,
      skillsWanted: project.skillsWanted,
      leaderId: project.leaderId,
    );
  }
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

Project _proyecto() => Project(
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
    late _FakeProjectRepository projectRepository;
    late WorkspaceController controller;
    late Project project;

    setUp(() {
      project = _proyecto();
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
      projectRepository = _FakeProjectRepository(project);
      controller = WorkspaceController(
        workspaceRepository,
        applicationRepository,
        profileRepository,
        projectRepository,
      );
    });

    ApplicationStatus estadoDe(String applicationId) => applicationRepository
        .applications
        .firstWhere((a) => a.id == applicationId)
        .status;

    group('porcentaje', () {
      test('sin hitos el porcentaje es 0', () async {
        await controller.open(project);

        expect(controller.totalMilestones, 0);
        expect(controller.progressPercent, 0);
      });

      test('con algunos hitos cumplidos es proporcional', () async {
        await controller.open(project);
        await controller.addMilestone('Hito 1', DateTime(2026, 1, 1));
        await controller.addMilestone('Hito 2', DateTime(2026, 2, 1));
        await controller.addMilestone('Hito 3', DateTime(2026, 3, 1));

        await controller.setMilestoneDone(
          controller.milestones.first.id!,
          true,
        );

        expect(controller.progressPercent, 33);
      });

      test('con todos los hitos cumplidos es 100', () async {
        await controller.open(project);
        await controller.addMilestone('Hito 1', DateTime(2026, 1, 1));
        await controller.addMilestone('Hito 2', DateTime(2026, 2, 1));

        for (final hito in controller.milestones) {
          await controller.setMilestoneDone(hito.id!, true);
        }

        expect(controller.progressPercent, 100);
      });
    });

    group('hitos', () {
      test('solo el lider puede marcar un hito como cumplido', () async {
        await controller.open(project);
        await controller.addMilestone('Hito 1', DateTime(2026, 1, 1));
        final String hitoId = controller.milestones.first.id!;

        // El miembro aceptado no es el lider: no puede marcarlo.
        profileRepository.current = _miembroProfile;
        await controller.open(project);
        await controller.setMilestoneDone(hitoId, true);
        expect(controller.milestones.first.done, isFalse);

        // El lider si puede.
        profileRepository.current = _liderProfile;
        await controller.open(project);
        await controller.setMilestoneDone(hitoId, true);
        expect(controller.milestones.first.done, isTrue);
      });

      test('addMilestone no hace nada si quien llama no es el lider', () async {
        profileRepository.current = _miembroProfile;
        await controller.open(project);

        await controller.addMilestone('Hito intruso', DateTime(2026, 1, 1));

        expect(controller.milestones, isEmpty);
      });
    });

    group('avances', () {
      test(
        'publicar un avance que cumple un hito lo marca y sube el porcentaje',
        () async {
          await controller.open(project);
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

      test(
        'el porcentaje guardado en el avance ya incluye el hito que cumple',
        () async {
          await controller.open(project);
          await controller.addMilestone('Hito 1', DateTime(2026, 1, 1));
          await controller.addMilestone('Hito 2', DateTime(2026, 2, 1));

          await controller.publishUpdate(
            title: 'Cumplo el primero',
            description: 'Con hito',
            milestoneId: controller.milestones.first.id,
          );

          // 1 de 2: la foto dice 50, no 0 (que era el porcentaje de antes).
          expect(controller.updates.single.completionPercentage, 50);
        },
      );

      test('un avance sin hito guarda el porcentaje que ya habia', () async {
        await controller.open(project);
        await controller.addMilestone('Hito 1', DateTime(2026, 1, 1));
        await controller.setMilestoneDone(controller.milestones.first.id!, true);

        await controller.publishUpdate(
          title: 'Sin hito',
          description: 'No cumple ninguno',
        );

        expect(controller.updates.single.completionPercentage, 100);
        expect(controller.updates.single.milestoneId, isNull);
      });

      test('sin hitos el avance guarda 0, no un numero inventado', () async {
        await controller.open(project);

        await controller.publishUpdate(title: 'Primero', description: 'Hola');

        expect(controller.updates.single.completionPercentage, 0);
      });

      test('un miembro que no es el lider puede cumplir un hito al publicar',
          () async {
        await controller.open(project);
        await controller.addMilestone('Hito 1', DateTime(2026, 1, 1));
        final String hitoId = controller.milestones.first.id!;

        profileRepository.current = _miembroProfile;
        await controller.open(project);
        await controller.publishUpdate(
          title: 'Lo logre',
          description: 'Listo',
          milestoneId: hitoId,
        );

        expect(controller.milestones.single.done, isTrue);
        expect(controller.updates.single.completionPercentage, 100);
      });

      test('un visitante no puede publicar', () async {
        profileRepository.current = _visitanteProfile;
        await controller.open(project);

        await controller.publishUpdate(title: 'Intruso', description: 'No');

        expect(controller.updates, isEmpty);
      });
    });

    group('quien entra', () {
      test('canEnter es true para el lider y para un miembro aceptado',
          () async {
        await controller.open(project);
        expect(controller.isLeader, isTrue);
        expect(controller.canEnter, isTrue);

        profileRepository.current = _miembroProfile;
        await controller.open(project);
        expect(controller.isLeader, isFalse);
        expect(controller.canEnter, isTrue);
      });

      test('canEnter es false para quien no lidera ni fue aceptado', () async {
        profileRepository.current = _visitanteProfile;
        await controller.open(project);

        expect(controller.canEnter, isFalse);
      });

      test('un miembro removido ya no puede entrar', () async {
        applicationRepository.decide('a1', ApplicationStatus.removed);
        profileRepository.current = _miembroProfile;

        await controller.open(project);

        expect(controller.canEnter, isFalse);
      });

      test('abrir otro espacio no deja ver lo del anterior', () async {
        await controller.open(project);
        await controller.addMilestone('Hito 1', DateTime(2026, 1, 1));
        expect(controller.milestones, isNotEmpty);

        final otro = Project(
          id: 'p2',
          title: 'Otro',
          problem: '',
          description: '',
          stage: ProjectStage.idea,
          academicProgram: '',
          currentMembers: 1,
          maxMembers: 3,
          skillsWanted: const [],
          leaderId: 'otro-lider',
        );
        final abriendo = controller.open(otro);

        // Antes de que lleguen los datos ya no hay nada del proyecto anterior.
        expect(controller.milestones, isEmpty);
        expect(controller.hasData.value, isFalse);
        await abriendo;
        expect(controller.milestones, isEmpty);
      });

      test('recargar no vacia lo que ya se ve', () async {
        await controller.open(project);
        await controller.addMilestone('Hito 1', DateTime(2026, 1, 1));

        final recargando = controller.reload();
        expect(controller.hasData.value, isTrue);
        expect(controller.milestones, isNotEmpty);
        await recargando;
        expect(controller.milestones.length, 1);
      });
    });

    group('salir del proyecto', () {
      test('un miembro que no lidera sale: queda en left y el contador baja',
          () async {
        profileRepository.current = _miembroProfile;
        await controller.open(project);
        expect(controller.canLeave, isTrue);
        expect(controller.project?.currentMembers, 2);

        final salio = await controller.leave();

        expect(salio, isTrue);
        expect(estadoDe('a1'), ApplicationStatus.left);
        expect(projectRepository.project.currentMembers, 1);
      });

      test('el lider no puede salir de su propio proyecto', () async {
        await controller.open(project);
        expect(controller.canLeave, isFalse);

        final salio = await controller.leave();

        expect(salio, isFalse);
        expect(estadoDe('a1'), ApplicationStatus.accepted);
        expect(projectRepository.project.currentMembers, 2);
      });

      test('un visitante no puede salir de lo que no es suyo', () async {
        profileRepository.current = _visitanteProfile;
        await controller.open(project);

        final salio = await controller.leave();

        expect(salio, isFalse);
        expect(projectRepository.project.currentMembers, 2);
      });

      test('el contador nunca baja de 1, que es el lider', () async {
        profileRepository.current = _miembroProfile;
        await controller.open(project);
        projectRepository.project = projectRepository.project.copyWith(
          currentMembers: 1,
        );

        await controller.leave();

        expect(projectRepository.project.currentMembers, 1);
      });
    });

    group('remover miembros y cambiar la etapa', () {
      test('el lider remueve: queda en removed y el contador baja', () async {
        await controller.open(project);
        final miembro = controller.members.firstWhere((m) => !m.isLeader);

        await controller.removeMember(miembro);

        expect(estadoDe('a1'), ApplicationStatus.removed);
        expect(projectRepository.project.currentMembers, 1);
        // El equipo recargado ya no lo incluye.
        expect(controller.members.where((m) => !m.isLeader), isEmpty);
        expect(controller.project?.currentMembers, 1);
      });

      test('un miembro no puede remover a nadie', () async {
        profileRepository.current = _miembroProfile;
        await controller.open(project);
        final miembro = controller.members.firstWhere((m) => !m.isLeader);

        await controller.removeMember(miembro);

        expect(estadoDe('a1'), ApplicationStatus.accepted);
        expect(projectRepository.project.currentMembers, 2);
      });

      test('el lider no se puede remover a si mismo', () async {
        await controller.open(project);
        final lider = controller.members.firstWhere((m) => m.isLeader);

        await controller.removeMember(lider);

        expect(projectRepository.project.currentMembers, 2);
      });

      test('el lider cambia la etapa y el controlador la recarga', () async {
        await controller.open(project);

        await controller.updateStage(ProjectStage.research);

        expect(projectRepository.project.stage, ProjectStage.research);
        expect(controller.project?.stage, ProjectStage.research);
      });

      test('un miembro no puede cambiar la etapa', () async {
        profileRepository.current = _miembroProfile;
        await controller.open(project);

        await controller.updateStage(ProjectStage.finished);

        expect(projectRepository.project.stage, ProjectStage.idea);
      });
    });
  });
}
