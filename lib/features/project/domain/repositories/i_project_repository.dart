import '../models/project.dart';

abstract class IProjectRepository {
  Future<List<Project>> getProjects();

  Future<Project> createProject(Project project);

  Future<void> closeRecruitment(String projectId);

  /// Suma un miembro al equipo. Se llama al aceptar una postulacion: sin esto
  /// el contador de miembros y `isFull` serian decorativos.
  Future<void> addMember(String projectId);

  /// Resta un miembro al equipo cuando alguien sale o el lider lo remueve. Es
  /// el inverso de [addMember] y nunca baja de 1, que es el lider.
  Future<void> removeMember(String projectId);

  /// Cambia la etapa del proyecto. Solo el lider la cambia.
  Future<void> updateStage(String projectId, ProjectStage stage);
}
