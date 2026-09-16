import 'package:f_clean_template/features/profile/domain/models/profile.dart';
import 'package:f_clean_template/features/profile/domain/repositories/i_profile_repository.dart';
import 'package:f_clean_template/features/project/domain/models/project.dart';
import 'package:f_clean_template/features/project/domain/repositories/i_project_repository.dart';
import 'package:f_clean_template/features/project/ui/viewmodels/project_controller.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeRepository implements IProjectRepository {
  @override
  Future<List<Project>> getProjects() async => [
        Project(
          id: '1',
          title: 'Proyecto 1',
          problem: 'Un problema',
          description: 'Una descripcion',
          stage: ProjectStage.idea,
          academicProgram: 'Ingeniería',
          currentMembers: 1,
          maxMembers: 3,
          skillsWanted: ['Dart'],
          leaderId: 'u1',
        ),
        Project(
          id: '2',
          title: 'Proyecto 2',
          problem: 'Otro problema',
          description: 'Otra descripcion',
          stage: ProjectStage.prototype,
          academicProgram: 'Diseño',
          currentMembers: 2,
          maxMembers: 2,
          skillsWanted: [],
          leaderId: 'u2',
        ),
      ];

  @override
  Future<Project> createProject(Project project) async =>
      throw UnimplementedError();

  @override
  Future<void> closeRecruitment(String projectId) async =>
      throw UnimplementedError();

  @override
  Future<void> addMember(String projectId) async => throw UnimplementedError();
}

/// Repositorio falso que se comporta como la fuente local: guarda en una lista
/// propia, le pone id a lo creado y lo inserta de primero.
///
/// Es a mano y no un mock generado a proposito: el controlador depende de la
/// interfaz, asi que basta con otra implementacion de la interfaz para probar
/// el recorrido entero sin red ni widgets.
class _FakeMutableRepository implements IProjectRepository {
  _FakeMutableRepository(this._projects);

  final List<Project> _projects;
  int _nextId = 100;

  @override
  Future<List<Project>> getProjects() async => List.unmodifiable(_projects);

  @override
  Future<Project> createProject(Project project) async {
    final creado = Project(
      id: '${_nextId++}',
      title: project.title,
      problem: project.problem,
      description: project.description,
      stage: project.stage,
      academicProgram: project.academicProgram,
      currentMembers: project.currentMembers,
      maxMembers: project.maxMembers,
      skillsWanted: project.skillsWanted,
      tags: project.tags,
      leaderId: project.leaderId,
      recruitmentOpen: project.recruitmentOpen,
    );
    _projects.insert(0, creado);
    return creado;
  }

  @override
  Future<void> closeRecruitment(String projectId) async {
    final index = _projects.indexWhere((p) => p.id == projectId);
    if (index != -1) {
      _projects[index] = _projects[index].copyWith(recruitmentOpen: false);
    }
  }

  @override
  Future<void> addMember(String projectId) async {
    final index = _projects.indexWhere((p) => p.id == projectId);
    if (index == -1 || _projects[index].isFull) return;
    _projects[index] = _projects[index].copyWith(
      currentMembers: _projects[index].currentMembers + 1,
    );
  }
}

/// Perfil falso: el controlador necesita las habilidades del estudiante para
/// la pestania "Para tus habilidades".
class _FakeProfileRepository implements IProfileRepository {
  _FakeProfileRepository([this.skills = const ['Dart', 'Diseño UX']]);

  final List<String> skills;

  @override
  Future<Profile> getCurrentProfile() async => Profile(
        id: '1',
        fullName: 'Carlos Ruidíaz',
        academicProgram: 'Ingeniería de Sistemas',
        semester: 8,
        skills: skills,
      );
}

Project _ideaNueva() => Project(
      title: 'Huerta urbana en la terraza',
      problem: 'La terraza del bloque B lleva tres anios sin uso.',
      description: 'Una huerta que abastezca la cafeteria del campus.',
      stage: ProjectStage.idea,
      academicProgram: 'Ingeniería Ambiental',
      currentMembers: 1,
      maxMembers: 5,
      skillsWanted: ['Agronomía'],
      leaderId: '1',
    );

