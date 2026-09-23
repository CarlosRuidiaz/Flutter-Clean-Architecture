/// Un hito del proyecto: lo unico de donde sale el porcentaje de avance.
///
/// El porcentaje no se guarda en ningun lado: `WorkspaceController` lo cuenta
/// a partir de cuantos hitos estan en [done]. Asi la barra nunca miente ni
/// retrocede sin motivo.
class Milestone {
  Milestone({
    this.id,
    required this.projectId,
    required this.title,
    required this.dueDate,
    this.done = false,
  });

  final String? id;
  final String projectId;
  final String title;
  final DateTime dueDate;
  final bool done;

  Milestone copyWith({bool? done}) => Milestone(
        id: id,
        projectId: projectId,
        title: title,
        dueDate: dueDate,
        done: done ?? this.done,
      );
}
