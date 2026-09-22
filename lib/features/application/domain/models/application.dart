import 'dart:convert';

enum ApplicationStatus { pending, accepted, rejected, withdrawn }

/// Una postulacion de un estudiante a un proyecto.
///
/// NO guarda el titulo ni la etapa del proyecto: las pantallas 14 y 19 los
/// piden a `IProjectRepository` con [projectId]. Asi no hay dos copias del
/// mismo dato.
class Application {
  Application({
    this.id,
    required this.projectId,
    required this.applicantId,
    required this.applicantName,
    required this.applicantProgram,
    required this.applicantSemester,
    required this.skillsOffered,
    this.status = ApplicationStatus.pending,
  });

  final String? id;
  final String projectId;
  final String applicantId;
  final String applicantName;
  final String applicantProgram; // pantalla 18: "Diseño Industrial"
  final int applicantSemester; // pantalla 18: "7.º semestre"
  final List<String> skillsOffered;
  final ApplicationStatus status;

  bool get isPending => status == ApplicationStatus.pending;

  /// La pantalla 14 muestra "Cancelar postulacion" solo mientras esto es true.
  bool get canWithdraw => status == ApplicationStatus.pending;

  factory Application.fromJson(Map<String, dynamic> json) {
    return Application(
      id: (json['_id'] ?? json['id'])?.toString(),
      projectId: json['project_id']?.toString() ?? '',
      applicantId: json['applicant_id']?.toString() ?? '',
      applicantName: json['applicant_name']?.toString() ?? '',
      applicantProgram: json['applicant_program']?.toString() ?? '',
      applicantSemester:
          int.tryParse(json['applicant_semester']?.toString() ?? '0') ?? 0,
      skillsOffered: _parseList(json['skills_offered']),
      status: _parseStatus(json['status']),
    );
  }

  Map<String, dynamic> toJson() => {
        if (id != null) '_id': id,
        'project_id': projectId,
        'applicant_id': applicantId,
        'applicant_name': applicantName,
        'applicant_program': applicantProgram,
        'applicant_semester': applicantSemester,
        'skills_offered': skillsOffered,
        'status': status.name,
      };

  Map<String, dynamic> toJsonNoId() => {
        'project_id': projectId,
        'applicant_id': applicantId,
        'applicant_name': applicantName,
        'applicant_program': applicantProgram,
        'applicant_semester': applicantSemester,
        'skills_offered': skillsOffered,
        'status': status.name,
      };

  static ApplicationStatus _parseStatus(dynamic statusValue) {
    if (statusValue == null) return ApplicationStatus.pending;
    final str = statusValue.toString();
    return ApplicationStatus.values.firstWhere(
      (s) => s.name == str,
      orElse: () => ApplicationStatus.pending,
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

  Application copyWith({ApplicationStatus? status}) => Application(
        id: id,
        projectId: projectId,
        applicantId: applicantId,
        applicantName: applicantName,
        applicantProgram: applicantProgram,
        applicantSemester: applicantSemester,
        skillsOffered: skillsOffered,
        status: status ?? this.status,
      );
}
