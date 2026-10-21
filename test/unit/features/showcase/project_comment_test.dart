import 'package:flutter_test/flutter_test.dart';
import 'package:f_clean_template/features/showcase/domain/models/project_comment.dart';

void main() {
  group('ProjectComment', () {
    group('fromJson y toJson', () {
      test('conversion de ida y vuelta con todos los campos', () {
        final fecha = DateTime(2026, 10, 10, 14, 30);
        final original = ProjectComment(
          id: 'c1',
          projectId: 'p1',
          authorId: 'u1',
          authorName: 'Ana Lopez',
          text: 'Excelente propuesta.',
          parentId: 'parent_1',
          isTeam: true,
          createdAt: fecha,
        );

        final json = original.toJson();
        expect(json['_id'], 'c1');
        expect(json['project_id'], 'p1');
        expect(json['author_id'], 'u1');
        expect(json['author_name'], 'Ana Lopez');
        expect(json['text'], 'Excelente propuesta.');
        expect(json['parent_id'], 'parent_1');
        expect(json['is_team'], isTrue);
        expect(json['created_at'], fecha.toIso8601String());

        final reconstruido = ProjectComment.fromJson(json);
        expect(reconstruido.id, original.id);
        expect(reconstruido.projectId, original.projectId);
        expect(reconstruido.authorId, original.authorId);
        expect(reconstruido.authorName, original.authorName);
        expect(reconstruido.text, original.text);
        expect(reconstruido.parentId, original.parentId);
        expect(reconstruido.isTeam, original.isTeam);
        expect(reconstruido.createdAt, original.createdAt);
        expect(reconstruido.isReply, isTrue);
      });

      test('comentario raiz sin parentId ni id', () {
        final raiz = ProjectComment(
          projectId: 'p2',
          authorId: 'u2',
          authorName: 'Carlos',
          text: 'Pregunta sobre la tecnologia',
        );

        expect(raiz.isReply, isFalse);
        expect(raiz.parentId, isNull);

        final jsonNoId = raiz.toJsonNoId();
        expect(jsonNoId.containsKey('_id'), isFalse);
        expect(jsonNoId.containsKey('id'), isFalse);
        expect(jsonNoId['project_id'], 'p2');
        expect(jsonNoId['author_id'], 'u2');
        expect(jsonNoId['author_name'], 'Carlos');
        expect(jsonNoId['text'], 'Pregunta sobre la tecnologia');
        expect(jsonNoId.containsKey('parent_id'), isFalse);
        expect(jsonNoId['is_team'], isFalse);
      });

      test('fromJson con datos que faltan o vienen mal usa valores por defecto sin reventar', () {
        final jsonIncompleto = <String, dynamic>{
          'is_team': 'invalido',
          'created_at': 'no_es_fecha',
        };

        final comment = ProjectComment.fromJson(jsonIncompleto);

        expect(comment.id, isNull);
        expect(comment.projectId, isEmpty);
        expect(comment.authorId, isEmpty);
        expect(comment.authorName, isEmpty);
        expect(comment.text, isEmpty);
        expect(comment.parentId, isNull);
        expect(comment.isTeam, isFalse);
        expect(comment.createdAt, isNotNull);
        expect(comment.isReply, isFalse);
      });

      test('fromJson lee tanto _id como id y convierte cadenas booleanas', () {
        final jsonConId = {
          'id': 'c2',
          'project_id': 'p1',
          'author_id': 'u1',
          'author_name': 'Tester',
          'text': 'Test',
          'is_team': 'true',
        };
        final comment = ProjectComment.fromJson(jsonConId);
        expect(comment.id, 'c2');
        expect(comment.isTeam, isTrue);
      });

      test('ida y vuelta: lo que se envia en toJsonNoId vuelve igual con fromJson', () {
        final original = ProjectComment(
          projectId: 'p3',
          authorId: 'u3',
          authorName: 'Laura',
          text: 'Comentario de prueba',
          parentId: 'padre_x',
          isTeam: true,
        );

        final enviado = original.toJsonNoId();
        final devuelto = ProjectComment.fromJson(enviado);

        expect(devuelto.projectId, original.projectId);
        expect(devuelto.authorId, original.authorId);
        expect(devuelto.authorName, original.authorName);
        expect(devuelto.text, original.text);
        expect(devuelto.parentId, original.parentId);
        expect(devuelto.isTeam, original.isTeam);
        expect(devuelto.isReply, isTrue);
      });
    });
  });
}
