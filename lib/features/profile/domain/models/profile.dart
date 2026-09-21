
class Profile {
  Profile({
    this.id,
    required this.fullName,
    required this.academicProgram,
    required this.semester,
    required this.skills,
    this.bio,
  });

  final String? id;
  final String fullName;
  final String academicProgram;
  final int semester;
  final List<String> skills;

  /// Presentacion corta. Opcional: no cuenta para [isComplete].
  final String? bio;
  
  /// Lee el mapa que devuelve `currentUser()` de Roble.
  ///
  /// El id sale de `userId` y nunca de `id`: `id` es la fila del perfil, y de
  /// este valor depende quien es el lider de cada proyecto. El resto del
  /// perfil viaja en `extra`, porque no tiene tabla propia.
  factory Profile.fromJson(Map<String, dynamic> json) {
    final extra = (json['extra'] as Map?)?.cast<String, dynamic>() ?? const {};
    final semester = extra['semester'];

    return Profile(
      id: json['userId'] as String?,
      fullName: (json['name'] as String?) ?? '',
      academicProgram: (extra['academicProgram'] as String?) ?? '',
      // El semestre puede volver como texto si alguien lo escribio a mano.
      semester: semester is int
          ? semester
          : int.tryParse('${semester ?? ''}') ?? 0,
      skills:
          (extra['skills'] as List?)?.map((s) => '$s').toList() ?? const [],
      // Vacia y ausente son lo mismo: no hay biografia que mostrar.
      bio: (extra['bio'] as String?)?.trim().isNotEmpty == true
          ? (extra['bio'] as String).trim()
          : null,
    );
  }

  bool get isComplete =>
      fullName.isNotEmpty &&
      academicProgram.isNotEmpty &&
      semester > 0 &&
      skills.isNotEmpty;
}
