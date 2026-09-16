enum ProjectStage { idea, teamFormation, research, prototype, testing, finished }

class Project {
  Project({
    this.id,
    required this.title,
    required this.problem,
    required this.description,
    required this.stage,
    required this.academicProgram,
    required this.currentMembers,
    required this.maxMembers,
    required this.skillsWanted,
    this.tags = const [],
    required this.leaderId,
    this.recruitmentOpen = true,
  });

  final String? id;
  final String title;
  final String problem; // pantalla 10, "Problema a resolver"
  final String description; // pantallas 07 y 10, "Descripcion"
  final ProjectStage stage;
  final String academicProgram;
  final int currentMembers;
  final int maxMembers;
  final List<String> skillsWanted;
  final List<String> tags; // pantalla 10, opcional
  final String leaderId; // quien puede abrir la pantalla 18
  final bool recruitmentOpen; // pantalla 18, "Cerrar reclutamiento"

  bool get isFull => currentMembers >= maxMembers;

  /// Regla de negocio de la semana: el boton "Postularme" de la pantalla 07
  /// solo aparece si esto es true.
  bool get acceptsApplications => recruitmentOpen && !isFull;

  Project copyWith({bool? recruitmentOpen, int? currentMembers}) => Project(
        id: id,
        title: title,
        problem: problem,
        description: description,
        stage: stage,
        academicProgram: academicProgram,
        skillsWanted: skillsWanted,
        tags: tags,
        leaderId: leaderId,
        maxMembers: maxMembers,
        recruitmentOpen: recruitmentOpen ?? this.recruitmentOpen,
        currentMembers: currentMembers ?? this.currentMembers,
      );
}
