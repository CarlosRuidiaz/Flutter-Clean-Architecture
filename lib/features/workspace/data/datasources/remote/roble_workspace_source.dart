import 'package:loggy/loggy.dart';
import 'package:roble/roble.dart';

import '../../../domain/models/milestone.dart';
import '../../../domain/models/progress_update.dart';
import '../../../domain/models/project_task.dart';
import '../i_workspace_source.dart';

/// El espacio de trabajo contra Roble: tablas `milestones`,
/// `progress_updates` y `tasks`. Cada lectura filtra por `project_id`.
class RobleWorkspaceSource with UiLoggy implements IWorkspaceSource {
  RobleWorkspaceSource(this.roble);

  final RobleApiDataBase roble;

  @override
  Future<List<Milestone>> getMilestones(String projectId) async {
    loggy.debug('RobleWorkspaceSource.getMilestones: proyecto $projectId');
    final records = await roble.read(
      'milestones',
      filters: {'project_id': projectId},
    );
    return records.map(Milestone.fromJson).toList();
  }

  @override
  Future<Milestone> addMilestone(Milestone milestone) async {
    loggy.debug('RobleWorkspaceSource.addMilestone: ${milestone.title}');
    final record = await roble.create('milestones', milestone.toJsonNoId());
    return Milestone.fromJson(record);
  }

  @override
  Future<void> setMilestoneDone(String milestoneId, bool done) async {
    loggy.debug('RobleWorkspaceSource.setMilestoneDone: $milestoneId = $done');
    await roble.update('milestones', milestoneId, {'done': done});
  }

  @override
  Future<List<ProgressUpdate>> getUpdates(String projectId) async {
    loggy.debug('RobleWorkspaceSource.getUpdates: proyecto $projectId');
    final records = await roble.read(
      'progress_updates',
      filters: {'project_id': projectId},
    );
    final avances = records.map(ProgressUpdate.fromJson).toList();
    avances.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return avances;
  }

  @override
  Future<ProgressUpdate> publishUpdate(ProgressUpdate update) async {
    loggy.debug('RobleWorkspaceSource.publishUpdate: ${update.title}');
    final record = await roble.create(
      'progress_updates',
      update.toJsonNoId(),
    );

    final milestoneId = update.milestoneId;
    if (milestoneId != null) {
      await setMilestoneDone(milestoneId, true);
    }
    return ProgressUpdate.fromJson(record);
  }

  @override
  Future<List<ProjectTask>> getTasks(String projectId) async {
    loggy.debug('RobleWorkspaceSource.getTasks: proyecto $projectId');
    final records = await roble.read(
      'tasks',
      filters: {'project_id': projectId},
    );
    return records.map(ProjectTask.fromJson).toList();
  }

  @override
  Future<ProjectTask> addTask(ProjectTask task) async {
    loggy.debug('RobleWorkspaceSource.addTask: ${task.title}');
    final record = await roble.create('tasks', task.toJsonNoId());
    return ProjectTask.fromJson(record);
  }

  @override
  Future<void> setTaskDone(String taskId, bool done) async {
    loggy.debug('RobleWorkspaceSource.setTaskDone: $taskId = $done');
    await roble.update('tasks', taskId, {'done': done});
  }
}
