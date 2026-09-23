import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../core/app_routes.dart';
import '../../../../../core/app_tokens.dart';
import '../../../domain/models/progress_update.dart';
import '../../../ui/viewmodels/workspace_controller.dart';

/// Pestania "Avances": la bitacora del proyecto, la mas reciente arriba.
class WorkspaceProgressTab extends StatelessWidget {
  const WorkspaceProgressTab({super.key});

  static const List<String> _meses = [
    'ENE',
    'FEB',
    'MAR',
    'ABR',
    'MAY',
    'JUN',
    'JUL',
    'AGO',
    'SEP',
    'OCT',
    'NOV',
    'DIC',
  ];

  String _fecha(DateTime fecha) =>
      '${fecha.day} ${_meses[fecha.month - 1]} ${fecha.year}';

  Widget _timelineItem(
    BuildContext context,
    ProgressUpdate update,
    bool esUltimo,
  ) {
    final TextTheme textTheme = Theme.of(context).textTheme;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: const BoxDecoration(
                  color: AppColors.persimmon,
                  shape: BoxShape.circle,
                ),
              ),
              if (!esUltimo)
                Expanded(child: Container(width: 2, color: AppColors.secondary)),
            ],
          ),
          const SizedBox(width: AppTokens.gapM),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: AppTokens.gapL),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _fecha(update.createdAt),
                    style: textTheme.labelSmall?.copyWith(
                      color: AppColors.secondary,
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: AppTokens.gapXs),
                  Text(update.title, style: textTheme.titleMedium),
                  const SizedBox(height: AppTokens.gapXs),
                  Text(update.description, style: textTheme.bodyMedium),
                ],
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

    return Obx(() {
      final updates = controller.updates;
      final project = controller.project;

      return Column(
        children: [
          Expanded(
            child: updates.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(AppTokens.gapXl),
                      child: Text(
                        'Todavía no hay avances. Publica el primero para '
                        'contarle al equipo en qué van.',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(AppTokens.gapL),
                    itemCount: updates.length,
                    itemBuilder: (context, i) => _timelineItem(
                      context,
                      updates[i],
                      i == updates.length - 1,
                    ),
                  ),
          ),
          Padding(
            padding: const EdgeInsets.all(AppTokens.gapL),
            child: ElevatedButton(
              onPressed: project == null
                  ? null
                  : () =>
                      Get.toNamed(AppRoutes.publishUpdate, arguments: project),
              child: const Text('Publicar avance'),
            ),
          ),
        ],
      );
    });
  }
}
