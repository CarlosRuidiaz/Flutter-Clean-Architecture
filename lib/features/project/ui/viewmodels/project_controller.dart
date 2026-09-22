import 'dart:async';

import 'package:get/get.dart';
import 'package:loggy/loggy.dart';

import '../../../auth/domain/repositories/i_auth_repository.dart';
import '../../../profile/domain/models/profile.dart';
import '../../../profile/domain/repositories/i_profile_repository.dart';
import '../../domain/models/project.dart';
import '../../domain/repositories/i_project_repository.dart';

/// Controlador de la cartelera.
///
/// Filtrar y ordenar es trabajo suyo, no del `ListView`: una vista que hace
/// `.where(...)` dentro del `build` esconde una regla de negocio en la UI.
class ProjectController extends GetxController with UiLoggy {
  ProjectController(this.repository, this.profileRepository, this.authRepository);

  final IProjectRepository repository;

  /// Hace falta para la pestania "Para tus habilidades": sin el perfil no se
  /// sabe contra que habilidades comparar.
  final IProfileRepository profileRepository;

  /// Por la interfaz, no por Roble: el controlador no sabe que hay detras.
  final IAuthRepository authRepository;

  StreamSubscription<bool>? _sesion;

  final RxList<Project> _projects = <Project>[].obs;
  final Rxn<Profile> _profile = Rxn<Profile>();
  final RxBool isLoading = false.obs;

  /// Estado de los filtros. Reactivo, para que la lista se repinte sola al
  /// cambiarlos.
  ///
  /// Los tres grupos son de seleccion multiple. Dentro de un grupo los valores
  /// se suman (marcar dos etapas muestra las dos); entre grupos se cruzan
  /// (una habilidad y un programa deja solo los que cumplen ambas). Un grupo
  /// vacio no filtra nada.
  final RxString searchQuery = ''.obs;
  final RxList<String> skillFilters = <String>[].obs;
  final RxList<String> programFilters = <String>[].obs;
  final RxList<ProjectStage> stageFilters = <ProjectStage>[].obs;

  List<Project> get projects => _projects;

  /// Las habilidades del perfil en sesion, o vacia mientras no haya cargado.
  List<String> get mySkills => _profile.value?.skills ?? const [];

  /// Los proyectos que pasan la busqueda y los tres grupos de "Explorar
  /// proyectos".
  ///
  /// Se calcula, no se almacena: derivarlo evita que se quede desincronizado
  /// cuando se crea un proyecto nuevo o cambia un filtro.
  ///
  /// Un proyecto con el equipo lleno no se esconde: sigue en la lista y es su
  /// tarjeta la que dice que el reclutamiento esta cerrado.
  List<Project> get visibleProjects {
    final String consulta = searchQuery.value.trim().toLowerCase();
    final List<String> habilidades = skillFilters;
    final List<String> programas = programFilters;
    final List<ProjectStage> etapas = stageFilters;

    return _projects.where((project) {
      if (etapas.isNotEmpty && !etapas.contains(project.stage)) return false;
      if (programas.isNotEmpty && !programas.contains(project.academicProgram)) {
        return false;
      }
      // La misma regla de coincidencia que usa la pestania de habilidades: si
      // el proyecto pide alguna de las marcadas, pasa.
      if (habilidades.isNotEmpty && !project.matchesAnySkill(habilidades)) {
        return false;
      }
      if (consulta.isNotEmpty &&
          !project.title.toLowerCase().contains(consulta)) {
        return false;
      }
      return true;
    }).toList();
  }

  /// Pestania "Para tus habilidades": los proyectos que piden alguna habilidad
  /// del perfil, y nada mas.
  ///
  /// Parte de la lista completa y no de [visibleProjects] a proposito. Su
  /// criterio es el perfil, y ese es el unico que tiene. La busqueda y los tres
  /// grupos son controles de "Explorar proyectos" y viven en su fila: recortar
  /// esta pestania con algo que aqui no se ve ni se puede deshacer se lee como
  /// un error de la app.
  List<Project> get projectsForMySkills =>
      _projects.where((p) => p.matchesAnySkill(mySkills)).toList();

  /// Pestania "Explorar proyectos": todos, recortados por lo que se haya
  /// elegido.
  List<Project> get allVisibleProjects => visibleProjects;

  /// Cuantos GRUPOS de filtro tienen algo marcado. Es el numero que sale en el
  /// boton "Filtros" y en "Aplicar N filtros". Se cuentan grupos, no chips:
  /// marcar tres habilidades sigue siendo un filtro.
  ///
  /// La busqueda no cuenta: tiene su propio campo a la vista.
  int get activeFilterCount =>
      (skillFilters.isEmpty ? 0 : 1) +
      (programFilters.isEmpty ? 0 : 1) +
      (stageFilters.isEmpty ? 0 : 1);

  /// True si hay algun filtro puesto, contando tambien la busqueda. La usa el
  /// estado vacio para decidir si ofrece "Limpiar filtros" o si el problema es
  /// que no hay proyectos.
  bool get hasActiveFilters =>
      activeFilterCount > 0 || searchQuery.value.trim().isNotEmpty;

  @override
  void onInit() {
    getProjects();
    getCurrentProfile();
    // Las habilidades con las que se cruza la cartelera son las de quien tenga
    // la sesion: al cambiar, las anteriores dejan de valer.
    _sesion = authRepository.sessionChanges.listen((haySesion) {
      loggy.debug('ProjectController: la sesion cambio (activa: $haySesion)');
      if (haySesion) {
        getCurrentProfile();
      } else {
        _profile.value = null;
      }
    });
    super.onInit();
  }

  @override
  void onClose() {
    _sesion?.cancel();
    super.onClose();
  }

  Future<void> getProjects() async {
    loggy.debug('ProjectController: pidiendo proyectos');
    isLoading.value = true;
    _projects.value = await repository.getProjects();
    isLoading.value = false;
  }

  Future<void> getCurrentProfile() async {
    loggy.debug('ProjectController: pidiendo el perfil para la cartelera');
    try {
      _profile.value = await profileRepository.getCurrentProfile();
    } catch (e) {
      // Sin sesion no hay habilidades con las que cruzar: la pestania se
      // queda vacia y lo explica, en vez de reventar la cartelera entera.
      loggy.warning('ProjectController: no se pudo cargar el perfil: $e');
      _profile.value = null;
    }
  }

  Future<Project> createProject(Project project) async {
    loggy.debug('ProjectController: creando proyecto');
    isLoading.value = true;
    try {
      final creado = await repository.createProject(project);
      await getProjects();   // para que el homepage se entere
      return creado;
    } finally {
      // Si el backend falla, isLoading no puede quedarse encendido: la
      // cartelera se quedaria girando para siempre.
      isLoading.value = false;
    }
  }

  void setSearchQuery(String query) => searchQuery.value = query;

  /// Vuelca de golpe lo que la pantalla de filtros traia seleccionado. La
  /// pantalla trabaja sobre una copia y solo llama aqui al pulsar "Aplicar":
  /// por eso salir con el boton de volver deja los filtros como estaban.
  void applyFilters({
    required List<String> skills,
    required List<String> programs,
    required List<ProjectStage> stages,
  }) {
    skillFilters.value = List<String>.from(skills);
    programFilters.value = List<String>.from(programs);
    stageFilters.value = List<ProjectStage>.from(stages);
  }

  void clearFilters() {
    skillFilters.clear();
    programFilters.clear();
    stageFilters.clear();
    searchQuery.value = '';
  }
}
