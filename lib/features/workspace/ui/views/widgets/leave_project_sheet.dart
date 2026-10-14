import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../core/app_tokens.dart';
import '../../viewmodels/workspace_controller.dart';
import 'refrescar_listas.dart';

/// Hoja de confirmacion para salir de un proyecto. No tiene ruta: se abre con
/// [showModalBottomSheet] desde el Resumen del espacio de trabajo.
class LeaveProjectSheet extends StatelessWidget {
  const LeaveProjectSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.card,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppTokens.radius * 3),
        ),
        side: BorderSide(color: AppColors.ink, width: AppTokens.borderWidth),
      ),
      builder: (_) => const LeaveProjectSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppTokens.gapL,
          vertical: AppTokens.gapXl,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              '¿Salir del proyecto?',
              style: textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppTokens.gapM),
            Text(
              'Dejarás el equipo y ya no verás su espacio de trabajo. '
              'Podrás volver a postularte mientras el reclutamiento siga '
              'abierto.',
              style: textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppTokens.gapXl),
            ElevatedButton(
              onPressed: () async {
                final salio = await Get.find<WorkspaceController>().leave();
                refrescarListasDeProyectos();
                if (context.mounted) Navigator.of(context).pop();
                // De vuelta a la pantalla principal: este espacio de trabajo
                // ya no es suyo.
                if (salio) Get.until((route) => route.isFirst);
              },
              child: const Text('Sí, salir del proyecto'),
            ),
            const SizedBox(height: AppTokens.gapS),
            OutlinedButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Quedarme'),
            ),
          ],
        ),
      ),
    );
  }
}
