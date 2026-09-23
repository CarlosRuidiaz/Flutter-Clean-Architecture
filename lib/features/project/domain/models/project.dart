import 'dart:convert';

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

  /// Si [userId] puede postularse: ademas de lo anterior, no es el lider. Quien
  /// crea el proyecto ya esta en el equipo y gestiona a los postulantes.
  bool acceptsApplicationsFrom(String? userId) =>
      acceptsApplications && userId != leaderId;

  /// Un proyecto encaja con un estudiante si alguna habilidad buscada coincide
  /// con alguna de las suyas. Comparacion sin distinguir mayusculas ni espacios
  /// de sobra, porque las habilidades se escriben a mano.
  ///
  /// Con [studentSkills] vacia devuelve false: sin habilidades registradas no
  /// se puede afirmar que un proyecto le sirva a nadie.
  bool matchesAnySkill(List<String> studentSkills) {
    final suyas = studentSkills.map(_normalizar).where((s) => s.isNotEmpty).toSet();
    if (suyas.isEmpty) return false;
    return skillsWanted
        .map(_normalizar)
        .any((buscada) => buscada.isNotEmpty && suyas.contains(buscada));
  }

  static String _normalizar(String habilidad) =>
      habilidad.trim().toLowerCase();

  factory Project.fromJson(Map<String, dynamic> json) {
    return Project(
      id: (json['_id'] ?? json['id'])?.toString(),
      title: json['title']?.toString() ?? '',
      problem: json['problem']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      stage: _parseStage(json['stage']),
      academicProgram: json['academic_program']?.toString() ?? '',
      currentMembers:
          int.tryParse(json['current_members']?.toString() ?? '0') ?? 0,
      maxMembers: int.tryParse(json['max_members']?.toString() ?? '0') ?? 0,
      skillsWanted: _parseList(json['skills_wanted']),
      tags: _parseList(json['tags']),
      leaderId: json['leader_id']?.toString() ?? '',
      recruitmentOpen: json['recruitment_open'] == null
          ? true
          : (json['recruitment_open'] is bool
              ? json['recruitment_open'] as bool
              : json['recruitment_open'].toString().toLowerCase() == 'true'),
    );
  }

  Map<String, dynamic> toJson() => {
        if (id != null) '_id': id,
        'title': title,
        'problem': problem,
        'description': description,
        'stage': stage.name,
        'academic_program': academicProgram,
        'current_members': currentMembers,
        'max_members': maxMembers,
        'skills_wanted': skillsWanted,
        'tags': tags,
        'leader_id': leaderId,
        'recruitment_open': recruitmentOpen,
      };

  /// Lo que se le manda a Roble al crear.
  ///
  /// Las listas van como texto JSON y no como `List`: las columnas jsonb
  /// reciben la lista de Dart y el servidor la convierte en un array de
  /// PostgreSQL (`{"a","b"}`), que no es JSON valido y responde 400
  /// "Conversion invalida". `fromJson` acepta las dos formas, asi que leer
  /// sigue funcionando igual.
  Map<String, dynamic> toJsonNoId() => {
        'title': title,
        'problem': problem,
        'description': description,
        'stage': stage.name,
        'academic_program': academicProgram,
        'current_members': currentMembers,
        'max_members': maxMembers,
        'skills_wanted': jsonEncode(skillsWanted),
        'tags': jsonEncode(tags),
        'leader_id': leaderId,
        'recruitment_open': recruitmentOpen,
      };

  static ProjectStage _parseStage(dynamic stageValue) {
    if (stageValue == null) return ProjectStage.idea;
    final str = stageValue.toString();
    return ProjectStage.values.firstWhere(
      (s) => s.name == str,
      orElse: () => ProjectStage.idea,
    );
  }

  static List<String> _parseList(dynamic value) {
    if (value == null) return const [];
    if (value is List) {
      return value.map((e) => e.toString()).toList();
    }
    if (value is String) {
      final trimmed = value.trim();
      if (trimmed.isEmpty) return const [];
      try {
        final decoded = jsonDecode(trimmed);
        if (decoded is List) {
          return decoded.map((e) => e.toString()).toList();
        }
      } catch (_) {}
    }
    return const [];
  }

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
