import 'package:flutter_test/flutter_test.dart';
import 'package:roble/roble.dart';
import 'package:f_clean_template/features/application/data/datasources/remote/roble_application_source.dart';
import 'package:f_clean_template/features/application/domain/models/application.dart';

class FakeRobleDatabaseForApp extends RobleApiDataBase {
  FakeRobleDatabaseForApp()
      : super(
          config: RobleApiConfig.fromContract(
            baseUrl: 'https://roble.test-openlab.uninorte.edu.co',
            contractId: 'proyecto_test_12345678',
          ),
        );

  final List<Map<String, dynamic>> applications = [];
  String? lastReadTable;
  Map<String, dynamic>? lastFilters;
  String? lastCreateTable;
  Map<String, dynamic>? lastCreateData;
  String? lastUpdateTable;
  dynamic lastUpdateId;
  Map<String, dynamic>? lastUpdateData;
  bool shouldThrowOnRead = false;

  @override
  Future<List<Map<String, dynamic>>> read(
    String tableName, {
    Map<String, dynamic>? filters,
  }) async {
    lastReadTable = tableName;
    lastFilters = filters;
    if (shouldThrowOnRead) {
      throw Exception('Fallo de red en Roble');
    }
    if (tableName == 'applications') {
      if (filters != null) {
        return applications.where((app) {
          for (final entry in filters.entries) {
            if (app[entry.key] != entry.value) return false;
          }
          return true;
        }).toList();
      }
      return applications;
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
    if (tableName == 'applications') {
      final record = Map<String, dynamic>.from(data);
      record['_id'] = 'app_${applications.length + 1}';
      applications.add(record);
      return record;
    }
    return {};
  }

  @override
  Future<Map<String, dynamic>> update(
    String tableName,
    dynamic id,
    Map<String, dynamic> data,
  ) async {
    lastUpdateTable = tableName;
    lastUpdateId = id;
    lastUpdateData = data;
    if (tableName == 'applications') {
      for (final a in applications) {
        if (a['_id'] == id.toString()) {
          a.addAll(data);
          return a;
        }
      }
    }
    return {};
  }
}

void main() {
  group('RobleApplicationSource', () {
    late FakeRobleDatabaseForApp fakeRoble;
    late RobleApplicationSource source;

    setUp(() {
      fakeRoble = FakeRobleDatabaseForApp();
      source = RobleApplicationSource(fakeRoble);
    });

    test('getMyApplications pide tabla applications y filtra por applicant_id', () async {
      fakeRoble.applications.addAll([
        {
          '_id': 'a1',
          'project_id': 'p1',
          'applicant_id': 'u1',
          'applicant_name': 'User 1',
          'applicant_program': 'Sistemas',
          'applicant_semester': 5,
          'skills_offered': ['Dart'],
          'status': 'pending',
        },
        {
          '_id': 'a2',
          'project_id': 'p2',
          'applicant_id': 'u2',
          'applicant_name': 'User 2',
          'applicant_program': 'Diseno',
          'applicant_semester': 3,
          'skills_offered': [],
          'status': 'pending',
        },
      ]);

      final myApps = await source.getMyApplications('u1');
      expect(fakeRoble.lastReadTable, 'applications');
      expect(fakeRoble.lastFilters?['applicant_id'], 'u1');
      expect(myApps.length, 1);
      expect(myApps.first.id, 'a1');
      expect(myApps.first.applicantId, 'u1');
    });

    test('getMyApplications propaga error cuando Roble falla', () async {
      fakeRoble.shouldThrowOnRead = true;
      expect(() => source.getMyApplications('u1'), throwsA(isA<Exception>()));
    });

    test('getApplicationsFor pide tabla applications y filtra por project_id', () async {
      fakeRoble.applications.addAll([
        {
          '_id': 'a1',
          'project_id': 'p1',
          'applicant_id': 'u1',
          'applicant_name': 'User 1',
          'applicant_program': 'Sistemas',
          'applicant_semester': 5,
          'skills_offered': ['Dart'],
          'status': 'pending',
        },
        {
          '_id': 'a2',
          'project_id': 'p2',
          'applicant_id': 'u2',
          'applicant_name': 'User 2',
          'applicant_program': 'Diseno',
          'applicant_semester': 3,
          'skills_offered': [],
          'status': 'pending',
        },
      ]);

      final projApps = await source.getApplicationsFor('p2');
      expect(fakeRoble.lastReadTable, 'applications');
      expect(fakeRoble.lastFilters?['project_id'], 'p2');
      expect(projApps.length, 1);
      expect(projApps.first.id, 'a2');
      expect(projApps.first.projectId, 'p2');
    });

    test('apply devuelve postulacion existente si ya hay una pending o accepted', () async {
      fakeRoble.applications.add({
        '_id': 'a1',
        'project_id': 'p1',
        'applicant_id': 'u1',
        'applicant_name': 'User 1',
        'applicant_program': 'Sistemas',
        'applicant_semester': 5,
        'skills_offered': ['Dart'],
        'status': 'pending',
      });

      final nueva = Application(
        projectId: 'p1',
        applicantId: 'u1',
        applicantName: 'User 1',
        applicantProgram: 'Sistemas',
        applicantSemester: 5,
        skillsOffered: const ['Dart'],
      );

      final resultado = await source.apply(nueva);
      expect(resultado.id, 'a1');
      expect(fakeRoble.applications.length, 1);
    });

    test('apply crea postulacion nueva mandando skills_offered como texto JSON si no existe vigente', () async {
      final nueva = Application(
        projectId: 'p1',
        applicantId: 'u1',
        applicantName: 'User 1',
        applicantProgram: 'Sistemas',
        applicantSemester: 5,
        skillsOffered: const ['Dart'],
      );

      final resultado = await source.apply(nueva);
      expect(fakeRoble.lastCreateTable, 'applications');
      expect(fakeRoble.lastCreateData?['skills_offered'], isA<String>());
      expect(resultado.id, isNotNull);
      expect(fakeRoble.applications.length, 1);
    });

    test('withdraw actualiza unicamente status a withdrawn', () async {
      fakeRoble.applications.add({
        '_id': 'a1',
        'project_id': 'p1',
        'applicant_id': 'u1',
        'applicant_name': 'User 1',
        'applicant_program': 'Sistemas',
        'applicant_semester': 5,
        'skills_offered': [],
        'status': 'pending',
      });

      await source.withdraw('a1');
      expect(fakeRoble.lastUpdateTable, 'applications');
      expect(fakeRoble.lastUpdateId, 'a1');
      expect(fakeRoble.lastUpdateData, {'status': 'withdrawn'});
      expect(fakeRoble.applications.first['status'], 'withdrawn');
    });

    test('decide actualiza status a la decision indicada', () async {
      fakeRoble.applications.add({
        '_id': 'a1',
        'project_id': 'p1',
        'applicant_id': 'u1',
        'applicant_name': 'User 1',
        'applicant_program': 'Sistemas',
        'applicant_semester': 5,
        'skills_offered': [],
        'status': 'pending',
      });

      await source.decide('a1', ApplicationStatus.accepted);
      expect(fakeRoble.lastUpdateData, {'status': 'accepted'});
      expect(fakeRoble.applications.first['status'], 'accepted');
    });

    test('leave actualiza status a left', () async {
      fakeRoble.applications.add({
        '_id': 'a1',
        'project_id': 'p1',
        'applicant_id': 'u1',
        'applicant_name': 'User 1',
        'applicant_program': 'Sistemas',
        'applicant_semester': 5,
        'skills_offered': [],
        'status': 'accepted',
      });

      await source.leave('a1');
      expect(fakeRoble.lastUpdateData, {'status': 'left'});
      expect(fakeRoble.applications.first['status'], 'left');
    });

    test('decide con removed actualiza status a removed', () async {
      fakeRoble.applications.add({
        '_id': 'a1',
        'project_id': 'p1',
        'applicant_id': 'u1',
        'applicant_name': 'User 1',
        'applicant_program': 'Sistemas',
        'applicant_semester': 5,
        'skills_offered': [],
        'status': 'accepted',
      });

      await source.decide('a1', ApplicationStatus.removed);
      expect(fakeRoble.lastUpdateData, {'status': 'removed'});
      expect(fakeRoble.applications.first['status'], 'removed');
    });

    test('quien salio puede volver a postularse: se crea una nueva', () async {
      fakeRoble.applications.add({
        '_id': 'a1',
        'project_id': 'p1',
        'applicant_id': 'u1',
        'applicant_name': 'User 1',
        'applicant_program': 'Sistemas',
        'applicant_semester': 5,
        'skills_offered': [],
        'status': 'left',
      });

      final resultado = await source.apply(Application(
        projectId: 'p1',
        applicantId: 'u1',
        applicantName: 'User 1',
        applicantProgram: 'Sistemas',
        applicantSemester: 5,
        skillsOffered: const [],
      ));

      expect(resultado.id, isNot('a1'));
      expect(resultado.isPending, isTrue);
      expect(fakeRoble.applications.length, 2);
    });

    test('un removido no puede volver a postularse: apply devuelve la suya',
        () async {
      fakeRoble.applications.add({
        '_id': 'a1',
        'project_id': 'p1',
        'applicant_id': 'u1',
        'applicant_name': 'User 1',
        'applicant_program': 'Sistemas',
        'applicant_semester': 5,
        'skills_offered': [],
        'status': 'removed',
      });

      final resultado = await source.apply(Application(
        projectId: 'p1',
        applicantId: 'u1',
        applicantName: 'User 1',
        applicantProgram: 'Sistemas',
        applicantSemester: 5,
        skillsOffered: const [],
      ));

      expect(resultado.id, 'a1');
      expect(resultado.status, ApplicationStatus.removed);
      expect(fakeRoble.applications.length, 1);
    });

    test('un removido de un proyecto si puede postularse a otro', () async {
      fakeRoble.applications.add({
        '_id': 'a1',
        'project_id': 'p1',
        'applicant_id': 'u1',
        'applicant_name': 'User 1',
        'applicant_program': 'Sistemas',
        'applicant_semester': 5,
        'skills_offered': [],
        'status': 'removed',
      });

      final resultado = await source.apply(Application(
        projectId: 'p2',
        applicantId: 'u1',
        applicantName: 'User 1',
        applicantProgram: 'Sistemas',
        applicantSemester: 5,
        skillsOffered: const [],
      ));

      expect(resultado.projectId, 'p2');
      expect(resultado.isPending, isTrue);
      expect(fakeRoble.applications.length, 2);
    });
  });
}
