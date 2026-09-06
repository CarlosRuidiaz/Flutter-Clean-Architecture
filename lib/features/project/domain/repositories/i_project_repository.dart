import '../models/project.dart';

abstract class IProjectRepository {
  Future<List<Project>> getProjects();
}
