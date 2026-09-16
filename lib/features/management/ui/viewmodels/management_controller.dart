import 'package:get/get.dart';
import 'package:loggy/loggy.dart';

import '../../../application/domain/models/application.dart';
import '../../../application/domain/repositories/i_application_repository.dart';
import '../../../project/domain/models/project.dart';
import '../../../project/domain/repositories/i_project_repository.dart';

/// Controlador de la pantalla 18 (el lado del lider).
///
/// El feature `management` no tiene entidad, ni fuente, ni repositorio propios:
/// vive sobre los dos repositorios que ya existen. Dos controladores sobre un
/// mismo repositorio es exactamente el punto.
class ManagementController extends GetxController with UiLoggy {
  ManagementController(this.applicationRepository, this.projectRepository);

  final IApplicationRepository applicationRepository;
  final IProjectRepository projectRepository;

  final RxList<Application> _applicants = <Application>[].obs;
  final Rxn<Project> _project = Rxn<Project>();
  final RxBool isLoading = false.obs;

  List<Application> get applicants => _applicants;
  Project? get project => _project.value;

  /// Cuantas postulaciones siguen sin decidir. No se almacena: se cuenta.
  int get pendingCount => _applicants.where((a) => a.isPending).length;

  Future<void> getApplicants(String projectId) async {
    loggy.debug('ManagementController: pidiendo postulantes');
    isLoading.value = true;
    _applicants.value = await applicationRepository.getApplicationsFor(
      projectId,
    );
    final projects = await projectRepository.getProjects();
    _project.value = projects.firstWhereOrNull((p) => p.id == projectId);
    isLoading.value = false;
  }

  Future<void> decide(String applicationId, ApplicationStatus decision) async {
    loggy.debug('ManagementController: decidiendo la postulacion $applicationId');
    await applicationRepository.decide(applicationId, decision);
    final projectId = _project.value?.id;
    if (projectId == null) return;

    // Aceptar a alguien lo suma al equipo: es lo que enciende isFull y apaga
    // acceptsApplications cuando se llena el ultimo cupo.
    if (decision == ApplicationStatus.accepted) {
      await projectRepository.addMember(projectId);
    }
    await getApplicants(projectId);
  }

  Future<void> closeRecruitment(String projectId) async {
    await projectRepository.closeRecruitment(projectId);
    await getApplicants(projectId);
  }
}
