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

void main() {
  group('ProjectController', () {
    test('el controlador expone lo que le da el repositorio', () async {
      final controller = ProjectController(_FakeRepository());
      await controller.getProjects();
      expect(controller.projects.length, 2);
      expect(controller.isLoading.value, isFalse);
    });
  });
}
