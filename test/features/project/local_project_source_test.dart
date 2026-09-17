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
    test('addMember sube el contador de miembros del proyecto pedido', () async {
      final antes = (await source.getProjects()).firstWhere((p) => p.id == '2');
      expect(antes.currentMembers, 2);

      await source.addMember('2');

      final despues =
          (await source.getProjects()).firstWhere((p) => p.id == '2');
      expect(despues.currentMembers, 3);
      expect(despues.maxMembers, antes.maxMembers);
    });

    test('addMember no pasa de maxMembers', () async {
      // El proyecto '4' nace lleno: 5 de 5.
      await source.addMember('4');

      final p4 = (await source.getProjects()).firstWhere((p) => p.id == '4');
      expect(p4.currentMembers, 5);
      expect(p4.isFull, isTrue);
      expect(p4.acceptsApplications, isFalse);
    });

    test('al llenar el ultimo cupo el proyecto deja de aceptar postulaciones',
        () async {
      // El '2' va 2 de 4: dos aceptaciones lo llenan.
      await source.addMember('2');
      await source.addMember('2');

      final p2 = (await source.getProjects()).firstWhere((p) => p.id == '2');
      expect(p2.currentMembers, 4);
      expect(p2.isFull, isTrue);
      expect(p2.acceptsApplications, isFalse);
    });
    test('el realineado de vocabulario no movio ids, lider ni cupos', () async {
      // El documento prohibia tocarlos: las postulaciones apuntan a estos id y
      // la gestion de postulantes se prueba sobre el '2', cuyo lider es el
      // perfil actual. Si alguien los cambia al retocar el catalogo, esto lo
      // caza antes que la pantalla.
      final projects = await source.getProjects();

      expect(projects.map((p) => p.id), ['1', '2', '3', '4', '5', '6']);

      final p2 = projects.firstWhere((p) => p.id == '2');
      expect(p2.leaderId, '1');
      expect(p2.currentMembers, 2);
      expect(p2.maxMembers, 4);

      final p4 = projects.firstWhere((p) => p.id == '4');
      expect(p4.isFull, isTrue, reason: 'el 4 es el equipo lleno de prueba');

      final p6 = projects.firstWhere((p) => p.id == '6');
      expect(p6.recruitmentOpen, isFalse);
      expect(p6.isFull, isFalse, reason: 'el 6 esta cerrado pero no lleno');
    });
  });
}
