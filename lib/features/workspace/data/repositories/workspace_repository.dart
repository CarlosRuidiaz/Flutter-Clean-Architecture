import '../../domain/models/milestone.dart';
import '../../domain/models/progress_update.dart';
import '../../domain/models/project_task.dart';
import '../../domain/repositories/i_workspace_repository.dart';
import '../datasources/i_workspace_source.dart';

class WorkspaceRepository implements IWorkspaceRepository {
  WorkspaceRepository(this.source);

  final IWorkspaceSource source;

  @override
  Future<List<Milestone>> getMilestones(String projectId) async =>
      await source.getMilestones(projectId);

  @override
  Future<Milestone> addMilestone(Milestone milestone) async =>
      await source.addMilestone(milestone);

  @override
  Future<void> setMilestoneDone(String milestoneId, bool done) async =>
      await source.setMilestoneDone(milestoneId, done);

  @override
  Future<List<ProgressUpdate>> getUpdates(String projectId) async =>
      await source.getUpdates(projectId);

  @override
  Future<ProgressUpdate> publishUpdate(ProgressUpdate update) async =>
      await source.publishUpdate(update);

  @override
  Future<List<ProjectTask>> getTasks(String projectId) async =>
      await source.getTasks(projectId);

  @override
  Future<ProjectTask> addTask(ProjectTask task) async =>
      await source.addTask(task);

  @override
  Future<void> setTaskDone(String taskId, bool done) async =>
      await source.setTaskDone(taskId, done);
}
