import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/app_tokens.dart';
import '../../domain/models/poll.dart';
import '../viewmodels/poll_controller.dart';

class PollResultsPage extends StatelessWidget {
  const PollResultsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final Poll poll = Get.arguments as Poll;
    final controller = Get.find<PollController>();
    final theme = Theme.of(context);

    // Make sure data is loaded if not already
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (poll.id != null) {
        controller.loadResponsesForPoll(poll.id!);
      }
    });

    return Scaffold(
      appBar: AppBar(title: const Text('Resultados')),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        final responses = controller.pollResponses[poll.id] ?? [];
        final total = responses.length;

        return RefreshIndicator(
          onRefresh: () => controller.loadResponsesForPoll(poll.id!),
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(AppTokens.gapL),
            children: [
              Text(poll.title, style: theme.textTheme.headlineSmall),
              if (poll.isActive) ...[
                const SizedBox(height: AppTokens.gapS),
                Text('Abierta hasta ${poll.closesAt.toLocal().toString().split('.')[0]}',
                    style: theme.textTheme.bodyMedium?.copyWith(color: AppColors.secondary)),
              ],
              const SizedBox(height: AppTokens.gapXl),
              for (int i = 0; i < poll.questions.length; i++) ...[
                Text('${i + 1}. ${poll.questions[i].text}',
                    style: theme.textTheme.titleMedium),
                const SizedBox(height: AppTokens.gapM),
                for (int j = 0; j < poll.questions[i].options.length; j++) ...[
                  Builder(
                    builder: (context) {
                      final count = responses.where((r) => r.answers.length > i && r.answers[i] == j).length;
                      final percent = total > 0 ? (count / total) : 0.0;
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(child: Text(poll.questions[i].options[j])),
                              Text('$count (${(percent * 100).toStringAsFixed(1)}%)',
                                  style: const TextStyle(fontWeight: FontWeight.bold)),
                            ],
                          ),
                          const SizedBox(height: AppTokens.gapXs),
                          LinearProgressIndicator(
                            value: percent,
                            backgroundColor: AppColors.card,
                            color: AppColors.persimmon,
                          ),
                          const SizedBox(height: AppTokens.gapM),
                        ],
                      );
                    }
                  ),
                ],
                const SizedBox(height: AppTokens.gapM),
              ],
              const SizedBox(height: AppTokens.gapXl),
              Text('Comentarios', style: theme.textTheme.titleMedium),
              const SizedBox(height: AppTokens.gapM),
              if (responses.every((r) => r.comment == null || r.comment!.isEmpty))
                Text('No hay comentarios.', style: theme.textTheme.bodyMedium)
              else
                ...responses.where((r) => r.comment != null && r.comment!.isNotEmpty).map((r) => Card(
                  margin: const EdgeInsets.only(bottom: AppTokens.gapS),
                  child: Padding(
                    padding: const EdgeInsets.all(AppTokens.gapM),
                    child: Text(r.comment!),
                  ),
                )),
            ],
          ),
        );
      }),
    );
  }
}
