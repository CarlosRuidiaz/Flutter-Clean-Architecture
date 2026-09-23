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

  /// La galeria y el video todavia no van: solo se guarda el enlace.
  final String? videoUrl;

  /// El hito que este avance cumple, si el autor marco alguno.
  final String? milestoneId;
}
