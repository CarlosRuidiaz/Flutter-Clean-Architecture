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

  Future<void> getMyApplications(String applicantId) async {
    loggy.debug('ApplicationController: pidiendo mis postulaciones');
    isLoading.value = true;
    _myApplications.value = await repository.getMyApplications(applicantId);
    isLoading.value = false;
  }

  Future<Application> apply(Application application) async {
    loggy.debug('ApplicationController: postulándose al proyecto ${application.projectId}');
    isLoading.value = true;
    final created = await repository.apply(application);
    _myApplications.value = await repository.getMyApplications(application.applicantId);
    isLoading.value = false;
    return created;
  }

  Future<void> withdraw(String applicationId, [String? applicantId]) async {
    loggy.debug('ApplicationController: cancelando la postulación $applicationId');
    isLoading.value = true;
    final existing =
        _myApplications.firstWhereOrNull((a) => a.id == applicationId);
    final targetApplicantId = applicantId ?? existing?.applicantId ?? '1';
    await repository.withdraw(applicationId);
    _myApplications.value = await repository.getMyApplications(targetApplicantId);
    isLoading.value = false;
  }

  /// Consulta el proyecto para mostrar su título y etapa en las pantallas 14 y 19.
  Future<Project?> getProject(String projectId) async {
    if (projectRepository == null) return null;
    final projects = await projectRepository!.getProjects();
    return projects.firstWhereOrNull((p) => p.id == projectId);
  }
}

