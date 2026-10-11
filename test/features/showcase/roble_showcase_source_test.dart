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

  @override
  Future<List<Map<String, dynamic>>> read(
    String tableName, {
    Map<String, dynamic>? filters,
  }) async {
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

    test('addComment y getComments filtran por project_id', () async {
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
      expect(guardado.id, isNotNull);
      await source.addComment(comment2);

      final p1Comments = await source.getComments('p1');
      expect(p1Comments.length, 1);
      expect(p1Comments.first.text, 'Primer comentario');
      expect(p1Comments.first.authorName, 'Camilo');
    });

    test('saveFeedback crea fila y actualizar sobreescribe sin duplicar',
        () async {
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
      expect(creado.id, 'fb_1');
      expect(fakeRoble.feedback.length, 1);

      // Mismo estudiante actualiza con ID o buscando por autor
      final fbActualizado = fbInicial.copyWith(
        id: creado.id,
        usability: 5,
        comment: 'Actualizado',
      );

      final actualizado = await source.saveFeedback(fbActualizado);
      expect(actualizado.id, 'fb_1');
      expect(actualizado.usability, 5);
      expect(fakeRoble.feedback.length, 1); // No duplicó fila

      final lista = await source.getFeedback('p1');
      expect(lista.length, 1);
      expect(lista.first.usability, 5);
      expect(lista.first.comment, 'Actualizado');
    });
  });
}
