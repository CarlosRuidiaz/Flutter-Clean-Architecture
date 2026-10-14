import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../core/app_routes.dart';
import '../../../../../core/app_tokens.dart';
import '../../../../project/domain/models/project.dart';
import '../../../domain/models/poll.dart';
import '../../viewmodels/poll_controller.dart';

class ActivePollsBlock extends StatelessWidget {
  const ActivePollsBlock({super.key, required this.project});

  final Project project;

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<PollController>();
    final theme = Theme.of(context);

    // Make sure they are loaded
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (project.id != null) {
        controller.loadPollsForProject(project.id!);
      }
    });

    return Obx(() {
      if (project.id == null) return const SizedBox.shrink();
      
      final allPolls = controller.projectPolls[project.id!] ?? [];
      final activePolls = allPolls.where((p) => p.isActive).toList();

      if (activePolls.isEmpty) {
        return const SizedBox.shrink();
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: AppTokens.gapXl),
          Text('Encuestas activas', style: theme.textTheme.titleMedium),
          const SizedBox(height: AppTokens.gapM),
          ...activePolls.map((poll) => _PollCard(poll: poll)),
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
        onTap: () async {
          final canView = await controller.canViewResults(poll);
          if (canView) {
            Get.toNamed(AppRoutes.pollResults, arguments: poll);
            return;
          }
          final canRes = await controller.canRespond(poll);
          if (canRes) {
            Get.toNamed(AppRoutes.respondPoll, arguments: poll);
            return;
          }
          Get.snackbar('Acceso denegado', 'No puedes responder ni ver los resultados de esta encuesta.');
        },
        borderRadius: BorderRadius.circular(AppTokens.radius),
        child: Padding(
          padding: const EdgeInsets.all(AppTokens.gapM),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(poll.title, style: theme.textTheme.titleSmall),
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
