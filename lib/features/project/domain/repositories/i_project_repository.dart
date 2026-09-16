import '../models/project.dart';

abstract class IProjectRepository {
  Future<List<Project>> getProjects();

  Future<Project> createProject(Project project);

  Future<void> closeRecruitment(String projectId);

  /// Suma un miembro al equipo. Se llama al aceptar una postulacion: sin esto
  /// el contador de miembros y `isFull` serian decorativos.
  Future<void> addMember(String projectId);
}
