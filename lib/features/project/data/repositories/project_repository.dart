import '../../domain/models/project.dart';
import '../../domain/repositories/i_project_repository.dart';
import '../datasources/i_project_source.dart';

class ProjectRepository implements IProjectRepository {
  ProjectRepository(this.source);

  final IProjectSource source;

  @override
  Future<List<Project>> getProjects() async => await source.getProjects();

  @override
  Future<Project> createProject(Project project) async =>
      await source.createProject(project);

  @override
  Future<void> closeRecruitment(String projectId) async =>
      await source.closeRecruitment(projectId);
}
