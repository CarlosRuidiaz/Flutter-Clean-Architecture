import 'package:get/get.dart';
import 'package:loggy/loggy.dart';

import '../../../application/domain/models/application.dart';
import '../../../application/domain/repositories/i_application_repository.dart';
import '../../../profile/domain/models/profile.dart';
import '../../../profile/domain/repositories/i_profile_repository.dart';
import '../../../project/domain/models/project.dart';
import '../../../project/domain/repositories/i_project_repository.dart';
import '../../domain/models/milestone.dart';
import '../../domain/models/progress_update.dart';
import '../../domain/models/project_task.dart';
import '../../domain/repositories/i_workspace_repository.dart';
import 'team_member.dart';

/// Controlador del espacio de trabajo del proyecto: el lugar privado del
/// equipo, distinto del detalle publico.
///
/// El proyecto le llega por [open], tal como lo recibe la pantalla por
/// `Get.arguments`, y despues lo vuelve a pedir a `IProjectRepository` para no
/// trabajar con la foto vieja del contador de miembros o de la etapa. Vive
/// sobre `IWorkspaceRepository` para hitos, avances y tareas, y sobre
/// `IApplicationRepository` e `IProfileRepository` para saber quien es el
/// equipo y quien tiene la sesion.
class WorkspaceController extends GetxController with UiLoggy {
  WorkspaceController(
    this.repository,
    this.applicationRepository,
    this.profileRepository,
    this.projectRepository,
  );

  final IWorkspaceRepository repository;
  final IApplicationRepository applicationRepository;
  final IProfileRepository profileRepository;
  final IProjectRepository projectRepository;

  final Rxn<Project> _project = Rxn<Project>();
  final Rxn<Profile> _profile = Rxn<Profile>();
  final RxList<TeamMember> _members = <TeamMember>[].obs;
  final RxList<Milestone> _milestones = <Milestone>[].obs;
  final RxList<ProgressUpdate> _updates = <ProgressUpdate>[].obs;
  final RxList<ProjectTask> _tasks = <ProjectTask>[].obs;
  final RxBool isLoading = false.obs;

  /// True cuando ya hay algo que enseñar. El spinner a pantalla completa solo
  /// tiene sentido mientras es false: refrescar una lista que ya esta a la
  /// vista no debe reemplazarla por un spinner.
  final RxBool hasData = false.obs;

  /// True si la ultima carga fallo y no hay nada que enseñar.
  final RxBool failed = false.obs;

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

  /// Se calcula, nunca se guarda: sin hitos el avance es 0. Lo que si se guarda
  /// es una foto de este numero dentro de cada avance publicado.
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

  /// Quien puede salir: un miembro aceptado que no es el lider. Un lider no se
  /// va de su propio proyecto.
  bool get canLeave => canEnter && !isLeader;

  /// Hitos sin cumplir: son los que se pueden elegir al publicar un avance.
  List<Milestone> get pendingMilestones =>
      _milestones.where((m) => !m.done).toList();

  /// Se llama cada vez que se abre el espacio de trabajo, no solo al crear el
  /// controlador: como sobrevive a los cambios de sesion (`fenix: true`), si
  /// el perfil se guardara una sola vez otra cuenta heredaria sus permisos.
  ///
  /// Parte de cero: lo que hubiera de otro proyecto o de otra cuenta se borra
  /// antes de pedir nada, para que no se vea ni un instante.
  Future<void> open(Project project) async {
    loggy.debug('WorkspaceController: abriendo el espacio de ${project.id}');
    _project.value = project;
    _profile.value = null;
    _members.clear();
    _milestones.clear();
    _updates.clear();
    _tasks.clear();
    hasData.value = false;
    await _cargar(project);
  }

  /// Vuelve a pedir todo sin vaciar la pantalla: es lo que hace deslizar para
  /// refrescar.
  Future<void> reload() async {
    loggy.debug('WorkspaceController: refrescando el espacio de trabajo');
    final actual = _project.value;
    if (actual == null) return;
    await _cargar(actual);
  }

  Future<void> _cargar(Project project) async {
    isLoading.value = true;
    failed.value = false;
    try {
      _profile.value = await profileRepository.getCurrentProfile();

      final projectId = project.id ?? '';
      _project.value = await _pedirProyecto(projectId) ?? project;
      await _cargarMiembros(projectId);
      _milestones.value = await repository.getMilestones(projectId);
      _updates.value = await repository.getUpdates(projectId);
      _tasks.value = await repository.getTasks(projectId);
      hasData.value = true;
    } catch (e) {
      loggy.error('WorkspaceController: no se pudo cargar: $e');
      failed.value = true;
    } finally {
      isLoading.value = false;
    }
  }

