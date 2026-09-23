/// Una tarea del equipo, dentro del espacio de trabajo.
///
/// Se llama `ProjectTask` y no `Task` para no confundirla con nada del propio
/// lenguaje.
class ProjectTask {
  ProjectTask({
    this.id,
    required this.projectId,
    required this.title,
    required this.assigneeName,
    this.done = false,
  });

  final String? id;
  final String projectId;
  final String title;
  final String assigneeName;
  final bool done;

  ProjectTask copyWith({bool? done}) => ProjectTask(
        id: id,
        projectId: projectId,
        title: title,
        assigneeName: assigneeName,
        done: done ?? this.done,
      );
}
