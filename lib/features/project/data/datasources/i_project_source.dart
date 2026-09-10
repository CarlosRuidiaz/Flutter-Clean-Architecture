import '../../domain/models/project.dart';

abstract class IProjectSource {
  Future<List<Project>> getProjects();
}
