import 'package:flutter_test/flutter_test.dart';
import 'package:roble/roble.dart';
import 'package:f_clean_template/features/project/data/datasources/remote/roble_project_source.dart';
import 'package:f_clean_template/features/project/domain/models/project.dart';

class FakeRobleDatabase extends RobleApiDataBase {
  FakeRobleDatabase()
      : super(
          config: RobleApiConfig.fromContract(
            baseUrl: 'https://roble.test-openlab.uninorte.edu.co',
            contractId: 'proyecto_test_12345678',
          ),
        );

  final List<Map<String, dynamic>> projects = [];
  String? lastReadTable;
  Map<String, dynamic>? lastFilters;
  String? lastCreateTable;
  Map<String, dynamic>? lastCreateData;
  bool shouldThrowOnRead = false;

  @override
  Future<List<Map<String, dynamic>>> read(
    String tableName, {
    Map<String, dynamic>? filters,
  }) async {
    lastReadTable = tableName;
    lastFilters = filters;
    if (shouldThrowOnRead) {
      throw Exception('Fallo de comunicacion con Roble');
    }
    if (tableName == 'projects') {
      return projects;
    }
    return [];
  }

  @override
  Future<Map<String, dynamic>> create(
    String tableName,
    Map<String, dynamic> data,
  ) async {
    lastCreateTable = tableName;
    lastCreateData = data;
    if (tableName == 'projects') {
      final record = Map<String, dynamic>.from(data);
      record['_id'] = 'p_${projects.length + 1}';
      projects.add(record);
      return record;
    }
    return {};
  }

  @override
  Future<Map<String, dynamic>?> getById(String tableName, dynamic id) async {
    if (tableName == 'projects') {
      for (final p in projects) {
        if (p['_id'] == id.toString()) return p;
      }
    }
    return null;
  }

  @override
  Future<Map<String, dynamic>> update(
    String tableName,
    dynamic id,
    Map<String, dynamic> data,
  ) async {
    if (tableName == 'projects') {
      for (final p in projects) {
        if (p['_id'] == id.toString()) {
          p.addAll(data);
          return p;
        }
      }
    }
    return {};
  }
}

void main() {
  group('RobleProjectSource', () {
    late FakeRobleDatabase fakeRoble;
    late RobleProjectSource source;

    setUp(() {
      fakeRoble = FakeRobleDatabase();
      source = RobleProjectSource(fakeRoble);
    });

    test('getProjects pide la tabla projects y devuelve la lista mapeada', () async {
      fakeRoble.projects.add({
        '_id': 'p1',
        'title': 'Proyecto Roble',
        'problem': 'Problema',
        'description': 'Descripcion',
        'stage': 'idea',
        'academic_program': 'Sistemas',
        'current_members': 1,
        'max_members': 4,
        'skills_wanted': ['Flutter'],
        'tags': ['Tech'],
        'leader_id': 'u1',
        'recruitment_open': true,
      });

      final list = await source.getProjects();
      expect(fakeRoble.lastReadTable, 'projects');
      expect(list.length, 1);
      expect(list.first.id, 'p1');
      expect(list.first.title, 'Proyecto Roble');
    });

    test('getProjects propaga el error cuando Roble falla', () async {
      fakeRoble.shouldThrowOnRead = true;
      expect(() => source.getProjects(), throwsA(isA<Exception>()));
    });

    test('createProject inserta con toJsonNoId mandando listas como texto JSON y devuelve _id', () async {
      final nuevo = Project(
        title: 'Nuevo Proyecto',
        problem: 'Prob',
        description: 'Desc',
        stage: ProjectStage.idea,
        academicProgram: 'Diseno',
        currentMembers: 1,
        maxMembers: 3,
        skillsWanted: const ['UX'],
        tags: const ['Mobile'],
        leaderId: 'l1',
      );

      final creado = await source.createProject(nuevo);
      expect(fakeRoble.lastCreateTable, 'projects');
      expect(fakeRoble.lastCreateData?['skills_wanted'], isA<String>());
      expect(fakeRoble.lastCreateData?['tags'], isA<String>());
      expect(creado.id, isNotNull);
      expect(creado.title, 'Nuevo Proyecto');
      expect(fakeRoble.projects.length, 1);
      expect(fakeRoble.projects.first['_id'], creado.id);
    });

    test('closeRecruitment actualiza recruitment_open a false', () async {
      fakeRoble.projects.add({
        '_id': 'p2',
        'title': 'Proyecto Abierto',
        'problem': '',
        'description': '',
        'stage': 'idea',
        'academic_program': '',
        'current_members': 1,
        'max_members': 3,
        'skills_wanted': [],
        'tags': [],
        'leader_id': 'l1',
        'recruitment_open': true,
      });

      await source.closeRecruitment('p2');
      expect(fakeRoble.projects.first['recruitment_open'], false);
    });

    test('addMember incrementa current_members si no esta lleno', () async {
      fakeRoble.projects.add({
        '_id': 'p3',
        'title': 'Proyecto Incompleto',
        'problem': '',
        'description': '',
        'stage': 'idea',
        'academic_program': '',
        'current_members': 1,
        'max_members': 3,
        'skills_wanted': [],
        'tags': [],
        'leader_id': 'l1',
        'recruitment_open': true,
      });

      await source.addMember('p3');
      expect(fakeRoble.projects.first['current_members'], 2);

      // Si se llena
      fakeRoble.projects.first['current_members'] = 3;
      await source.addMember('p3');
      expect(fakeRoble.projects.first['current_members'], 3);
    });

    Map<String, dynamic> proyecto(String id, int miembros) => {
      '_id': id,
      'title': 'Proyecto',
      'problem': '',
      'description': '',
      'stage': 'idea',
      'academic_program': '',
      'current_members': miembros,
      'max_members': 4,
      'skills_wanted': [],
      'tags': [],
      'leader_id': 'l1',
      'recruitment_open': true,
    };

    test('removeMember resta uno a current_members', () async {
      fakeRoble.projects.add(proyecto('p4', 3));

      await source.removeMember('p4');

      expect(fakeRoble.projects.first['current_members'], 2);
    });

    test('removeMember nunca baja de 1, que es el lider', () async {
      fakeRoble.projects.add(proyecto('p5', 1));

      await source.removeMember('p5');

      expect(fakeRoble.projects.first['current_members'], 1);
    });

    test('removeMember de un proyecto que no existe no hace nada', () async {
      await source.removeMember('no-existe');

      expect(fakeRoble.projects, isEmpty);
    });

    test('updateStage escribe el nombre de la etapa en la columna stage',
        () async {
      fakeRoble.projects.add(proyecto('p6', 2));

      await source.updateStage('p6', ProjectStage.prototype);

      expect(fakeRoble.projects.first['stage'], 'prototype');
      expect(fakeRoble.projects.first['current_members'], 2);
    });
  });
}
