import 'package:get/get.dart';
import 'package:loggy/loggy.dart';

import '../../domain/models/project.dart';
import '../../domain/repositories/i_project_repository.dart';

class ProjectController extends GetxController with UiLoggy {
  ProjectController(this.repository);

  final IProjectRepository repository;

  final RxList<Project> _projects = <Project>[].obs;
  final RxBool isLoading = false.obs;

  List<Project> get projects => _projects;

  @override
  void onInit() {
    getProjects();
    super.onInit();
  }

  Future<void> getProjects() async {
    loggy.debug('ProjectController: pidiendo proyectos');
    isLoading.value = true;
    _projects.value = await repository.getProjects();
    isLoading.value = false;
  }

  Future<Project> createProject(Project project) async {
    loggy.debug('ProjectController: creando proyecto');
    isLoading.value = true;
    final creado = await repository.createProject(project);
    await getProjects();   // para que el homepage se entere
    isLoading.value = false;
    return creado;
  }
}