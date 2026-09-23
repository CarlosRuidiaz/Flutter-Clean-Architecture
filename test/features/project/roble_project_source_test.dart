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

  @override
  Future<List<Map<String, dynamic>>> read(
    String tableName, {
    Map<String, dynamic>? filters,
  }) async {
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

    test('getProjects devuelve la lista mapeada desde Roble', () async {
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
      expect(list.length, 1);
      expect(list.first.id, 'p1');
      expect(list.first.title, 'Proyecto Roble');
    });

    test('createProject inserta con toJsonNoId y devuelve el proyecto con _id', () async {
      final nuevo = Project(
        title: 'Nuevo Proyecto',
        problem: 'Prob',
        description: 'Desc',
        stage: ProjectStage.idea,
        academicProgram: 'Diseño',
        currentMembers: 1,
        maxMembers: 3,
        skillsWanted: const ['UX'],
        leaderId: 'l1',
      );

      final creado = await source.createProject(nuevo);
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
  });
}
