import '../../../../../core/app_catalogs.dart';
import '../../../domain/models/application.dart';
import '../i_application_source.dart';

/// Centinela de "no hay postulacion vigente", para no depender de paquetes
/// externos en la capa de datos.
final Application _sinPostulacion = Application(
  projectId: '',
  applicantId: '',
  applicantName: '',
  applicantProgram: '',
  applicantSemester: 0,
  skillsOffered: const [],
);

/// Fuente de datos local en memoria para las postulaciones.
class LocalApplicationSource implements IApplicationSource {
  // apply, withdraw y decide modifican esta misma lista.
  // Cuando entre el backend, esta lista la reemplaza una llamada de red y ni el
  // repositorio ni los controladores cambian.
  final List<Application> _applications = [
    Application(
      id: '1',
      projectId: '2',
      applicantId: 'u7',
      applicantName: 'Mariana Pérez',
      applicantProgram: AppCatalogs.programIndustrialDesign,
      applicantSemester: 7,
      skillsOffered: const [AppCatalogs.skillUx, AppCatalogs.skillResearch],
      status: ApplicationStatus.pending,
    ),
    Application(
      id: '2',
      projectId: '2',
      applicantId: 'u8',
      applicantName: 'Felipe Gómez',
      applicantProgram: AppCatalogs.programSystems,
      applicantSemester: 5,
      skillsOffered: const [AppCatalogs.skillWeb, AppCatalogs.skillManagement],
      status: ApplicationStatus.pending,
    ),
    Application(
      id: '3',
      projectId: '1',
      applicantId: '1',
      applicantName: 'Carlos Ruidíaz',
      applicantProgram: AppCatalogs.programSystems,
      applicantSemester: 8,
      skillsOffered: const [AppCatalogs.skillUx],
      status: ApplicationStatus.pending,
    ),
    Application(
      id: '4',
      projectId: '3',
      applicantId: '1',
      applicantName: 'Carlos Ruidíaz',
      applicantProgram: AppCatalogs.programSystems,
      applicantSemester: 8,
      skillsOffered: const [AppCatalogs.skillResearch],
      status: ApplicationStatus.accepted,
    ),
  ];

  int _nextId = 5;

  @override
  Future<List<Application>> getMyApplications(String applicantId) async =>
      _applications.where((a) => a.applicantId == applicantId).toList();

  @override
  Future<List<Application>> getApplicationsFor(String projectId) async =>
      _applications.where((a) => a.projectId == projectId).toList();

  @override
  Future<Application> apply(Application application) async {
    // Un estudiante no puede tener dos postulaciones vivas al mismo proyecto.
    // Si ya la tiene, se devuelve esa en vez de crear un duplicado: la pantalla
    // 18 mostraria al mismo candidato repetido.
    final vigente = _applications.firstWhere(
      (a) =>
          a.projectId == application.projectId &&
          a.applicantId == application.applicantId &&
          (a.status == ApplicationStatus.pending ||
              a.status == ApplicationStatus.accepted),
      orElse: () => _sinPostulacion,
    );
    if (!identical(vigente, _sinPostulacion)) return vigente;

    final creada = Application(
      id: '${_nextId++}',
      projectId: application.projectId,
      applicantId: application.applicantId,
      applicantName: application.applicantName,
      applicantProgram: application.applicantProgram,
      applicantSemester: application.applicantSemester,
      skillsOffered: application.skillsOffered,
      status: application.status,
    );
    _applications.add(creada);
    return creada;
  }

  @override
  Future<void> withdraw(String applicationId) async {
    final index = _applications.indexWhere((a) => a.id == applicationId);
    if (index != -1) {
      _applications[index] = _applications[index].copyWith(
        status: ApplicationStatus.withdrawn,
      );
    }
  }

  @override
  Future<void> decide(String applicationId, ApplicationStatus decision) async {
    final index = _applications.indexWhere((a) => a.id == applicationId);
    if (index != -1) {
      _applications[index] = _applications[index].copyWith(status: decision);
    }
  }
}
