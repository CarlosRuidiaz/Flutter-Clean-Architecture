import 'package:f_clean_template/core/app_catalogs.dart';
import 'package:f_clean_template/features/profile/domain/models/profile.dart';
import 'package:f_clean_template/features/profile/domain/repositories/i_profile_repository.dart';
import 'package:f_clean_template/features/project/domain/models/project.dart';
import 'package:f_clean_template/features/project/domain/repositories/i_project_repository.dart';
import 'package:f_clean_template/features/project/ui/viewmodels/project_controller.dart';
import 'package:flutter_test/flutter_test.dart';

import '../auth/fake_auth_repository.dart';

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

/// Repositorio que falla al crear, como Roble cuando responde 400.
class _FailingRepository extends _FakeRepository {
  @override
  Future<Project> createProject(Project project) async =>
      throw StateError('el backend rechazo la peticion');
}

/// Perfil falso: el controlador necesita las habilidades del estudiante para
/// la pestania "Para tus habilidades".
class _FakeProfileRepository implements IProfileRepository {
  _FakeProfileRepository([this.skills = const [AppCatalogs.skillUx]]);

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
      final controller = ProjectController(_FakeRepository(), _FakeProfileRepository(), FakeAuthRepository());
      await controller.getProjects();
      expect(controller.projects.length, 2);
      expect(controller.isLoading.value, isFalse);
    });

    test('si crear falla, isLoading se apaga y el error sube', () async {
      final controller = ProjectController(
        _FailingRepository(),
        _FakeProfileRepository(),
        FakeAuthRepository(),
      );

      await expectLater(
        controller.createProject(_ideaNueva()),
        throwsStateError,
      );

      // Si se quedara en true, la cartelera giraria para siempre.
      expect(controller.isLoading.value, isFalse);
    });

    test('createProject deja el proyecto nuevo en la lista del controlador',
        () async {
      final controller = ProjectController(_FakeMutableRepository([]), _FakeProfileRepository(), FakeAuthRepository());
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
        FakeAuthRepository(),
      );
      await controller.getProjects();

      final creado = await controller.createProject(_ideaNueva());

      expect(controller.projects.length, 2);
      expect(controller.projects.first.id, creado.id);
      expect(controller.projects.first.title, 'Huerta urbana en la terraza');
    });
  });

  group('ProjectController · filtros por grupos', () {
    /// Cuatro proyectos elegidos para que cada grupo deje un subconjunto
    /// distinto: dos etapas, dos programas, uno lleno y uno cerrado.
    List<Project> catalogo() => [
          Project(
            id: '1',
            title: 'App de movilidad',
            problem: 'p',
            description: 'd',
            stage: ProjectStage.research,
            academicProgram: AppCatalogs.programArchitecture,
            currentMembers: 4,
            maxMembers: 6,
            skillsWanted: const [AppCatalogs.skillUx],
            leaderId: 'u3',
          ),
          Project(
            id: '2',
            title: 'Tutorías entre pares',
            problem: 'p',
            description: 'd',
            stage: ProjectStage.idea,
            academicProgram: AppCatalogs.programSystems,
            currentMembers: 2,
            maxMembers: 4,
            skillsWanted: const [AppCatalogs.skillWeb, AppCatalogs.skillPython],
            leaderId: '1',
          ),
          Project(
            id: '3',
            title: 'Reciclaje textil',
            problem: 'p',
            description: 'd',
            stage: ProjectStage.idea,
            academicProgram: AppCatalogs.programIndustrialDesign,
            currentMembers: 5,
            maxMembers: 5, // lleno
            skillsWanted: const [AppCatalogs.skillManagement],
            leaderId: 'u2',
          ),
          Project(
            id: '4',
            title: 'Biblioteca accesible',
            problem: 'p',
            description: 'd',
            stage: ProjectStage.finished,
            academicProgram: AppCatalogs.programPsychology,
            currentMembers: 3,
            maxMembers: 4,
            skillsWanted: const [AppCatalogs.skillUx],
            leaderId: 'u6',
            recruitmentOpen: false, // cerrado
          ),
        ];

    Future<ProjectController> cargado({
      List<String> skills = const [AppCatalogs.skillUx],
    }) async {
      final controller = ProjectController(
        _FakeMutableRepository(catalogo()),
        _FakeProfileRepository(skills),
        FakeAuthRepository(),
      );
      await controller.getProjects();
      await controller.getCurrentProfile();
      return controller;
    }

    test('sin filtros, allVisibleProjects son todos', () async {
      final controller = await cargado();
      expect(controller.allVisibleProjects.length, 4);
      expect(controller.hasActiveFilters, isFalse);
      expect(controller.activeFilterCount, 0);
    });

    test('la busqueda por titulo no distingue mayusculas', () async {
      final controller = await cargado();
      controller.setSearchQuery('  TUTORÍAS  ');

      expect(controller.allVisibleProjects.single.id, '2');
      // La busqueda tiene su propio campo a la vista: no cuenta como grupo.
      expect(controller.activeFilterCount, 0);
      expect(controller.hasActiveFilters, isTrue);
    });

    test('marcar dos etapas muestra los proyectos de las dos', () async {
      final controller = await cargado();
      controller.applyFilters(
        skills: const [],
        programs: const [],
        stages: const [ProjectStage.idea, ProjectStage.finished],
      );

      // Dentro de un grupo los valores se suman.
      expect(controller.allVisibleProjects.map((p) => p.id), ['2', '3', '4']);
    });

    test('habilidad y programa a la vez se cruzan', () async {
      final controller = await cargado();
      controller.applyFilters(
        skills: const [AppCatalogs.skillUx],
        programs: const [AppCatalogs.programPsychology],
        stages: const [],
      );

      // El '1' pide Diseño UX pero es de Arquitectura: entre grupos se cruza,
      // no se suma.
      expect(controller.allVisibleProjects.map((p) => p.id), ['4']);
      expect(controller.activeFilterCount, 2);
    });

    test('activeFilterCount cuenta grupos, no chips', () async {
      final controller = await cargado();
      controller.applyFilters(
        skills: const [
          AppCatalogs.skillUx,
          AppCatalogs.skillWeb,
          AppCatalogs.skillPython,
        ],
        programs: const [],
        stages: const [],
      );

      expect(controller.skillFilters.length, 3);
      expect(controller.activeFilterCount, 1);
    });

    test('un grupo vacio no filtra nada', () async {
      final controller = await cargado();
      controller.applyFilters(
        skills: const [],
        programs: const [AppCatalogs.programSystems],
        stages: const [],
      );

      expect(controller.allVisibleProjects.map((p) => p.id), ['2']);
    });

    test('el proyecto lleno y el cerrado siguen en la lista', () async {
      // onlyOpen desaparecio: nada esconde un proyecto por estar lleno o
      // cerrado, y es su tarjeta la que lo dice.
      final controller = await cargado();

      expect(controller.allVisibleProjects.map((p) => p.id), [
        '1',
        '2',
        '3',
        '4',
      ]);
      expect(
        controller.allVisibleProjects
            .where((p) => !p.acceptsApplications)
            .map((p) => p.id),
        ['3', '4'],
      );
    });

    test('projectsForMySkills no se recorta con los filtros de explorar',
        () async {
      final controller = await cargado(skills: const ['diseño ux']);

      expect(controller.projectsForMySkills.map((p) => p.id), ['1', '4']);

      // Los filtros son controles de "Explorar proyectos" y solo recortan esa
      // lista. La de habilidades tiene su propio criterio, el perfil.
      controller.applyFilters(
        skills: const [AppCatalogs.skillManagement],
        programs: const [AppCatalogs.programSystems],
        stages: const [ProjectStage.finished],
      );

      expect(controller.projectsForMySkills.map((p) => p.id), ['1', '4']);
      expect(controller.allVisibleProjects, isEmpty);
    });

    test('la busqueda tampoco recorta la pestania de habilidades', () async {
      final controller = await cargado(skills: const ['diseño ux']);
      controller.setSearchQuery('zzzz');

      expect(controller.allVisibleProjects, isEmpty);
      expect(controller.projectsForMySkills.map((p) => p.id), ['1', '4']);
    });

    test('sin habilidades en el perfil, la pestania de habilidades va vacia',
        () async {
      final controller = await cargado(skills: const []);

      expect(controller.mySkills, isEmpty);
      expect(controller.projectsForMySkills, isEmpty);
      expect(controller.allVisibleProjects.length, 4);
    });

    test('clearFilters deja la lista completa', () async {
      final controller = await cargado();
      controller.setSearchQuery('biblioteca');
      controller.applyFilters(
        skills: const [AppCatalogs.skillManagement],
        programs: const [AppCatalogs.programSystems],
        stages: const [ProjectStage.idea],
      );
      expect(controller.allVisibleProjects, isEmpty);
      expect(controller.activeFilterCount, 3);

      controller.clearFilters();

      expect(controller.hasActiveFilters, isFalse);
      expect(controller.activeFilterCount, 0);
      expect(controller.searchQuery.value, isEmpty);
      expect(controller.allVisibleProjects.length, 4);
    });

    test('applyFilters copia la seleccion, no la comparte', () async {
      // La pantalla de filtros edita su propia lista mientras esta abierta.
      // Si el controlador guardara la misma referencia, cada toque se
      // aplicaria al instante y "Aplicar" no significaria nada.
      final controller = await cargado();
      final seleccion = <ProjectStage>[ProjectStage.idea];

      controller.applyFilters(
        skills: const [],
        programs: const [],
        stages: seleccion,
      );
      seleccion.add(ProjectStage.finished);

      expect(controller.stageFilters, [ProjectStage.idea]);
    });

    test('un proyecto creado entra en las listas derivadas', () async {
      final controller = await cargado();
      controller.applyFilters(
        skills: const [],
        programs: const [],
        stages: const [ProjectStage.idea],
      );
      final antes = controller.allVisibleProjects.length;

      await controller.createProject(
        Project(
          title: 'Huerta urbana',
          problem: 'p',
          description: 'd',
          stage: ProjectStage.idea,
          academicProgram: AppCatalogs.programSystems,
          currentMembers: 1,
          maxMembers: 5,
          skillsWanted: const [AppCatalogs.skillUx],
          leaderId: '1',
        ),
      );

      expect(controller.allVisibleProjects.length, antes + 1);
      expect(controller.allVisibleProjects.first.title, 'Huerta urbana');
      expect(controller.projectsForMySkills.first.title, 'Huerta urbana');
    });
  });

  group('ProjectController · sesion', () {
    test('cerrar sesion borra la busqueda y los filtros', () async {
      final authRepo = FakeAuthRepository();
      final controller = ProjectController(
        _FakeRepository(),
        _FakeProfileRepository(),
        authRepo,
      );
      controller.onInit();
      await controller.getProjects();

      controller.setSearchQuery('movilidad');
      controller.applyFilters(
        skills: const [AppCatalogs.skillUx],
        programs: const [AppCatalogs.programSystems],
        stages: const [ProjectStage.idea],
      );

      expect(controller.searchQuery.value, 'movilidad');
      expect(controller.activeFilterCount, 3);

      authRepo.emitirSesion(false);
      await Future.delayed(const Duration(milliseconds: 50));

      expect(controller.searchQuery.value, isEmpty);
      expect(controller.activeFilterCount, 0);
      expect(controller.hasActiveFilters, isFalse);

      controller.onClose();
    });
  });
}
