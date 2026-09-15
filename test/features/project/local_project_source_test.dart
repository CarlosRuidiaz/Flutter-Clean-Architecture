import 'package:f_clean_template/features/project/data/datasources/local/local_project_source.dart';
import 'package:f_clean_template/features/project/domain/models/project.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('LocalProjectSource', () {
    late LocalProjectSource source;

    setUp(() {
      source = LocalProjectSource();
    });

    test('devuelve 6 proyectos', () async {
      final projects = await source.getProjects();
      expect(projects.length, 6);
    });

    test('todos tienen titulo y programa academico', () async {
      final projects = await source.getProjects();
      for (final p in projects) {
        expect(p.title.isNotEmpty, isTrue);
        expect(p.academicProgram.isNotEmpty, isTrue);
      }
    });

    test('el proyecto lleno cumple isFull', () async {
      final projects = await source.getProjects();
      final fullProjects = projects.where((p) => p.isFull).toList();
      expect(fullProjects.isNotEmpty, isTrue);
      for (final p in fullProjects) {
        expect(p.currentMembers >= p.maxMembers, isTrue);
      }
    });

    test('las seis etapas estan representadas al menos una vez', () async {
      final projects = await source.getProjects();
      final stages = projects.map((p) => p.stage).toSet();
      expect(stages.length, ProjectStage.values.length);
      for (final stage in ProjectStage.values) {
        expect(stages.contains(stage), isTrue);
      }
    });

    test('el proyecto lleno no acepta postulaciones', () async {
      final projects = await source.getProjects();
      for (final p in projects.where((p) => p.isFull)) {
        expect(p.acceptsApplications, isFalse);
      }
    });

    test('al menos un proyecto tiene skillsWanted vacia', () async {
      final projects = await source.getProjects();
      expect(projects.any((p) => p.skillsWanted.isEmpty), isTrue);
    });

    test('createProject asigna un id nuevo', () async {
      final project = Project(
        title: 'Title',
        problem: 'P',
        description: 'D',
        stage: ProjectStage.idea,
        academicProgram: 'A',
        currentMembers: 1,
        maxMembers: 3,
        skillsWanted: [],
        leaderId: '1',
      );
      final created = await source.createProject(project);
      expect(created.id, '7');
    });

    test('createProject deja el proyecto en la lista', () async {
      final project = Project(
        title: 'Title',
        problem: 'P',
        description: 'D',
        stage: ProjectStage.idea,
        academicProgram: 'A',
        currentMembers: 1,
        maxMembers: 3,
        skillsWanted: [],
        leaderId: '1',
      );
      await source.createProject(project);
      final projects = await source.getProjects();
      expect(projects.length, 7);
      expect(projects.first.title, 'Title');
    });

    test('closeRecruitment deja recruitmentOpen en false', () async {
      await source.closeRecruitment('1');
      final projects = await source.getProjects();
      final p1 = projects.firstWhere((p) => p.id == '1');
      expect(p1.recruitmentOpen, isFalse);
    });

    test('un proyecto con reclutamiento cerrado no acepta postulaciones', () async {
      await source.closeRecruitment('1');
      final projects = await source.getProjects();
      final p1 = projects.firstWhere((p) => p.id == '1');
      expect(p1.acceptsApplications, isFalse);
    });
  });
}
