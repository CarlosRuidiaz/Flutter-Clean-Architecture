import 'dart:async';

import 'package:get/get.dart';
import 'package:loggy/loggy.dart';

import '../../../application/domain/models/application.dart';
import '../../../application/domain/repositories/i_application_repository.dart';
import '../../../auth/domain/repositories/i_auth_repository.dart';
import '../../../profile/domain/repositories/i_profile_repository.dart';
import '../../../project/domain/models/project.dart';
import '../../../project/domain/repositories/i_project_repository.dart';

class MyProjectsController extends GetxController with UiLoggy {
  MyProjectsController(
    this.projectRepo,
    this.appRepo,
    this.profileRepo,
    this.authRepo,
  );

  final IProjectRepository projectRepo;
  final IApplicationRepository appRepo;
  final IProfileRepository profileRepo;
  final IAuthRepository authRepo;

  StreamSubscription<bool>? _sessionSub;

  final RxBool isLoading = false.obs;
  final RxString error = ''.obs;

  final RxList<Project> createdProjects = <Project>[].obs;
  final RxMap<String, int> pendingApplicationsCount = <String, int>{}.obs;

  final RxList<Project> participatingProjects = <Project>[].obs;

  int pendingFor(String? projectId) =>
      projectId == null ? 0 : (pendingApplicationsCount[projectId] ?? 0);

  /// Creados + participando, sin [ProjectStage.finished] y sin repetir id.
  int get activeProjectsCount {
    final ids = <String>{};
    for (final p in createdProjects) {
      if (p.stage != ProjectStage.finished && p.id != null) ids.add(p.id!);
    }
    for (final p in participatingProjects) {
      if (p.stage != ProjectStage.finished && p.id != null) ids.add(p.id!);
    }
    return ids.length;
  }

  @override
  void onInit() {
    super.onInit();
    _loadData();
    _sessionSub = authRepo.sessionChanges.listen((haySesion) {
      loggy.debug(
          'MyProjectsController: cambio de sesion (activa: $haySesion)');
      if (haySesion) {
        _loadData();
      } else {
        _clearData();
      }
    });
  }

  @override
  void onClose() {
    _sessionSub?.cancel();
    super.onClose();
  }

  void _clearData() {
    createdProjects.clear();
    participatingProjects.clear();
    pendingApplicationsCount.clear();
  }

  Future<void> reload() async => _loadData();

  Future<void> _loadData() async {
    loggy.debug('MyProjectsController: _loadData()');
    isLoading.value = true;
    error.value = '';
    try {
      final user = await authRepo.getLoggedUser();
      if (user == null) {
        _clearData();
        return;
      }

      final profile = await profileRepo.getCurrentProfile();
      final myId = profile.id;
      if (myId == null) {
        _clearData();
        return;
      }

      final allProjects = await projectRepo.getProjects();

      // Creados por mí
      final created =
          allProjects.where((p) => p.leaderId == myId).toList();
      createdProjects.value = created;

      // Pendientes en paralelo
      final conteos = await Future.wait(created.map((p) async {
        final apps = await appRepo.getApplicationsFor(p.id!);
        return MapEntry(p.id!, apps.where((a) => a.isPending).length);
      }));
      pendingApplicationsCount.assignAll(Map.fromEntries(conteos));

      // Donde participo
      final myApps = await appRepo.getMyApplications(myId);
      final acceptedProjectIds = myApps
          .where((a) => a.status == ApplicationStatus.accepted)
          .map((a) => a.projectId)
          .toSet();

      participatingProjects.value = allProjects
          .where((p) => acceptedProjectIds.contains(p.id))
          .toList();
    } catch (e) {
      loggy.error('Error cargando Mis Proyectos: $e');
      error.value = '$e';
    } finally {
      isLoading.value = false;
    }
  }
}
