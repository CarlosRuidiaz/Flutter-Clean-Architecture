import '../models/milestone.dart';
import '../models/progress_update.dart';
import '../models/project_task.dart';

abstract class IWorkspaceRepository {
  Future<List<Milestone>> getMilestones(String projectId);

  Future<Milestone> addMilestone(Milestone milestone);

  Future<void> setMilestoneDone(String milestoneId, bool done);

  /// El mas reciente primero.
  Future<List<ProgressUpdate>> getUpdates(String projectId);

  /// Si [ProgressUpdate.milestoneId] viene informado, marca ese hito cumplido.
  Future<ProgressUpdate> publishUpdate(ProgressUpdate update);

  Future<List<ProjectTask>> getTasks(String projectId);

  Future<ProjectTask> addTask(ProjectTask task);

  Future<void> setTaskDone(String taskId, bool done);
}