  /// La copia viva del proyecto. `IProjectRepository` no tiene busqueda por id
  /// y es un contrato compartido: se filtra la lista.
  Future<Project?> _pedirProyecto(String projectId) async {
    final proyectos = await projectRepository.getProjects();
    return proyectos.firstWhereOrNull((p) => p.id == projectId);
  }

  Future<void> _cargarMiembros(String projectId) async {
    final project = _project.value;
    if (project == null) return;
    final applications = await applicationRepository.getApplicationsFor(
      projectId,
    );
    _members.value = _buildMembers(project, applications);
  }

  /// Despues de cambiar el equipo o la etapa: el proyecto y los miembros.
  Future<void> _recargarEquipo(String projectId) async {
    final fresco = await _pedirProyecto(projectId);
    if (fresco != null) _project.value = fresco;
    await _cargarMiembros(projectId);
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
            applicationId: a.id,
          ),
        );

    return [lider, ...aceptados];
  }

  /// Un miembro que no es el lider sale del proyecto: su postulacion pasa a
  /// `left` y el contador baja en 1. Devuelve true si salio.
  ///
  /// No recarga el equipo despues: quien sale deja la pantalla, y recargar
  /// primero lo dejaria viendo un instante "sin acceso" detras de la hoja.
  Future<bool> leave() async {
    loggy.debug('WorkspaceController: saliendo del proyecto');
    final projectId = _project.value?.id;
    final me = _profile.value?.id;
    if (projectId == null || me == null || isLeader) return false;

    final yo = _members.firstWhereOrNull((m) => !m.isLeader && m.id == me);
    final applicationId = yo?.applicationId;
    if (applicationId == null) return false;

    await applicationRepository.leave(applicationId);
    await projectRepository.removeMember(projectId);
    return true;
  }

  /// El lider saca a un miembro: su postulacion pasa a `removed` y el contador
  /// baja en 1. Quien queda removido no puede volver a postularse.
  Future<void> removeMember(TeamMember member) async {
    loggy.debug('WorkspaceController: removiendo a ${member.name}');
    final projectId = _project.value?.id;
    final applicationId = member.applicationId;
    if (projectId == null || !isLeader) return;
    if (member.isLeader || applicationId == null) return;

    await applicationRepository.decide(
      applicationId,
      ApplicationStatus.removed,
    );
    await projectRepository.removeMember(projectId);
    await _recargarEquipo(projectId);
  }

  /// El lider cambia la etapa del proyecto entre las seis de [ProjectStage].
  Future<void> updateStage(ProjectStage stage) async {
    loggy.debug('WorkspaceController: cambiando la etapa a ${stage.name}');
    final projectId = _project.value?.id;
    if (projectId == null || !isLeader) return;

    await projectRepository.updateStage(projectId, stage);
    await _recargarEquipo(projectId);
  }

  Future<void> addMilestone(String title, DateTime dueDate) async {
    loggy.debug('WorkspaceController: añadiendo el hito "$title"');
    final projectId = _project.value?.id;
    if (projectId == null || !isLeader) return;

    await repository.addMilestone(
      Milestone(projectId: projectId, title: title, dueDate: dueDate),
    );
    _milestones.value = await repository.getMilestones(projectId);
  }

  Future<void> setMilestoneDone(String milestoneId, bool done) async {
    loggy.debug('WorkspaceController: hito $milestoneId a done=$done');
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
    loggy.debug('WorkspaceController: publicando el avance "$title"');
    final projectId = _project.value?.id;
    if (projectId == null || !canEnter) return;

    // Primero se marca el hito y despues se calcula el porcentaje, para que la
    // foto que se guarda en el avance ya lo incluya. Se llama al repositorio
    // directo y no a setMilestoneDone: cualquier miembro puede cumplir un hito
    // al publicar, aunque solo el lider pueda marcarlo a mano.
    if (milestoneId != null) {
      await repository.setMilestoneDone(milestoneId, true);
      _milestones.value = await repository.getMilestones(projectId);
    }

    await repository.publishUpdate(
      ProgressUpdate(
        projectId: projectId,
        authorId: _profile.value?.id ?? '',
        authorName: _profile.value?.fullName ?? '',
        title: title,
        description: description,
        createdAt: DateTime.now(),
        completionPercentage: progressPercent,
        videoUrl: videoUrl,
        milestoneId: milestoneId,
      ),
    );
    _updates.value = await repository.getUpdates(projectId);
  }

  Future<void> addTask(String title, String assigneeName) async {
    loggy.debug('WorkspaceController: añadiendo la tarea "$title"');
    final projectId = _project.value?.id;
    if (projectId == null || !canEnter) return;

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
    loggy.debug('WorkspaceController: tarea $taskId a done=$done');
    if (!canEnter) return;

    await repository.setTaskDone(taskId, done);
    final projectId = _project.value?.id;
    if (projectId != null) {
      _tasks.value = await repository.getTasks(projectId);
    }
  }
}
