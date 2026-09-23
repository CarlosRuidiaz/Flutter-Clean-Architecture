import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../core/app_tokens.dart';
import '../../../domain/models/milestone.dart';
import '../../../domain/models/project_task.dart';
import '../../../ui/viewmodels/workspace_controller.dart';
import 'add_milestone_sheet.dart';
import 'add_task_sheet.dart';

/// Pestania "Tareas": los hitos, arriba, y las tareas del equipo, abajo.
class WorkspaceTasksTab extends StatelessWidget {
  const WorkspaceTasksTab({super.key});

  static const List<String> _meses = [
    'ene',
    'feb',
    'mar',
    'abr',
    'may',
    'jun',
    'jul',
    'ago',
    'sep',
    'oct',
    'nov',
    'dic',
  ];

  String _fecha(DateTime fecha) =>
      '${fecha.day} ${_meses[fecha.month - 1]} ${fecha.year}';

  String _iniciales(String nombre) {
    final partes = nombre
        .trim()
        .split(RegExp(r'\s+'))
        .where((p) => p.isNotEmpty);
    final letras = partes.take(2).map((p) => p[0].toUpperCase()).join();
    return letras.isEmpty ? '?' : letras;
  }

  Widget _milestoneRow(
    BuildContext context,
    WorkspaceController controller,
    Milestone milestone,
  ) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    final Color color = milestone.done ? AppColors.secondary : AppColors.ink;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppTokens.gapS),
      child: Row(
        children: [
          Checkbox(
            value: milestone.done,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(2),
            ),
            activeColor: AppColors.petrol,
            onChanged: controller.isLeader
                ? (checked) => controller.setMilestoneDone(
                      milestone.id ?? '',
                      checked ?? false,
                    )
                : null,
          ),
          const SizedBox(width: AppTokens.gapS),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  milestone.title,
                  style: textTheme.bodyLarge?.copyWith(color: color),
                ),
                Text(
                  _fecha(milestone.dueDate),
                  style: textTheme.bodySmall?.copyWith(color: color),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _taskRow(
    BuildContext context,
    WorkspaceController controller,
    ProjectTask task,
  ) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    final Color color = task.done ? AppColors.secondary : AppColors.ink;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppTokens.gapS),
      child: Row(
        children: [
          Checkbox(
            value: task.done,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(2),
            ),
            activeColor: AppColors.petrol,
            onChanged: (checked) => controller.setTaskDone(
              task.id ?? '',
              checked ?? false,
            ),
          ),
          const SizedBox(width: AppTokens.gapS),
          Expanded(
            child: Text(task.title, style: textTheme.bodyLarge?.copyWith(color: color)),
          ),
          CircleAvatar(
            radius: 14,
            backgroundColor: AppColors.paper,
            child: Text(
              _iniciales(task.assigneeName),
              style: const TextStyle(
                color: AppColors.ink,
                fontWeight: FontWeight.w700,
                fontSize: 11,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final WorkspaceController controller = Get.find();
    final TextTheme textTheme = Theme.of(context).textTheme;

    return Obx(() {
      final int total = controller.totalMilestones;
      final int cumplidos = controller.completedMilestones;

      return ListView(
        padding: const EdgeInsets.all(AppTokens.gapL),
        children: [
          Text(
            total == 0 ? 'Hitos · Sin hitos todavía' : 'Hitos · $cumplidos de $total cumplidos',
            style: textTheme.titleMedium,
          ),
          const SizedBox(height: AppTokens.gapM),
          if (controller.milestones.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: AppTokens.gapS),
              child: Text(
                controller.isLeader
                    ? 'Añade el primer hito para poder medir el avance.'
                    : 'El líder todavía no ha añadido hitos.',
                style: textTheme.bodySmall,
              ),
            )
          else
            for (final milestone in controller.milestones)
              _milestoneRow(context, controller, milestone),
          const SizedBox(height: AppTokens.gapXl),
          Text('Tareas pendientes', style: textTheme.titleMedium),
          const SizedBox(height: AppTokens.gapM),
          if (controller.tasks.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: AppTokens.gapS),
              child: Text(
                'Todavía no hay tareas. Añade la primera para repartir el '
                'trabajo.',
                style: textTheme.bodySmall,
              ),
            )
          else
            for (final task in controller.tasks) _taskRow(context, controller, task),
          const SizedBox(height: AppTokens.gapXl),
          OutlinedButton(
            onPressed: () => AddTaskSheet.show(context),
            child: const Text('Añadir tarea'),
          ),
          if (controller.isLeader) ...[
            const SizedBox(height: AppTokens.gapS),
            OutlinedButton(
              onPressed: () => AddMilestoneSheet.show(context),
              child: const Text('Añadir hito'),
            ),
          ],
        ],
      );
    });
  }
}
