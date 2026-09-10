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
