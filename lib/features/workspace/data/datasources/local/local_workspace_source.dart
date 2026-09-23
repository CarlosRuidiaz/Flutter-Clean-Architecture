import '../../../domain/models/milestone.dart';
import '../../../domain/models/progress_update.dart';
import '../../../domain/models/project_task.dart';
import '../i_workspace_source.dart';

/// Fuente de datos local en memoria para el espacio de trabajo.
///
/// Empieza vacia a proposito: los proyectos van a pasar pronto a tener
/// identificadores del servidor, y unos datos de prueba atados a los de hoy
/// dejarian de coincidir. Se pierde al cerrar la app, y eso es lo esperado
/// por ahora: cuando entre el backend, esta clase se cambia por una de Roble
/// sin tocar el repositorio ni el controlador.
class LocalWorkspaceSource implements IWorkspaceSource {
  final List<Milestone> _milestones = [];
  final List<ProgressUpdate> _updates = [];
  final List<ProjectTask> _tasks = [];

  int _nextMilestoneId = 1;
  int _nextUpdateId = 1;
  int _nextTaskId = 1;

  @override
  Future<List<Milestone>> getMilestones(String projectId) async =>
      _milestones.where((m) => m.projectId == projectId).toList();

  @override
  Future<Milestone> addMilestone(Milestone milestone) async {
    final creado = Milestone(
      id: '${_nextMilestoneId++}',
      projectId: milestone.projectId,
      title: milestone.title,
      dueDate: milestone.dueDate,
      done: milestone.done,
    );
    _milestones.add(creado);
    return creado;
  }

  @override
  Future<void> setMilestoneDone(String milestoneId, bool done) async {
    final index = _milestones.indexWhere((m) => m.id == milestoneId);
    if (index != -1) {
      _milestones[index] = _milestones[index].copyWith(done: done);
    }
  }

  @override
  Future<List<ProgressUpdate>> getUpdates(String projectId) async {
    final propios =
        _updates.where((u) => u.projectId == projectId).toList();
    propios.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return propios;
  }

  @override
  Future<ProgressUpdate> publishUpdate(ProgressUpdate update) async {
    final creado = ProgressUpdate(
      id: '${_nextUpdateId++}',
      projectId: update.projectId,
      authorId: update.authorId,
      authorName: update.authorName,
      title: update.title,
      description: update.description,
      createdAt: update.createdAt,
      videoUrl: update.videoUrl,
      milestoneId: update.milestoneId,
    );
    _updates.add(creado);

    final milestoneId = update.milestoneId;
    if (milestoneId != null) {
      await setMilestoneDone(milestoneId, true);
    }
    return creado;
  }

  @override
  Future<List<ProjectTask>> getTasks(String projectId) async =>
      _tasks.where((t) => t.projectId == projectId).toList();

  @override
  Future<ProjectTask> addTask(ProjectTask task) async {
    final creada = ProjectTask(
      id: '${_nextTaskId++}',
      projectId: task.projectId,
      title: task.title,
      assigneeName: task.assigneeName,
      done: task.done,
    );
    _tasks.add(creada);
    return creada;
  }

  @override
  Future<void> setTaskDone(String taskId, bool done) async {
    final index = _tasks.indexWhere((t) => t.id == taskId);
    if (index != -1) {
      _tasks[index] = _tasks[index].copyWith(done: done);
    }
  }
}