void main() {
  group('ProjectController', () {
    test('el controlador expone lo que le da el repositorio', () async {
      final controller = ProjectController(_FakeRepository(), _FakeProfileRepository());
      await controller.getProjects();
      expect(controller.projects.length, 2);
      expect(controller.isLoading.value, isFalse);
    });

    test('createProject deja el proyecto nuevo en la lista del controlador',
        () async {
      final controller = ProjectController(_FakeMutableRepository([]), _FakeProfileRepository());
      await controller.getProjects();
      expect(controller.projects, isEmpty);

      final creado = await controller.createProject(_ideaNueva());

      // El id lo pone la fuente, no quien crea: por eso se compara contra el
      // proyecto devuelto y no contra el que se paso.
      expect(creado.id, isNotNull);
      expect(controller.projects.length, 1);
      expect(
        controller.projects.any((p) => p.id == creado.id),
        isTrue,
        reason: 'la cartelera tiene que recargarse sola despues de crear',
      );
      expect(controller.isLoading.value, isFalse);
    });

    test('el proyecto nuevo queda de primero', () async {
      final controller = ProjectController(
        _FakeMutableRepository([
          Project(
            id: '1',
            title: 'Proyecto viejo',
            problem: 'Un problema',
            description: 'Una descripcion',
            stage: ProjectStage.testing,
            academicProgram: 'Ingeniería',
            currentMembers: 1,
            maxMembers: 3,
            skillsWanted: const [],
            leaderId: 'u1',
          ),
        ]),
        _FakeProfileRepository(),
      );
      await controller.getProjects();

      final creado = await controller.createProject(_ideaNueva());

      expect(controller.projects.length, 2);
      expect(controller.projects.first.id, creado.id);
      expect(controller.projects.first.title, 'Huerta urbana en la terraza');
    });
  });

  group('ProjectController · filtros', () {
    /// Cuatro proyectos elegidos para que cada filtro deje un subconjunto
    /// distinto: dos etapas, uno lleno y uno con el reclutamiento cerrado.
    List<Project> catalogo() => [
          Project(
            id: '1',
            title: 'App de movilidad',
            problem: 'p',
            description: 'd',
            stage: ProjectStage.research,
            academicProgram: 'Ingeniería Civil',
            currentMembers: 4,
            maxMembers: 6,
            skillsWanted: ['Diseño UX'],
            leaderId: 'u3',
          ),
          Project(
            id: '2',
            title: 'Tutorías entre pares',
            problem: 'p',
            description: 'd',
            stage: ProjectStage.idea,
            academicProgram: 'Ingeniería de Sistemas',
            currentMembers: 2,
            maxMembers: 4,
            skillsWanted: ['Flutter', 'Backend'],
            leaderId: '1',
          ),
          Project(
            id: '3',
            title: 'Reciclaje textil',
            problem: 'p',
            description: 'd',
            stage: ProjectStage.idea,
            academicProgram: 'Diseño Industrial',
            currentMembers: 5,
            maxMembers: 5, // lleno: no acepta postulaciones
            skillsWanted: ['Logística'],
            leaderId: 'u2',
          ),
          Project(
            id: '4',
            title: 'Biblioteca accesible',
            problem: 'p',
            description: 'd',
            stage: ProjectStage.finished,
            academicProgram: 'Psicología',
            currentMembers: 3,
            maxMembers: 4,
            skillsWanted: ['Diseño UX'],
            leaderId: 'u6',
            recruitmentOpen: false, // cerrado: tampoco acepta
          ),
        ];

    Future<ProjectController> cargado({
      List<String> skills = const ['Diseño UX'],
    }) async {
      final controller = ProjectController(
        _FakeMutableRepository(catalogo()),
        _FakeProfileRepository(skills),
      );
      await controller.getProjects();
      await controller.getCurrentProfile();
      return controller;
    }

    test('sin filtros, allVisibleProjects son todos', () async {
      final controller = await cargado();
      expect(controller.allVisibleProjects.length, 4);
      expect(controller.hasActiveFilters, isFalse);
    });

    test('la busqueda por titulo no distingue mayusculas', () async {
      final controller = await cargado();
      controller.setSearchQuery('  TUTORÍAS  ');

      expect(controller.allVisibleProjects.length, 1);
      expect(controller.allVisibleProjects.single.id, '2');
      expect(controller.hasActiveFilters, isTrue);
    });

    test('el filtro de etapa deja solo los de esa etapa, y null los devuelve',
        () async {
      final controller = await cargado();
      controller.setStageFilter(ProjectStage.idea);
      expect(controller.allVisibleProjects.map((p) => p.id), ['2', '3']);

      controller.setStageFilter(null);
      expect(controller.allVisibleProjects.length, 4);
    });

    test('onlyOpen esconde el lleno y el de reclutamiento cerrado', () async {
      final controller = await cargado();
      controller.toggleOnlyOpen();

      expect(controller.allVisibleProjects.map((p) => p.id), ['1', '2']);
    });

    test('projectsForMySkills cruza los filtros con las habilidades del perfil',
        () async {
      final controller = await cargado(skills: ['diseño ux']);

      // El 1 y el 4 piden "Diseño UX"; el 4 se cae al exigir abiertos.
      expect(controller.projectsForMySkills.map((p) => p.id), ['1', '4']);
      controller.toggleOnlyOpen();
      expect(controller.projectsForMySkills.map((p) => p.id), ['1']);
    });

    test('sin habilidades en el perfil, la pestania de habilidades va vacia',
        () async {
      final controller = await cargado(skills: const []);

      expect(controller.mySkills, isEmpty);
      expect(controller.projectsForMySkills, isEmpty);
      expect(controller.allVisibleProjects.length, 4);
    });

    test('clearFilters devuelve la cartelera completa', () async {
      final controller = await cargado();
      controller.setSearchQuery('biblioteca');
      controller.setStageFilter(ProjectStage.finished);
      controller.toggleOnlyOpen();
      expect(controller.allVisibleProjects, isEmpty);

      controller.clearFilters();

      expect(controller.hasActiveFilters, isFalse);
      expect(controller.allVisibleProjects.length, 4);
    });

    test('un proyecto creado entra en las listas derivadas sin recalcular nada',
        () async {
      final controller = await cargado();
      controller.setStageFilter(ProjectStage.idea);
      final antes = controller.allVisibleProjects.length;

      await controller.createProject(
        Project(
          title: 'Huerta urbana',
          problem: 'p',
          description: 'd',
          stage: ProjectStage.idea,
          academicProgram: 'Ingeniería Ambiental',
          currentMembers: 1,
          maxMembers: 5,
          skillsWanted: const ['Diseño UX'],
          leaderId: '1',
        ),
      );

      expect(controller.allVisibleProjects.length, antes + 1);
      expect(controller.allVisibleProjects.first.title, 'Huerta urbana');
      expect(controller.projectsForMySkills.first.title, 'Huerta urbana');
    });
  });
}
