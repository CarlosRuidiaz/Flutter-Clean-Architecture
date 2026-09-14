import '../../../domain/models/application.dart';
import '../i_application_source.dart';

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
      applicantProgram: 'Diseño Industrial',
      applicantSemester: 7,
      skillsOffered: ['Diseño UX', 'Investigación'],
      status: ApplicationStatus.pending,
    ),
    Application(
      id: '2',
      projectId: '2',
      applicantId: 'u8',
      applicantName: 'Felipe Gómez',
      applicantProgram: 'Ingeniería de Sistemas',
      applicantSemester: 5,
      skillsOffered: ['Flutter', 'Backend'],
      status: ApplicationStatus.pending,
    ),
    Application(
      id: '3',
      projectId: '1',
      applicantId: '1',
      applicantName: 'Carlos Ruidíaz',
      applicantProgram: 'Ingeniería de Sistemas',
      applicantSemester: 8,
      skillsOffered: ['Diseño UX'],
      status: ApplicationStatus.pending,
    ),
    Application(
      id: '4',
      projectId: '3',
      applicantId: '1',
      applicantName: 'Carlos Ruidíaz',
      applicantProgram: 'Ingeniería de Sistemas',
      applicantSemester: 8,
      skillsOffered: ['Investigación'],
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
