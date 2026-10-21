import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:f_clean_template/features/project/domain/models/project.dart';

void main() {
  group('Project', () {
    group('isFull', () {
      test('es verdadero cuando los miembros llegan al maximo o lo superan', () {
        final exactoLleno = Project(
          title: 'Proyecto',
          problem: '',
          description: '',
          stage: ProjectStage.idea,
          academicProgram: '',
          currentMembers: 4,
          maxMembers: 4,
          skillsWanted: const [],
          leaderId: 'l1',
        );
        expect(exactoLleno.isFull, isTrue);

        final superoLleno = exactoLleno.copyWith(currentMembers: 5);
        expect(superoLleno.isFull, isTrue);
      });

      test('es falso cuando todavia hay cupo disponible', () {
        final conCupo = Project(
          title: 'Proyecto',
          problem: '',
          description: '',
          stage: ProjectStage.idea,
          academicProgram: '',
          currentMembers: 2,
          maxMembers: 4,
          skillsWanted: const [],
          leaderId: 'l1',
        );
        expect(conCupo.isFull, isFalse);
      });
    });

    group('acceptsApplicationsFrom', () {
      final base = Project(
        id: 'p1',
        title: 'Proyecto Abierto',
        problem: '',
        description: '',
        stage: ProjectStage.idea,
        academicProgram: '',
        currentMembers: 1,
        maxMembers: 4,
        skillsWanted: const [],
        leaderId: 'lider1',
        recruitmentOpen: true,
      );

      test('el lider no puede postularse a su propio proyecto', () {
        expect(base.acceptsApplicationsFrom('lider1'), isFalse);
      });

      test('un postulante distinto si puede mientras haya cupo y este abierto', () {
        expect(base.acceptsApplicationsFrom('otro_usuario'), isTrue);
      });

      test('rechaza si el reclutamiento esta cerrado', () {
        final cerrado = base.copyWith(recruitmentOpen: false);
        expect(cerrado.acceptsApplicationsFrom('otro_usuario'), isFalse);
      });

      test('rechaza si el proyecto esta lleno', () {
        final lleno = base.copyWith(currentMembers: 4);
        expect(lleno.isFull, isTrue);
        expect(lleno.acceptsApplicationsFrom('otro_usuario'), isFalse);
      });
    });

    group('fromJson y toJson', () {
      test('fromJson con datos completos mapea cada atributo', () {
        final json = {
          '_id': 'p100',
          'title': 'Proyecto Test',
          'problem': 'Problema test',
          'description': 'Descripcion test',
          'stage': 'research',
          'academic_program': 'Ingenieria de Sistemas',
          'current_members': 2,
          'max_members': 4,
          'skills_wanted': ['Flutter', 'Dart'],
          'tags': ['Tech', 'Mobile'],
          'leader_id': 'leader123',
          'recruitment_open': true,
        };

        final project = Project.fromJson(json);

        expect(project.id, 'p100');
        expect(project.title, 'Proyecto Test');
        expect(project.problem, 'Problema test');
        expect(project.description, 'Descripcion test');
        expect(project.stage, ProjectStage.research);
        expect(project.academicProgram, 'Ingenieria de Sistemas');
        expect(project.currentMembers, 2);
        expect(project.maxMembers, 4);
        expect(project.skillsWanted, ['Flutter', 'Dart']);
        expect(project.tags, ['Tech', 'Mobile']);
        expect(project.leaderId, 'leader123');
        expect(project.recruitmentOpen, true);
      });

      test('fromJson con datos que faltan o vienen mal usa valores por defecto sin reventar', () {
        final jsonIncompleto = <String, dynamic>{
          'current_members': 'texto_invalido',
          'max_members': null,
          'skills_wanted': null,
          'tags': 'cadena_no_json',
          'stage': 'etapa_desconocida',
          'recruitment_open': 'no_es_bool',
        };

        final project = Project.fromJson(jsonIncompleto);

        expect(project.id, isNull);
        expect(project.title, isEmpty);
        expect(project.problem, isEmpty);
        expect(project.description, isEmpty);
        expect(project.stage, ProjectStage.idea);
        expect(project.academicProgram, isEmpty);
        expect(project.currentMembers, 0);
        expect(project.maxMembers, 0);
        expect(project.skillsWanted, isEmpty);
        expect(project.tags, isEmpty);
        expect(project.leaderId, isEmpty);
        expect(project.recruitmentOpen, isFalse);
      });

      test('fromJson maneja listas jsonb que llegan como texto JSON codificado', () {
        final json = {
          '_id': 'p101',
          'title': 'Proyecto Texto JSON',
          'problem': 'Problema',
          'description': 'Descripcion',
          'stage': 'prototype',
          'academic_program': 'Diseno',
          'current_members': 1,
          'max_members': 3,
          'skills_wanted': jsonEncode(['UI/UX', 'Figma']),
          'tags': jsonEncode(['Design']),
          'leader_id': 'l1',
          'recruitment_open': 'true',
        };

        final project = Project.fromJson(json);

        expect(project.skillsWanted, ['UI/UX', 'Figma']);
        expect(project.tags, ['Design']);
        expect(project.stage, ProjectStage.prototype);
        expect(project.recruitmentOpen, isTrue);
      });

      test('toJsonNoId contiene las columnas correctas sin id y con listas en texto json', () {
        final project = Project(
          id: 'id_a_ignorar',
          title: 'Huerta urbana',
          problem: 'Un problema',
          description: 'Una descripcion',
          stage: ProjectStage.teamFormation,
          academicProgram: 'Arquitectura',
          currentMembers: 1,
          maxMembers: 5,
          skillsWanted: const ['Diseno UX', 'Analisis de datos'],
          tags: const ['Sostenibilidad'],
          leaderId: 'u1',
          recruitmentOpen: true,
        );

        final jsonNoId = project.toJsonNoId();

        expect(jsonNoId.containsKey('_id'), isFalse);
        expect(jsonNoId.containsKey('id'), isFalse);
        expect(jsonNoId['title'], 'Huerta urbana');
        expect(jsonNoId['problem'], 'Un problema');
        expect(jsonNoId['description'], 'Una descripcion');
        expect(jsonNoId['stage'], 'teamFormation');
        expect(jsonNoId['academic_program'], 'Arquitectura');
        expect(jsonNoId['current_members'], 1);
        expect(jsonNoId['max_members'], 5);
        expect(jsonNoId['skills_wanted'], jsonEncode(['Diseno UX', 'Analisis de datos']));
        expect(jsonNoId['tags'], jsonEncode(['Sostenibilidad']));
        expect(jsonNoId['leader_id'], 'u1');
        expect(jsonNoId['recruitment_open'], isTrue);
      });

      test('ida y vuelta: lo que se envia en toJsonNoId vuelve igual con fromJson', () {
        final original = Project(
          title: 'Huerta urbana',
          problem: 'Un problema',
          description: 'Una descripcion',
          stage: ProjectStage.teamFormation,
          academicProgram: 'Arquitectura',
          currentMembers: 1,
          maxMembers: 5,
          skillsWanted: const ['Diseno UX', 'Analisis de datos'],
          tags: const ['Sostenibilidad'],
          leaderId: 'u1',
          recruitmentOpen: true,
        );

        final enviado = original.toJsonNoId();
        final devuelto = Project.fromJson(enviado);

        expect(devuelto.title, original.title);
        expect(devuelto.problem, original.problem);
        expect(devuelto.description, original.description);
        expect(devuelto.stage, original.stage);
        expect(devuelto.academicProgram, original.academicProgram);
        expect(devuelto.currentMembers, original.currentMembers);
        expect(devuelto.maxMembers, original.maxMembers);
        expect(devuelto.skillsWanted, original.skillsWanted);
        expect(devuelto.tags, original.tags);
        expect(devuelto.leaderId, original.leaderId);
        expect(devuelto.recruitmentOpen, original.recruitmentOpen);
      });
    });
  });
}
