import 'package:get/get.dart';
import 'package:loggy/loggy.dart';

import '../../../project/domain/models/project.dart';
import '../../../project/domain/repositories/i_project_repository.dart';
import '../../domain/models/application.dart';
import '../../domain/repositories/i_application_repository.dart';

/// Controlador de las pantallas 14 y 19 (el lado del postulante).
class ApplicationController extends GetxController with UiLoggy {
  ApplicationController(this.repository, [this.projectRepository]);

  final IApplicationRepository repository;
  final IProjectRepository? projectRepository;

  final RxList<Application> _myApplications = <Application>[].obs;
  final RxBool isLoading = false.obs;

  List<Application> get myApplications => _myApplications;

  /// La postulacion vigente del estudiante a [projectId], si la hay. Una
  /// cancelada, rechazada, o de la que salio, no cuenta: puede volver a
  /// postularse. Una de la que lo removieron tampoco cuenta como vigente, pero
  /// ver [fueRemovidoDe].
  Application? vigenteEn(String projectId) =>
      _myApplications.firstWhereOrNull(
        (a) =>
            a.projectId == projectId &&
            (a.status == ApplicationStatus.pending ||
                a.status == ApplicationStatus.accepted),
      );

  /// True si el lider saco a este estudiante de [projectId]. No vuelve a
  /// postularse a ese proyecto.
  bool fueRemovidoDe(String projectId) => _myApplications.any(
        (a) =>
            a.projectId == projectId &&
            a.status == ApplicationStatus.removed,
      );

  Future<void> getMyApplications(String applicantId) async {
    loggy.debug('ApplicationController: pidiendo mis postulaciones');
    isLoading.value = true;
    _myApplications.value = await repository.getMyApplications(applicantId);
    isLoading.value = false;
  }

  /// Crea la postulacion y devuelve la que quedo guardada. Devuelve null si no
  /// se creo nada: el lider no se postula a su propio proyecto.
  ///
  /// Si el estudiante ya esta en el proyecto, o lo removieron, la fuente
  /// devuelve esa postulacion en vez de crear otra.
  Future<Application?> apply(Application application) async {
    loggy.debug(
      'ApplicationController: postulándose al proyecto ${application.projectId}',
    );

    final project = await getProject(application.projectId);
    if (project != null && project.leaderId == application.applicantId) {
      loggy.warning(
        'ApplicationController: el líder no se postula a su propio proyecto',
      );
      return null;
    }

    isLoading.value = true;
    final created = await repository.apply(application);
    _myApplications.value = await repository.getMyApplications(
      application.applicantId,
    );
    isLoading.value = false;
    return created;
  }

  Future<void> withdraw(String applicationId, [String? applicantId]) async {
    loggy.debug(
      'ApplicationController: cancelando la postulación $applicationId',
    );
    isLoading.value = true;
    final existing =
        _myApplications.firstWhereOrNull((a) => a.id == applicationId);
    final targetApplicantId = applicantId ?? existing?.applicantId;
    await repository.withdraw(applicationId);
    // Sin saber de quien es, no se adivina: la lista se vuelve a pedir la
    // proxima vez que se abra un detalle.
    if (targetApplicantId != null) {
      _myApplications.value =
          await repository.getMyApplications(targetApplicantId);
    }
    isLoading.value = false;
  }

  /// Consulta el proyecto para mostrar su título y etapa en las pantallas 14 y 19.
  Future<Project?> getProject(String projectId) async {
    if (projectRepository == null) return null;
    final projects = await projectRepository!.getProjects();
    return projects.firstWhereOrNull((p) => p.id == projectId);
  }
}
