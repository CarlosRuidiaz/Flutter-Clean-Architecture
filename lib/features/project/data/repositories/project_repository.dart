import '../../domain/models/project.dart';
import '../../domain/repositories/i_project_repository.dart';
import '../datasources/i_project_source.dart';

class ProjectRepository implements IProjectRepository {
  ProjectRepository(this.source);

  final IProjectSource source;

  @override
  Future<List<Project>> getProjects() async => await source.getProjects();
}
