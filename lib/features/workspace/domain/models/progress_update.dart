/// Una entrada de la bitacora de avances del proyecto.
///
/// No mueve el porcentaje por si sola: si [milestoneId] viene informado, es el
/// hito que este avance cumple, y es eso lo que sube la barra.
class ProgressUpdate {
  ProgressUpdate({
    this.id,
    required this.projectId,
    required this.authorId,
    required this.authorName,
    required this.title,
    required this.description,
    required this.createdAt,
    required this.completionPercentage,
    this.videoUrl,
    this.milestoneId,
  });

  final String? id;
  final String projectId;
  final String authorId;
  final String authorName;
  final String title;
  final String description;
  final DateTime createdAt;

  /// Foto del porcentaje de avance del proyecto (0 a 100) en el momento de
  /// publicar. El porcentaje real sigue calculandose con los hitos y nunca se
  /// guarda: esto es solo lo que decia la barra cuando se escribio el avance.
  final int completionPercentage;

  /// La galeria y el video todavia no van: solo se guarda el enlace.
  final String? videoUrl;

  /// El hito que este avance cumple, si el autor marco alguno.
  final String? milestoneId;

  factory ProgressUpdate.fromJson(Map<String, dynamic> json) {
    return ProgressUpdate(
      id: (json['_id'] ?? json['id'])?.toString(),
      projectId: json['project_id']?.toString() ?? '',
      authorId: json['author_id']?.toString() ?? '',
      authorName: json['author_name']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      createdAt:
          DateTime.tryParse(json['created_at']?.toString() ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0),
      completionPercentage:
          (int.tryParse(json['completion_percentage']?.toString() ?? '') ?? 0)
              .clamp(0, 100),
      videoUrl: _textoOpcional(json['video_url']),
      milestoneId: _textoOpcional(json['milestone_id']),
    );
  }

  /// Lo que se le manda a Roble al crear. La fecha viaja como texto ISO 8601 y
  /// los dos campos opcionales como texto vacio cuando no hay valor.
  Map<String, dynamic> toJsonNoId() => {
        'project_id': projectId,
        'author_id': authorId,
        'author_name': authorName,
        'title': title,
        'description': description,
        'created_at': createdAt.toIso8601String(),
        'completion_percentage': completionPercentage,
        'video_url': videoUrl ?? '',
        'milestone_id': milestoneId ?? '',
      };

  /// Vacio y ausente son lo mismo: no hay valor que mostrar.
  static String? _textoOpcional(dynamic value) {
    final texto = value?.toString().trim() ?? '';
    return texto.isEmpty ? null : texto;
  }
}
