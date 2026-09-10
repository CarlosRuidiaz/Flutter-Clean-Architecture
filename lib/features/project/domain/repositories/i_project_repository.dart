import '../models/project.dart';

abstract class IProjectRepository {
  Future<List<Project>> getProjects();

  Future<Project> createProject(Project project);

  Future<void> closeRecruitment(String projectId);
}
