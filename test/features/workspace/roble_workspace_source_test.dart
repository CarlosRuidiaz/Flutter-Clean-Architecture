import 'package:f_clean_template/features/workspace/data/datasources/remote/roble_workspace_source.dart';
import 'package:f_clean_template/features/workspace/domain/models/milestone.dart';
import 'package:f_clean_template/features/workspace/domain/models/progress_update.dart';
import 'package:f_clean_template/features/workspace/domain/models/project_task.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:roble/roble.dart';

/// Roble falso, sin red: guarda las filas de cada tabla en memoria y recuerda
/// que filtros y que datos recibio, para poder comprobar lo que la fuente le
/// pide.
class _FakeRoble extends RobleApiDataBase {
  _FakeRoble()
    : super(
        config: RobleApiConfig.fromContract(
          baseUrl: 'https://roble.test-openlab.uninorte.edu.co',
          contractId: 'workspace_test_12345678',
        ),
      );

  final Map<String, List<Map<String, dynamic>>> tablas = {
    'milestones': [],
    'progress_updates': [],
    'tasks': [],
  };

  final List<Map<String, dynamic>?> filtrosRecibidos = [];
  final Map<String, List<Map<String, dynamic>>> enviado = {
    'milestones': [],
    'progress_updates': [],
    'tasks': [],
  };

  @override
  Future<List<Map<String, dynamic>>> read(
    String tableName, {
    Map<String, dynamic>? filters,
  }) async {
    filtrosRecibidos.add(filters);
    return (tablas[tableName] ?? []).where((fila) {
      if (filters == null) return true;
      return filters.entries.every(
        (e) => fila[e.key]?.toString() == e.value?.toString(),
      );
    }).toList();
  }

  @override
  Future<Map<String, dynamic>> create(
    String tableName,
    Map<String, dynamic> data,
  ) async {
    enviado[tableName]!.add(Map<String, dynamic>.from(data));
    final fila = Map<String, dynamic>.from(data);
    fila['_id'] = '${tableName}_${tablas[tableName]!.length + 1}';
    tablas[tableName]!.add(fila);
    return fila;
  }

  @override
  Future<Map<String, dynamic>> update(
    String tableName,
    dynamic id,
    Map<String, dynamic> data,
  ) async {
    for (final fila in tablas[tableName]!) {
      if (fila['_id'] == id.toString()) {
        fila.addAll(data);
        return fila;
      }
    }
    return {};
  }
}

Map<String, dynamic> _hito(String id, String projectId, {bool done = false}) =>
    {
      '_id': id,
      'project_id': projectId,
      'title': 'Hito $id',
      'due_date': '2026-10-30T00:00:00.000',
      'done': done,
    };

Map<String, dynamic> _avance(String id, String projectId, String creado) => {
  '_id': id,
  'project_id': projectId,
  'author_id': 'a1',
  'author_name': 'Ana',
  'title': 'Avance $id',
  'description': 'd',
  'created_at': creado,
  'completion_percentage': 0,
  'video_url': '',
  'milestone_id': '',
};

Map<String, dynamic> _tarea(String id, String projectId) => {
  '_id': id,
  'project_id': projectId,
  'title': 'Tarea $id',
  'assignee_name': 'Luis',
  'done': false,
};

