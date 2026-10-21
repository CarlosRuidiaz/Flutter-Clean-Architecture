import 'package:flutter_test/flutter_test.dart';
import 'package:roble/roble.dart';
import 'package:f_clean_template/features/showcase/data/datasources/remote/roble_showcase_source.dart';
import 'package:f_clean_template/features/showcase/domain/models/project_comment.dart';
import 'package:f_clean_template/features/showcase/domain/models/project_feedback.dart';

class FakeRobleDatabaseForShowcase extends RobleApiDataBase {
  FakeRobleDatabaseForShowcase()
      : super(
          config: RobleApiConfig.fromContract(
            baseUrl: 'https://roble.test-openlab.uninorte.edu.co',
            contractId: 'proyecto_test_12345678',
          ),
        );

  final List<Map<String, dynamic>> comments = [];
  final List<Map<String, dynamic>> feedback = [];

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
      throw Exception('Fallo de comunicacion con Roble');
    }
    if (tableName == 'comments') {
      if (filters != null && filters.containsKey('project_id')) {
        return comments
            .where((c) => c['project_id'] == filters['project_id'])
            .toList();
      }
      return comments;
    }
    if (tableName == 'feedback') {
      if (filters != null) {
        return feedback.where((f) {
          for (final entry in filters.entries) {
            if (f[entry.key] != entry.value) return false;
          }
          return true;
        }).toList();
      }
      return feedback;
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
    final record = Map<String, dynamic>.from(data);
    if (tableName == 'comments') {
      record['_id'] = 'c_${comments.length + 1}';
      comments.add(record);
      return record;
    }
    if (tableName == 'feedback') {
      record['_id'] = 'fb_${feedback.length + 1}';
      feedback.add(record);
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
    if (tableName == 'feedback') {
      for (final f in feedback) {
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
  group('RobleShowcaseSource', () {
    late FakeRobleDatabaseForShowcase fakeRoble;
    late RobleShowcaseSource source;

    setUp(() {
      fakeRoble = FakeRobleDatabaseForShowcase();
      source = RobleShowcaseSource(fakeRoble);
    });

    test('addComment inserta en tabla comments con toJsonNoId y getComments filtra por project_id', () async {
      final comment1 = ProjectComment(
        projectId: 'p1',
        authorId: 'u1',
        authorName: 'Camilo',
        text: 'Primer comentario',
      );
      final comment2 = ProjectComment(
        projectId: 'p2',
        authorId: 'u2',
        authorName: 'Laura',
        text: 'Otro proyecto',
      );

      final guardado = await source.addComment(comment1);
      expect(fakeRoble.lastCreateTable, 'comments');
      expect(fakeRoble.lastCreateData?['project_id'], 'p1');
      expect(guardado.id, isNotNull);

      await source.addComment(comment2);

      final p1Comments = await source.getComments('p1');
      expect(fakeRoble.lastReadTable, 'comments');
      expect(fakeRoble.lastFilters, {'project_id': 'p1'});
      expect(p1Comments.length, 1);
      expect(p1Comments.first.text, 'Primer comentario');
      expect(p1Comments.first.authorName, 'Camilo');
    });

    test('getComments propaga error cuando Roble falla', () async {
      fakeRoble.shouldThrowOnRead = true;
      expect(() => source.getComments('p1'), throwsA(isA<Exception>()));
    });

    test('getFeedback pide tabla feedback y propaga error cuando Roble falla', () async {
      fakeRoble.shouldThrowOnRead = true;
      expect(() => source.getFeedback('p1'), throwsA(isA<Exception>()));
    });

    test('saveFeedback crea fila y actualizar sobreescribe sin duplicar', () async {
      final fbInicial = ProjectFeedback(
        projectId: 'p1',
        authorId: 'u1',
        authorName: 'Estudiante 1',
        usability: 4,
        innovation: 4,
        visualDesign: 4,
        feasibility: 4,
      );

      final creado = await source.saveFeedback(fbInicial);
      expect(fakeRoble.lastCreateTable, 'feedback');
      expect(creado.id, 'fb_1');
      expect(fakeRoble.feedback.length, 1);

      // Mismo estudiante actualiza con ID o buscando por autor
      final fbActualizado = fbInicial.copyWith(
        id: creado.id,
        usability: 5,
        comment: 'Actualizado',
      );

      final actualizado = await source.saveFeedback(fbActualizado);
      expect(fakeRoble.lastUpdateTable, 'feedback');
      expect(fakeRoble.lastUpdateId, 'fb_1');
      expect(actualizado.id, 'fb_1');
      expect(actualizado.usability, 5);
      expect(fakeRoble.feedback.length, 1); // No duplico fila

      final lista = await source.getFeedback('p1');
      expect(fakeRoble.lastReadTable, 'feedback');
      expect(lista.length, 1);
      expect(lista.first.usability, 5);
      expect(lista.first.comment, 'Actualizado');
    });
  });
}
