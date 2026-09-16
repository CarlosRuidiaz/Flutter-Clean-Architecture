import 'package:get/get.dart';
import 'package:loggy/loggy.dart';

import '../../../profile/domain/models/profile.dart';
import '../../../profile/domain/repositories/i_profile_repository.dart';
import '../../domain/models/project.dart';
import '../../domain/repositories/i_project_repository.dart';

/// Controlador de la cartelera.
///
/// Filtrar y ordenar es trabajo suyo, no del `ListView`: una vista que hace
/// `.where(...)` dentro del `build` esconde una regla de negocio en la UI.
class ProjectController extends GetxController with UiLoggy {
  ProjectController(this.repository, this.profileRepository);

  final IProjectRepository repository;

  /// Hace falta para la pestania "Para tus habilidades": sin el perfil no se
  /// sabe contra que habilidades comparar.
  final IProfileRepository profileRepository;

  final RxList<Project> _projects = <Project>[].obs;
  final Rxn<Profile> _profile = Rxn<Profile>();
  final RxBool isLoading = false.obs;

  /// Estado de los tres filtros de la cartelera. Reactivo, para que la lista se
  /// repinte sola al cambiarlos.
  final Rxn<ProjectStage> stageFilter = Rxn<ProjectStage>(); // null = todas
  final RxString searchQuery = ''.obs;
  final RxBool onlyOpen = false.obs;

  List<Project> get projects => _projects;

  /// Las habilidades del perfil en sesion, o vacia mientras no haya cargado.
  List<String> get mySkills => _profile.value?.skills ?? const [];

  /// Los proyectos que pasan los tres filtros.
  ///
  /// Se calcula, no se almacena: derivarlo evita que se quede desincronizado
  /// cuando se crea un proyecto nuevo o cambia un filtro.
  List<Project> get visibleProjects {
    final String consulta = searchQuery.value.trim().toLowerCase();
    final ProjectStage? etapa = stageFilter.value;
    final bool soloAbiertos = onlyOpen.value;

    return _projects.where((project) {
      if (etapa != null && project.stage != etapa) return false;
      if (soloAbiertos && !project.acceptsApplications) return false;
      if (consulta.isNotEmpty &&
          !project.title.toLowerCase().contains(consulta)) {
        return false;
      }
      return true;
    }).toList();
  }

  /// Pestania "Para tus habilidades": los filtros y ademas la coincidencia con
  /// el perfil, que la responde la entidad.
  List<Project> get projectsForMySkills =>
      visibleProjects.where((p) => p.matchesAnySkill(mySkills)).toList();

  /// Pestania "Explorar proyectos": los filtros y nada mas.
  List<Project> get allVisibleProjects => visibleProjects;

  /// True si hay algun filtro puesto. La usa el estado vacio para decidir si
  /// ofrece "Limpiar filtros" o si el problema es que no hay proyectos.
  bool get hasActiveFilters =>
      stageFilter.value != null ||
      onlyOpen.value ||
      searchQuery.value.trim().isNotEmpty;

  @override
  void onInit() {
    getProjects();
    getCurrentProfile();
    super.onInit();
  }

  Future<void> getProjects() async {
    loggy.debug('ProjectController: pidiendo proyectos');
    isLoading.value = true;
    _projects.value = await repository.getProjects();
    isLoading.value = false;
  }

  Future<void> getCurrentProfile() async {
    loggy.debug('ProjectController: pidiendo el perfil para la cartelera');
    _profile.value = await profileRepository.getCurrentProfile();
  }

  Future<Project> createProject(Project project) async {
    loggy.debug('ProjectController: creando proyecto');
    isLoading.value = true;
    final creado = await repository.createProject(project);
    await getProjects();   // para que el homepage se entere
    isLoading.value = false;
    return creado;
  }

  void setStageFilter(ProjectStage? stage) => stageFilter.value = stage;

  void setSearchQuery(String query) => searchQuery.value = query;

  void toggleOnlyOpen() => onlyOpen.value = !onlyOpen.value;

  void clearFilters() {
    stageFilter.value = null;
    searchQuery.value = '';
    onlyOpen.value = false;
  }
}
