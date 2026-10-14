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

  factory Milestone.fromJson(Map<String, dynamic> json) {
    return Milestone(
      id: (json['_id'] ?? json['id'])?.toString(),
      projectId: json['project_id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      dueDate: _parseDate(json['due_date']),
      done: _parseBool(json['done']),
    );
  }

  /// Lo que se le manda a Roble al crear. La fecha viaja como texto ISO 8601.
  Map<String, dynamic> toJsonNoId() => {
        'project_id': projectId,
        'title': title,
        'due_date': dueDate.toIso8601String(),
        'done': done,
      };

  static DateTime _parseDate(dynamic value) =>
      DateTime.tryParse(value?.toString() ?? '') ??
      DateTime.fromMillisecondsSinceEpoch(0);

  static bool _parseBool(dynamic value) =>
      value is bool ? value : value?.toString().toLowerCase() == 'true';

  Milestone copyWith({bool? done}) => Milestone(
        id: id,
        projectId: projectId,
        title: title,
        dueDate: dueDate,
        done: done ?? this.done,
      );
}
