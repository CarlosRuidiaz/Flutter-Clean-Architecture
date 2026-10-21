import 'package:f_clean_template/features/workspace/domain/models/milestone.dart';
import 'package:f_clean_template/features/workspace/domain/models/progress_update.dart';
import 'package:f_clean_template/features/workspace/domain/models/project_task.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Milestone', () {
    test('fromJson lee las columnas de la tabla milestones', () {
      final hito = Milestone.fromJson({
        '_id': 'm1',
        'project_id': 'p1',
        'title': 'Prototipo',
        'due_date': '2026-10-30T00:00:00.000',
        'done': true,
      });

      expect(hito.id, 'm1');
      expect(hito.projectId, 'p1');
      expect(hito.title, 'Prototipo');
      expect(hito.dueDate, DateTime(2026, 10, 30));
      expect(hito.done, isTrue);
    });

    test('fromJson con datos que faltan o vienen mal usa valores por defecto sin reventar', () {
      final hito = Milestone.fromJson({
        'title': null,
        'due_date': null,
        'done': 'invalido',
      });

      expect(hito.id, isNull);
      expect(hito.projectId, isEmpty);
      expect(hito.title, isEmpty);
      expect(hito.dueDate, isNotNull);
      expect(hito.done, isFalse);
    });

    test('toJsonNoId manda la fecha como texto ISO 8601 y sin _id', () {
      final json = Milestone(
        id: 'm1',
        projectId: 'p1',
        title: 'Prototipo',
        dueDate: DateTime(2026, 10, 30),
      ).toJsonNoId();

      expect(json, {
        'project_id': 'p1',
        'title': 'Prototipo',
        'due_date': DateTime(2026, 10, 30).toIso8601String(),
        'done': false,
      });
      expect(json.containsKey('_id'), isFalse);
      expect(json.containsKey('id'), isFalse);
    });

    test('ida y vuelta: lo que se manda vuelve igual', () {
      final original = Milestone(
        projectId: 'p1',
        title: 'Entrega final',
        dueDate: DateTime(2026, 12, 1, 8, 30),
        done: true,
      );

      final vuelta = Milestone.fromJson({
        '_id': 'm9',
        ...original.toJsonNoId(),
      });

      expect(vuelta.id, 'm9');
      expect(vuelta.projectId, original.projectId);
      expect(vuelta.title, original.title);
      expect(vuelta.dueDate, original.dueDate);
      expect(vuelta.done, original.done);
    });

    test('lee el id de id si no viene _id, y done como texto', () {
      final hito = Milestone.fromJson({
        'id': 'm2',
        'project_id': 'p1',
        'title': 'x',
        'due_date': '2026-01-01T00:00:00.000',
        'done': 'true',
      });

      expect(hito.id, 'm2');
      expect(hito.done, isTrue);
    });
  });

  group('ProgressUpdate', () {
    test('fromJson lee las columnas de la tabla progress_updates', () {
      final avance = ProgressUpdate.fromJson({
        '_id': 'u1',
        'project_id': 'p1',
        'author_id': 'a1',
        'author_name': 'Ana',
        'title': 'Primer avance',
        'description': 'Arrancamos',
        'created_at': '2026-09-23T10:15:00.000',
        'completion_percentage': 60,
        'video_url': 'https://video.test/1',
        'milestone_id': 'm1',
      });

      expect(avance.id, 'u1');
      expect(avance.authorName, 'Ana');
      expect(avance.createdAt, DateTime(2026, 9, 23, 10, 15));
      expect(avance.completionPercentage, 60);
      expect(avance.videoUrl, 'https://video.test/1');
      expect(avance.milestoneId, 'm1');
    });

    test('fromJson con datos que faltan o vienen mal usa valores por defecto sin reventar', () {
      final avance = ProgressUpdate.fromJson({
        'title': null,
        'description': null,
        'created_at': 'no_es_fecha',
        'completion_percentage': 'no_es_numero',
      });

      expect(avance.id, isNull);
      expect(avance.projectId, isEmpty);
      expect(avance.authorId, isEmpty);
      expect(avance.authorName, isEmpty);
      expect(avance.title, isEmpty);
      expect(avance.description, isEmpty);
      expect(avance.completionPercentage, 0);
      expect(avance.videoUrl, isNull);
      expect(avance.milestoneId, isNull);
      expect(avance.createdAt, isNotNull);
    });

    test('video y hito vacios se leen como ausentes', () {
      final avance = ProgressUpdate.fromJson({
        '_id': 'u1',
        'project_id': 'p1',
        'author_id': 'a1',
        'author_name': 'Ana',
        'title': 't',
        'description': 'd',
        'created_at': '2026-09-23T10:15:00.000',
        'completion_percentage': 0,
        'video_url': '',
        'milestone_id': '   ',
      });

      expect(avance.videoUrl, isNull);
      expect(avance.milestoneId, isNull);
    });

    test('toJsonNoId manda los opcionales como texto vacio', () {
      final json = ProgressUpdate(
        projectId: 'p1',
        authorId: 'a1',
        authorName: 'Ana',
        title: 't',
        description: 'd',
        createdAt: DateTime(2026, 9, 23),
        completionPercentage: 40,
      ).toJsonNoId();

      expect(json['video_url'], '');
      expect(json['milestone_id'], '');
      expect(json['completion_percentage'], 40);
      expect(json['created_at'], DateTime(2026, 9, 23).toIso8601String());
      expect(json.containsKey('_id'), isFalse);
      expect(json.containsKey('id'), isFalse);
    });

    test('ida y vuelta: lo que se manda vuelve igual', () {
      final original = ProgressUpdate(
        projectId: 'p1',
        authorId: 'a1',
        authorName: 'Ana',
        title: 'Titulo',
        description: 'Descripcion',
        createdAt: DateTime(2026, 9, 23, 18, 5),
        completionPercentage: 75,
        videoUrl: 'https://video.test/2',
        milestoneId: 'm3',
      );

      final vuelta = ProgressUpdate.fromJson({
        '_id': 'u7',
        ...original.toJsonNoId(),
      });

      expect(vuelta.id, 'u7');
      expect(vuelta.title, original.title);
      expect(vuelta.createdAt, original.createdAt);
      expect(vuelta.completionPercentage, 75);
      expect(vuelta.videoUrl, original.videoUrl);
      expect(vuelta.milestoneId, original.milestoneId);
    });

    test('el porcentaje llega acotado de 0 a 100, aunque venga como texto', () {
      ProgressUpdate leer(dynamic valor) => ProgressUpdate.fromJson({
        'project_id': 'p1',
        'created_at': '2026-09-23T10:15:00.000',
        'completion_percentage': valor,
      });

      expect(leer('45').completionPercentage, 45);
      expect(leer(250).completionPercentage, 100);
      expect(leer(-5).completionPercentage, 0);
      expect(leer(null).completionPercentage, 0);
    });
  });

  group('ProjectTask', () {
    test('fromJson lee las columnas de la tabla tasks', () {
      final tarea = ProjectTask.fromJson({
        '_id': 't1',
        'project_id': 'p1',
        'title': 'Disenar logo',
        'assignee_name': 'Luis',
        'done': false,
      });

      expect(tarea.id, 't1');
      expect(tarea.projectId, 'p1');
      expect(tarea.title, 'Disenar logo');
      expect(tarea.assigneeName, 'Luis');
      expect(tarea.done, isFalse);
    });

    test('fromJson con datos que faltan o vienen mal usa valores por defecto sin reventar', () {
      final tarea = ProjectTask.fromJson({
        'title': null,
        'assignee_name': null,
        'done': 'falso_texto',
      });

      expect(tarea.id, isNull);
      expect(tarea.projectId, isEmpty);
      expect(tarea.title, isEmpty);
      expect(tarea.assigneeName, isEmpty);
      expect(tarea.done, isFalse);
    });

    test('toJsonNoId manda las columnas correctas sin id', () {
      final task = ProjectTask(
        id: 't_ignorar',
        projectId: 'p5',
        title: 'Crear pruebas',
        assigneeName: 'Carlos',
        done: true,
      );

      final json = task.toJsonNoId();
      expect(json, {
        'project_id': 'p5',
        'title': 'Crear pruebas',
        'assignee_name': 'Carlos',
        'done': true,
      });
      expect(json.containsKey('_id'), isFalse);
      expect(json.containsKey('id'), isFalse);
    });

    test('ida y vuelta: lo que se manda vuelve igual', () {
      final original = ProjectTask(
        projectId: 'p1',
        title: 'Escribir informe',
        assigneeName: 'Maria',
        done: true,
      );

      final vuelta = ProjectTask.fromJson({
        '_id': 't5',
        ...original.toJsonNoId(),
      });

      expect(vuelta.id, 't5');
      expect(vuelta.title, original.title);
      expect(vuelta.assigneeName, original.assigneeName);
      expect(vuelta.done, isTrue);
    });
  });
}
