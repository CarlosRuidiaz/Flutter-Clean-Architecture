import 'package:flutter_test/flutter_test.dart';
import 'package:f_clean_template/core/app_catalogs.dart';
import 'package:f_clean_template/features/profile/data/datasources/local/local_profile_source.dart';
import 'package:f_clean_template/features/profile/data/repositories/profile_repository.dart';
import 'package:f_clean_template/features/project/data/datasources/local/local_project_source.dart';
import 'package:f_clean_template/features/project/data/repositories/project_repository.dart';
import 'package:f_clean_template/features/project/domain/models/project.dart';
import 'package:f_clean_template/features/project/ui/viewmodels/project_controller.dart';

import '../auth/fake_auth_repository.dart';

void main() {
  group('Filtro por tags en la cartelera', () {
    test('ProjectController filtra visibleProjects por tags', () {
      final p1 = Project(
        id: '1',
        title: 'P1',
        problem: '',
        description: '',
        stage: ProjectStage.idea,
        academicProgram: 'Sistemas',
        currentMembers: 1,
        maxMembers: 4,
        skillsWanted: [],
        tags: [AppCatalogs.tagEducation],
        leaderId: 'u1',
      );
      final p2 = Project(
        id: '2',
        title: 'P2',
        problem: '',
        description: '',
        stage: ProjectStage.idea,
        academicProgram: 'Sistemas',
        currentMembers: 1,
        maxMembers: 4,
        skillsWanted: [],
        tags: [AppCatalogs.tagTechnology],
        leaderId: 'u2',
      );

      final auth = FakeAuthRepository();
      final controller = ProjectController(
        ProjectRepository(LocalProjectSource()),
        ProfileRepository(LocalProfileSource()),
        auth,
      );

      controller.projects.addAll([p1, p2]);
      expect(controller.visibleProjects.length, 2);

      controller.tagFilters.add(AppCatalogs.tagEducation);
      expect(controller.visibleProjects.length, 1);
      expect(controller.visibleProjects.first.id, '1');
      expect(controller.activeFilterCount, 1);

      controller.clearFilters();
      expect(controller.tagFilters, isEmpty);
      expect(controller.activeFilterCount, 0);
      expect(controller.visibleProjects.length, 2);
    });

    test('Los tags se limpian al cerrar sesión', () async {
      final auth = FakeAuthRepository();
      final controller = ProjectController(
        ProjectRepository(LocalProjectSource()),
        ProfileRepository(LocalProfileSource()),
        auth,
      );
      controller.onInit();

      controller.tagFilters.add(AppCatalogs.tagSustainability);
      expect(controller.tagFilters.isNotEmpty, isTrue);

      // Cerrar sesión
      auth.emitirSesion(false);
      await Future<void>.delayed(const Duration(milliseconds: 50));

      expect(controller.tagFilters, isEmpty);
      expect(controller.activeFilterCount, 0);
      controller.onClose();
    });
  });
}