void main() {
  group('RobleWorkspaceSource', () {
    late _FakeRoble roble;
    late RobleWorkspaceSource source;

    setUp(() {
      roble = _FakeRoble();
      source = RobleWorkspaceSource(roble);
    });

    group('hitos', () {
      test('getMilestones filtra por project_id', () async {
        roble.tablas['milestones']!.addAll([
          _hito('m1', 'p1'),
          _hito('m2', 'p2'),
          _hito('m3', 'p1'),
        ]);

        final hitos = await source.getMilestones('p1');

        expect(hitos.map((h) => h.id), ['m1', 'm3']);
        expect(roble.filtrosRecibidos.single, {'project_id': 'p1'});
      });

      test('addMilestone manda las columnas de la tabla y devuelve el _id',
          () async {
        final creado = await source.addMilestone(
          Milestone(
            projectId: 'p1',
            title: 'Prototipo',
            dueDate: DateTime(2026, 10, 30),
          ),
        );

        expect(roble.enviado['milestones']!.single, {
          'project_id': 'p1',
          'title': 'Prototipo',
          'due_date': DateTime(2026, 10, 30).toIso8601String(),
          'done': false,
        });
        expect(creado.id, 'milestones_1');
        expect(creado.title, 'Prototipo');
      });

      test('setMilestoneDone actualiza la columna done', () async {
        roble.tablas['milestones']!.add(_hito('m1', 'p1'));

        await source.setMilestoneDone('m1', true);

        expect(roble.tablas['milestones']!.single['done'], isTrue);
      });
    });

    group('avances', () {
      test('getUpdates filtra por project_id y devuelve el mas nuevo primero',
          () async {
        roble.tablas['progress_updates']!.addAll([
          _avance('u1', 'p1', '2026-09-01T10:00:00.000'),
          _avance('u2', 'p2', '2026-09-05T10:00:00.000'),
          _avance('u3', 'p1', '2026-09-20T10:00:00.000'),
          _avance('u4', 'p1', '2026-09-10T10:00:00.000'),
        ]);

        final avances = await source.getUpdates('p1');

        expect(avances.map((a) => a.id), ['u3', 'u4', 'u1']);
        expect(roble.filtrosRecibidos.single, {'project_id': 'p1'});
      });

      test('publishUpdate manda las columnas, incluido el porcentaje',
          () async {
        final creado = await source.publishUpdate(
          ProgressUpdate(
            projectId: 'p1',
            authorId: 'a1',
            authorName: 'Ana',
            title: 'Primer avance',
            description: 'Arrancamos',
            createdAt: DateTime(2026, 9, 23, 10),
            completionPercentage: 60,
          ),
        );

        expect(roble.enviado['progress_updates']!.single, {
          'project_id': 'p1',
          'author_id': 'a1',
          'author_name': 'Ana',
          'title': 'Primer avance',
          'description': 'Arrancamos',
          'created_at': DateTime(2026, 9, 23, 10).toIso8601String(),
          'completion_percentage': 60,
          'video_url': '',
          'milestone_id': '',
        });
        expect(creado.id, 'progress_updates_1');
        expect(creado.completionPercentage, 60);
      });

      test('publishUpdate con milestoneId marca ese hito como cumplido',
          () async {
        roble.tablas['milestones']!.addAll([
          _hito('m1', 'p1'),
          _hito('m2', 'p1'),
        ]);

        await source.publishUpdate(
          ProgressUpdate(
            projectId: 'p1',
            authorId: 'a1',
            authorName: 'Ana',
            title: 't',
            description: 'd',
            createdAt: DateTime(2026, 9, 23),
            completionPercentage: 50,
            milestoneId: 'm1',
          ),
        );

        expect(roble.tablas['milestones']![0]['done'], isTrue);
        expect(roble.tablas['milestones']![1]['done'], isFalse);
        expect(
          roble.enviado['progress_updates']!.single['milestone_id'],
          'm1',
        );
      });
    });

    group('tareas', () {
      test('getTasks filtra por project_id', () async {
        roble.tablas['tasks']!.addAll([
          _tarea('t1', 'p1'),
          _tarea('t2', 'p2'),
        ]);

        final tareas = await source.getTasks('p2');

        expect(tareas.map((t) => t.id), ['t2']);
        expect(roble.filtrosRecibidos.single, {'project_id': 'p2'});
      });

      test('addTask manda las columnas de la tabla y devuelve el _id', () async {
        final creada = await source.addTask(
          ProjectTask(
            projectId: 'p1',
            title: 'Disenar logo',
            assigneeName: 'Luis',
          ),
        );

        expect(roble.enviado['tasks']!.single, {
          'project_id': 'p1',
          'title': 'Disenar logo',
          'assignee_name': 'Luis',
          'done': false,
        });
        expect(creada.id, 'tasks_1');
      });

      test('setTaskDone actualiza la columna done', () async {
        roble.tablas['tasks']!.add(_tarea('t1', 'p1'));

        await source.setTaskDone('t1', true);

        expect(roble.tablas['tasks']!.single['done'], isTrue);
      });
    });
  });
}
