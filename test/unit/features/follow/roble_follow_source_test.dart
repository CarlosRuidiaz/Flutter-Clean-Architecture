import 'package:flutter_test/flutter_test.dart';
import 'package:roble/roble.dart';
import 'package:f_clean_template/features/follow/data/datasources/remote/roble_follow_source.dart';
import 'package:f_clean_template/features/follow/domain/models/follow.dart';

class FakeRobleDatabaseForFollow extends RobleApiDataBase {
  FakeRobleDatabaseForFollow()
      : super(
          config: RobleApiConfig.fromContract(
            baseUrl: 'https://roble.test-openlab.uninorte.edu.co',
            contractId: 'proyecto_test_12345678',
          ),
        );

  final List<Map<String, dynamic>> follows = [];
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
      throw Exception('Error al conectar con Roble');
    }
    if (tableName == 'follows') {
      if (filters != null) {
        return follows.where((f) {
          for (final entry in filters.entries) {
            if (f[entry.key] != entry.value) return false;
          }
          return true;
        }).toList();
      }
      return follows;
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
    if (tableName == 'follows') {
      final record = Map<String, dynamic>.from(data);
      record['_id'] = 'f_${follows.length + 1}';
      follows.add(record);
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
    if (tableName == 'follows') {
      for (final f in follows) {
        if (f['_id'] == id.toString()) {
          f.addAll(data);
          return f;
        }
      }
    }
    return {};
  }
}

void main() {
  group('RobleFollowSource', () {
    late FakeRobleDatabaseForFollow fakeRoble;
    late RobleFollowSource source;

    setUp(() {
      fakeRoble = FakeRobleDatabaseForFollow();
      source = RobleFollowSource(fakeRoble);
    });

    test('getFollowsByUser pide tabla follows con filtros user_id y active true', () async {
      fakeRoble.follows.addAll([
        {'_id': 'f1', 'project_id': 'p1', 'user_id': 'u1', 'active': true},
        {'_id': 'f2', 'project_id': 'p2', 'user_id': 'u1', 'active': false},
        {'_id': 'f3', 'project_id': 'p3', 'user_id': 'u2', 'active': true},
      ]);

      final resultado = await source.getFollowsByUser('u1');

      expect(fakeRoble.lastReadTable, 'follows');
      expect(fakeRoble.lastFilters, {'user_id': 'u1', 'active': true});
      expect(resultado.length, 1);
      expect(resultado.first.id, 'f1');
      expect(resultado.first.projectId, 'p1');
    });

    test('getFollowsByUser propaga error cuando Roble falla', () async {
      fakeRoble.shouldThrowOnRead = true;
      expect(() => source.getFollowsByUser('u1'), throwsA(isA<Exception>()));
    });

    test('getFollow pide tabla follows con filtros user_id y project_id', () async {
      fakeRoble.follows.add({
        '_id': 'f1',
        'project_id': 'p1',
        'user_id': 'u1',
        'active': true,
      });

      final follow = await source.getFollow('u1', 'p1');

      expect(fakeRoble.lastReadTable, 'follows');
      expect(fakeRoble.lastFilters, {'user_id': 'u1', 'project_id': 'p1'});
      expect(follow, isNotNull);
      expect(follow!.id, 'f1');

      final inexistente = await source.getFollow('u1', 'p999');
      expect(inexistente, isNull);
    });

    test('setFollow crea registro nuevo en follows con toJsonNoId si no existe', () async {
      final follow = Follow(projectId: 'p10', userId: 'u10', active: true);

      final resultado = await source.setFollow(follow);

      expect(fakeRoble.lastCreateTable, 'follows');
      expect(fakeRoble.lastCreateData, {
        'project_id': 'p10',
        'user_id': 'u10',
        'active': true,
      });
      expect(resultado.id, isNotNull);
      expect(fakeRoble.follows.length, 1);
    });

    test('setFollow actualiza solo active en registro existente sin duplicar', () async {
      fakeRoble.follows.add({
        '_id': 'f10',
        'project_id': 'p10',
        'user_id': 'u10',
        'active': true,
      });

      final followDesactivar = Follow(
        projectId: 'p10',
        userId: 'u10',
        active: false,
      );

      final resultado = await source.setFollow(followDesactivar);

      expect(fakeRoble.lastUpdateTable, 'follows');
      expect(fakeRoble.lastUpdateId, 'f10');
      expect(fakeRoble.lastUpdateData, {'active': false});
      expect(resultado.id, 'f10');
      expect(resultado.active, isFalse);
      expect(fakeRoble.follows.length, 1);
    });
  });
}
