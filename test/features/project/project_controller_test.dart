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
      final controller = ProjectController(_FakeRepository());
      await controller.getProjects();
      expect(controller.projects.length, 2);
      expect(controller.isLoading.value, isFalse);
    });

    test('createProject deja el proyecto nuevo en la lista del controlador',
        () async {
      final controller = ProjectController(_FakeMutableRepository([]));
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
      );
      await controller.getProjects();

      final creado = await controller.createProject(_ideaNueva());

      expect(controller.projects.length, 2);
      expect(controller.projects.first.id, creado.id);
      expect(controller.projects.first.title, 'Huerta urbana en la terraza');
    });
  });
}
