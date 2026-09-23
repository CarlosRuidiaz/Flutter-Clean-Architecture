/// Un miembro visible en el espacio de trabajo.
///
/// No es una entidad propia ni sale de ningun repositorio: `WorkspaceController`
/// la arma con el lider del proyecto y las postulaciones aceptadas. Por eso
/// vive en `ui/viewmodels` y no en `domain`.
class TeamMember {
  const TeamMember({
    required this.id,
    required this.name,
    required this.academicProgram,
    required this.isLeader,
  });

  final String id;
  final String name;

  /// Puede venir vacio: del lider no se conoce el programa si no es quien
  /// tiene la sesion.
  final String academicProgram;
  final bool isLeader;

  String get role => isLeader ? 'Líder' : 'Miembro';
}
