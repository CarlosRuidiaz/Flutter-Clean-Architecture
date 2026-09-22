import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:f_clean_template/features/project/domain/models/project.dart';

void main() {
  group('Project model JSON', () {
    test('fromJson y toJson ida y vuelta con listas como List', () {
      final json = {
        '_id': 'p100',
        'title': 'Proyecto Test',
        'problem': 'Problema test',
        'description': 'Descripcion test',
        'stage': 'research',
        'academic_program': 'Ingeniería de Sistemas',
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
      expect(project.academicProgram, 'Ingeniería de Sistemas');
      expect(project.currentMembers, 2);
      expect(project.maxMembers, 4);
      expect(project.skillsWanted, ['Flutter', 'Dart']);
      expect(project.tags, ['Tech', 'Mobile']);
      expect(project.leaderId, 'leader123');
      expect(project.recruitmentOpen, true);

      final toJson = project.toJson();
      expect(toJson['_id'], 'p100');
      expect(toJson['title'], 'Proyecto Test');
      expect(toJson['stage'], 'research');
      expect(toJson['skills_wanted'], ['Flutter', 'Dart']);

      final toJsonNoId = project.toJsonNoId();
      expect(toJsonNoId.containsKey('_id'), false);
      expect(toJsonNoId.containsKey('id'), false);
      expect(toJsonNoId['title'], 'Proyecto Test');
    });

    test('fromJson maneja listas jsonb que llegan como texto JSON codificado', () {
      final json = {
        '_id': 'p101',
        'title': 'Proyecto Texto JSON',
        'problem': 'Problema',
        'description': 'Descripcion',
        'stage': 'prototype',
        'academic_program': 'Diseño',
        'current_members': 1,
        'max_members': 3,
        'skills_wanted': jsonEncode(['UI/UX', 'Figma']),
        'tags': jsonEncode(['Design']),
        'leader_id': 'l1',
        'recruitment_open': false,
      };

      final project = Project.fromJson(json);

      expect(project.skillsWanted, ['UI/UX', 'Figma']);
      expect(project.tags, ['Design']);
      expect(project.stage, ProjectStage.prototype);
      expect(project.recruitmentOpen, false);
    });

    test('fromJson usa etapa por defecto idea ante una etapa desconocida o nula', () {
      final jsonUnknown = {
        '_id': 'p102',
        'title': 'Proyecto Desconocido',
        'problem': '',
        'description': '',
        'stage': 'etapa_inventada',
        'academic_program': '',
        'current_members': 0,
        'max_members': 2,
        'skills_wanted': [],
        'tags': [],
        'leader_id': 'l2',
        'recruitment_open': true,
      };

      final projectUnknown = Project.fromJson(jsonUnknown);
      expect(projectUnknown.stage, ProjectStage.idea);

      final jsonNull = {
        ...jsonUnknown,
        'stage': null,
      };
      final projectNull = Project.fromJson(jsonNull);
      expect(projectNull.stage, ProjectStage.idea);
    });
  });
}
