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

  factory ProjectTask.fromJson(Map<String, dynamic> json) {
    return ProjectTask(
      id: (json['_id'] ?? json['id'])?.toString(),
      projectId: json['project_id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      assigneeName: json['assignee_name']?.toString() ?? '',
      done: json['done'] is bool
          ? json['done'] as bool
          : json['done']?.toString().toLowerCase() == 'true',
    );
  }

  /// Lo que se le manda a Roble al crear.
  Map<String, dynamic> toJsonNoId() => {
        'project_id': projectId,
        'title': title,
        'assignee_name': assigneeName,
        'done': done,
      };

  ProjectTask copyWith({bool? done}) => ProjectTask(
        id: id,
        projectId: projectId,
        title: title,
        assigneeName: assigneeName,
        done: done ?? this.done,
      );
}
