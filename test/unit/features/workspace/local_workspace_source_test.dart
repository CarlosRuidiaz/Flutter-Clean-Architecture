import 'package:flutter_test/flutter_test.dart';
import 'package:f_clean_template/features/workspace/data/datasources/local/local_workspace_source.dart';
import 'package:f_clean_template/features/workspace/domain/models/milestone.dart';
import 'package:f_clean_template/features/workspace/domain/models/progress_update.dart';
import 'package:f_clean_template/features/workspace/domain/models/project_task.dart';

void main() {
  group('LocalWorkspaceSource', () {
    late LocalWorkspaceSource source;

    setUp(() {
      source = LocalWorkspaceSource();
    });

    group('hitos', () {
      test('addMilestone asigna un id y getMilestones filtra por projectId', () async {
        final m1 = await source.addMilestone(Milestone(
          projectId: 'p1',
          title: 'Hito 1',
          dueDate: DateTime(2026, 11, 1),
        ));
        final m2 = await source.addMilestone(Milestone(
          projectId: 'p2',
          title: 'Hito de otro proyecto',
          dueDate: DateTime(2026, 11, 5),
        ));

        expect(m1.id, '1');
        expect(m2.id, '2');

        final hitosP1 = await source.getMilestones('p1');
        expect(hitosP1.length, 1);
        expect(hitosP1.first.title, 'Hito 1');
        expect(hitosP1.first.done, isFalse);

        final hitosP2 = await source.getMilestones('p2');
        expect(hitosP2.length, 1);
        expect(hitosP2.first.title, 'Hito de otro proyecto');
      });

      test('setMilestoneDone actualiza el estado done del hito', () async {
        final m = await source.addMilestone(Milestone(
          projectId: 'p1',
          title: 'Hito inicial',
          dueDate: DateTime(2026, 11, 1),
        ));
        expect(m.done, isFalse);

        await source.setMilestoneDone(m.id!, true);

        final actualizados = await source.getMilestones('p1');
        expect(actualizados.first.done, isTrue);

        await source.setMilestoneDone(m.id!, false);
        final desmarcados = await source.getMilestones('p1');
        expect(desmarcados.first.done, isFalse);
      });
    });

    group('tareas', () {
      test('addTask asigna un id y getTasks filtra por projectId', () async {
        final t1 = await source.addTask(ProjectTask(
          projectId: 'p1',
          title: 'Configurar entorno',
          assigneeName: 'Carlos',
          done: false,
        ));
        final t2 = await source.addTask(ProjectTask(
          projectId: 'p2',
          title: 'Tarea p2',
          assigneeName: 'Ana',
          done: true,
        ));

        expect(t1.id, '1');
        expect(t2.id, '2');

        final tareasP1 = await source.getTasks('p1');
        expect(tareasP1.length, 1);
        expect(tareasP1.first.title, 'Configurar entorno');
        expect(tareasP1.first.assigneeName, 'Carlos');
      });

      test('setTaskDone actualiza el estado done de la tarea', () async {
        final t = await source.addTask(ProjectTask(
          projectId: 'p1',
          title: 'Investigar arquitectura',
          assigneeName: 'Carlos',
          done: false,
        ));

        await source.setTaskDone(t.id!, true);

        final tareas = await source.getTasks('p1');
        expect(tareas.first.done, isTrue);
      });
    });

    group('avances', () {
      test('publishUpdate asigna id, getUpdates filtra por proyecto y ordena por fecha descendente', () async {
        final fecha1 = DateTime(2026, 9, 10, 10, 0);
        final fecha2 = DateTime(2026, 9, 20, 15, 0);

        await source.publishUpdate(ProgressUpdate(
          projectId: 'p1',
          authorId: 'u1',
          authorName: 'Ana',
          title: 'Avance antiguo',
          description: '',
          createdAt: fecha1,
          completionPercentage: 20,
        ));

        await source.publishUpdate(ProgressUpdate(
          projectId: 'p1',
          authorId: 'u1',
          authorName: 'Ana',
          title: 'Avance reciente',
          description: '',
          createdAt: fecha2,
          completionPercentage: 50,
        ));

        final avances = await source.getUpdates('p1');
        expect(avances.length, 2);
        // Orden descendente por createdAt
        expect(avances.first.title, 'Avance reciente');
        expect(avances.last.title, 'Avance antiguo');
      });

      test('publishUpdate que referencia un hito lo marca como completado automaticamente', () async {
        final hito = await source.addMilestone(Milestone(
          projectId: 'p1',
          title: 'Diseno terminado',
          dueDate: DateTime(2026, 10, 1),
        ));
        expect(hito.done, isFalse);

        await source.publishUpdate(ProgressUpdate(
          projectId: 'p1',
          authorId: 'u1',
          authorName: 'Ana',
          title: 'Publicacion de avance',
          description: 'Hito cumplido',
          createdAt: DateTime.now(),
          completionPercentage: 40,
          milestoneId: hito.id,
        ));

        final hitosActualizados = await source.getMilestones('p1');
        expect(hitosActualizados.first.done, isTrue);
      });
    });
  });
}
