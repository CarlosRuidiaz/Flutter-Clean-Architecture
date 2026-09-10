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
          stage: ProjectStage.idea,
          academicProgram: 'Ingeniería',
          currentMembers: 1,
          maxMembers: 3,
          skillsWanted: ['Dart'],
        ),
        Project(
          id: '2',
          title: 'Proyecto 2',
          stage: ProjectStage.prototype,
          academicProgram: 'Diseño',
          currentMembers: 2,
          maxMembers: 2,
          skillsWanted: [],
        ),
      ];
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