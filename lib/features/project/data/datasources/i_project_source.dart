import '../../domain/models/project.dart';

abstract class IProjectSource {
  Future<List<Project>> getProjects();

  Future<Project> createProject(Project project);

  Future<void> closeRecruitment(String projectId);
}
