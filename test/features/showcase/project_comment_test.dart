import 'package:flutter_test/flutter_test.dart';
import 'package:f_clean_template/features/showcase/domain/models/project_comment.dart';

void main() {
  group('ProjectComment', () {
    test('Conversión de ida y vuelta con todos los campos', () {
      final fecha = DateTime(2026, 10, 10, 14, 30);
      final original = ProjectComment(
        id: 'c1',
        projectId: 'p1',
        authorId: 'u1',
        authorName: 'Ana López',
        text: 'Excelente propuesta.',
        parentId: 'parent_1',
        isTeam: true,
        createdAt: fecha,
      );

      final json = original.toJson();
      expect(json['_id'], 'c1');
      expect(json['project_id'], 'p1');
      expect(json['author_id'], 'u1');
      expect(json['author_name'], 'Ana López');
      expect(json['text'], 'Excelente propuesta.');
      expect(json['parent_id'], 'parent_1');
      expect(json['is_team'], true);
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

    test('Comentario raíz sin parentId y sin id', () {
      final raiz = ProjectComment(
        projectId: 'p2',
        authorId: 'u2',
        authorName: 'Carlos',
        text: 'Pregunta sobre la tecnología',
      );

      expect(raiz.isReply, isFalse);
      expect(raiz.parentId, isNull);

      final jsonNoId = raiz.toJsonNoId();
      expect(jsonNoId.containsKey('_id'), isFalse);
      expect(jsonNoId.containsKey('id'), isFalse);
      expect(jsonNoId['project_id'], 'p2');
    });

    test('fromJson lee tanto _id como id y maneja formatos booleanos', () {
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
  });
}
