import 'package:get/get.dart';
import 'package:loggy/loggy.dart';

import '../../../application/domain/models/application.dart';
import '../../../application/domain/repositories/i_application_repository.dart';
import '../../../project/domain/models/project.dart';
import '../../../project/domain/repositories/i_project_repository.dart';

/// Esqueleto del controlador de la pantalla 18 (el lado del lider).
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
    // TODO(carril management): pedir las postulaciones del proyecto y llenar
    // _applicants, con isLoading en true mientras tanto.
  }

  Future<void> decide(String applicationId, ApplicationStatus decision) async {
    // TODO(carril management): aceptar o rechazar y recargar la lista.
  }

  Future<void> closeRecruitment(String projectId) async {
    // TODO(carril management): cerrar el reclutamiento del proyecto.
  }
}
