import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../core/app_routes.dart';
import '../../../../../core/app_tokens.dart';
import '../../../../project/domain/models/project.dart';
import '../../../domain/models/poll.dart';
import '../../viewmodels/poll_controller.dart';

class WorkspacePollsBlock extends StatelessWidget {
  const WorkspacePollsBlock({super.key, required this.project});

  final Project project;

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<PollController>();
    final theme = Theme.of(context);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (project.id != null) {
        controller.loadPollsForProject(project.id!);
      }
    });

    return Obx(() {
      if (project.id == null) return const SizedBox.shrink();

      final polls = controller.projectPolls[project.id!] ?? [];

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Validación', style: theme.textTheme.titleMedium),
              TextButton.icon(
                onPressed: () => Get.toNamed(AppRoutes.createPoll, arguments: project),
                icon: const Icon(Icons.add),
                label: const Text('Crear encuesta'),
              ),
            ],
          ),
          const SizedBox(height: AppTokens.gapM),
          if (polls.isEmpty)
            Text('No hay encuestas creadas.', style: theme.textTheme.bodyMedium)
          else
            ...polls.map((poll) => _PollCard(poll: poll)),
        ],
      );
    });
  }
}

class _PollCard extends StatelessWidget {
  const _PollCard({required this.poll});

  final Poll poll;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final controller = Get.find<PollController>();

    return Card(
      margin: const EdgeInsets.only(bottom: AppTokens.gapS),
      child: InkWell(
        onTap: () {
          // El equipo siempre puede ver los resultados (lo valida canViewResults, pero desde workspace es obvio)
          Get.toNamed(AppRoutes.pollResults, arguments: poll);
        },
        borderRadius: BorderRadius.circular(AppTokens.radius),
        child: Padding(
          padding: const EdgeInsets.all(AppTokens.gapM),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(child: Text(poll.title, style: theme.textTheme.titleSmall)),
                  Text(poll.isActive ? 'Activa' : 'Cerrada',
                      style: theme.textTheme.bodySmall?.copyWith(
                          color: poll.isActive ? AppColors.gold : AppColors.secondary,
                          fontWeight: FontWeight.bold)),
                ],
              ),
              if (poll.audienceProgram != null) ...[
                const SizedBox(height: AppTokens.gapXs),
                Text('Para: ${poll.audienceProgram}', style: theme.textTheme.bodySmall?.copyWith(color: AppColors.secondary)),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
