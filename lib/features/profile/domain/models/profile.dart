/// Entidad de dominio que representa el perfil del estudiante.
///
/// El perfil contiene la información académica básica y las habilidades
/// que el estudiante ofrece a los proyectos.
class Profile {
  Profile({
    this.id,
    required this.fullName,
    required this.academicProgram,
    required this.semester,
    required this.skills,
  });

  final String? id;
  final String fullName;
  final String academicProgram;
  final int semester;
  final List<String> skills;

  /// `true` cuando todos los campos obligatorios tienen contenido útil.
  bool get isComplete =>
      fullName.isNotEmpty &&
      academicProgram.isNotEmpty &&
      semester > 0 &&
      skills.isNotEmpty;
}
