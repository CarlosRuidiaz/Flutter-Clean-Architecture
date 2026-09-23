import 'package:get/get.dart';
import 'package:loggy/loggy.dart';

import '../../../application/domain/models/application.dart';
import '../../../application/domain/repositories/i_application_repository.dart';
import '../../../profile/domain/models/profile.dart';
import '../../../profile/domain/repositories/i_profile_repository.dart';
import '../../../project/domain/models/project.dart';
import '../../domain/models/milestone.dart';
import '../../domain/models/progress_update.dart';
import '../../domain/models/project_task.dart';
import '../../domain/repositories/i_workspace_repository.dart';
import 'team_member.dart';

/// Controlador del espacio de trabajo del proyecto: el lugar privado del
/// equipo, distinto del detalle publico.
///
/// No tiene `IProjectRepository`: el proyecto le llega por [open], tal como lo
/// recibe la pantalla por `Get.arguments`. Vive sobre `IWorkspaceRepository`
/// para hitos, avances y tareas, y sobre `IApplicationRepository` e
/// `IProfileRepository` para saber quien es el equipo y quien tiene la sesion.
class WorkspaceController extends GetxController with UiLoggy {
  WorkspaceController(
    this.repository,
    this.applicationRepository,
    this.profileRepository,
  );

  final IWorkspaceRepository repository;
  final IApplicationRepository applicationRepository;
  final IProfileRepository profileRepository;

  final Rxn<Project> _project = Rxn<Project>();
  final Rxn<Profile> _profile = Rxn<Profile>();
  final RxList<TeamMember> _members = <TeamMember>[].obs;
  final RxList<Milestone> _milestones = <Milestone>[].obs;
  final RxList<ProgressUpdate> _updates = <ProgressUpdate>[].obs;
  final RxList<ProjectTask> _tasks = <ProjectTask>[].obs;
  final RxBool isLoading = false.obs;

  /// Que pestania esta activa. Vive aqui, no en el widget, para que publicar
  /// un avance pueda dejar al volver la pestania de avances al frente.
  final RxInt tabIndex = 0.obs;

  Project? get project => _project.value;
  Profile? get profile => _profile.value;
  List<TeamMember> get members => _members;
  List<Milestone> get milestones => _milestones;

  /// El mas reciente primero: asi lo entrega ya el repositorio.
  List<ProgressUpdate> get updates => _updates;
  List<ProjectTask> get tasks => _tasks;

  int get totalMilestones => _milestones.length;
  int get completedMilestones => _milestones.where((m) => m.done).length;

  /// Se calcula, nunca se guarda: sin hitos el avance es 0.
  int get progressPercent => totalMilestones == 0
      ? 0
      : ((completedMilestones / totalMilestones) * 100).round();

  bool get isLeader =>
      _profile.value != null &&
      _project.value != null &&
      _profile.value!.id == _project.value!.leaderId;

  /// El lider y los miembros aceptados. Nadie mas.
  bool get canEnter {
    final me = _profile.value?.id;
    if (me == null) return false;
    return isLeader || _members.any((m) => !m.isLeader && m.id == me);
  }

  /// Hitos sin cumplir: son los que se pueden elegir al publicar un avance.
  List<Milestone> get pendingMilestones =>
      _milestones.where((m) => !m.done).toList();

  /// Se llama cada vez que se abre el espacio de trabajo, no solo al crear el
  /// controlador: como sobrevive a los cambios de sesion (`fenix: true`), si
  /// el perfil se guardara una sola vez otra cuenta heredaria sus permisos.
  Future<void> open(Project project) async {
    loggy.debug('WorkspaceController: abriendo el espacio de ${project.id}');
    isLoading.value = true;
    _project.value = project;
    _profile.value = await profileRepository.getCurrentProfile();

    final projectId = project.id ?? '';
    final applications = await applicationRepository.getApplicationsFor(
      projectId,
    );
    _members.value = _buildMembers(project, applications);
    _milestones.value = await repository.getMilestones(projectId);
    _updates.value = await repository.getUpdates(projectId);
    _tasks.value = await repository.getTasks(projectId);
    isLoading.value = false;
  }

  List<TeamMember> _buildMembers(
    Project project,
    List<Application> applications,
  ) {
    final me = _profile.value;
    final esLiderQuienMira = me?.id == project.leaderId;

    final lider = TeamMember(
      id: project.leaderId,
      name: esLiderQuienMira ? me!.fullName : 'Líder del proyecto',
      academicProgram: esLiderQuienMira ? me!.academicProgram : '',
      isLeader: true,
    );

    final aceptados = applications
        .where((a) => a.status == ApplicationStatus.accepted)
        .map(
          (a) => TeamMember(
            id: a.applicantId,
            name: a.applicantName,
            academicProgram: a.applicantProgram,
            isLeader: false,
          ),
        );

    return [lider, ...aceptados];
  }

  Future<void> addMilestone(String title, DateTime dueDate) async {
    final projectId = _project.value?.id;
    if (projectId == null || !isLeader) return;

    await repository.addMilestone(
      Milestone(projectId: projectId, title: title, dueDate: dueDate),
    );
    _milestones.value = await repository.getMilestones(projectId);
  }

  Future<void> setMilestoneDone(String milestoneId, bool done) async {
    if (!isLeader) return;

    await repository.setMilestoneDone(milestoneId, done);
    final projectId = _project.value?.id;
    if (projectId != null) {
      _milestones.value = await repository.getMilestones(projectId);
    }
  }

  Future<void> publishUpdate({
    required String title,
    required String description,
    String? videoUrl,
    String? milestoneId,
  }) async {
    final projectId = _project.value?.id;
    if (projectId == null) return;

    await repository.publishUpdate(
      ProgressUpdate(
        projectId: projectId,
        authorId: _profile.value?.id ?? '',
        authorName: _profile.value?.fullName ?? '',
        title: title,
        description: description,
        createdAt: DateTime.now(),
        videoUrl: videoUrl,
        milestoneId: milestoneId,
      ),
    );
    _updates.value = await repository.getUpdates(projectId);
    if (milestoneId != null) {
      _milestones.value = await repository.getMilestones(projectId);
    }
  }

  Future<void> addTask(String title, String assigneeName) async {
    final projectId = _project.value?.id;
    if (projectId == null) return;

    await repository.addTask(
      ProjectTask(
        projectId: projectId,
        title: title,
        assigneeName: assigneeName,
      ),
    );
    _tasks.value = await repository.getTasks(projectId);
  }

  Future<void> setTaskDone(String taskId, bool done) async {
    await repository.setTaskDone(taskId, done);
    final projectId = _project.value?.id;
    if (projectId != null) {
      _tasks.value = await repository.getTasks(projectId);
    }
  }
}
