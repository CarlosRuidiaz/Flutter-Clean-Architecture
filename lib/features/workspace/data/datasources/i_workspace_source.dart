import '../../domain/models/milestone.dart';
import '../../domain/models/progress_update.dart';
import '../../domain/models/project_task.dart';

abstract class IWorkspaceSource {
  Future<List<Milestone>> getMilestones(String projectId);

  Future<Milestone> addMilestone(Milestone milestone);

  Future<void> setMilestoneDone(String milestoneId, bool done);

  Future<List<ProgressUpdate>> getUpdates(String projectId);

  Future<ProgressUpdate> publishUpdate(ProgressUpdate update);

  Future<List<ProjectTask>> getTasks(String projectId);

  Future<ProjectTask> addTask(ProjectTask task);

  Future<void> setTaskDone(String taskId, bool done);
}
