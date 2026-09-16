import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../core/app_tokens.dart';
import '../../viewmodels/application_controller.dart';

/// Hoja modal 15 de confirmación para retirar/cancelar una postulación.
///
/// Se muestra como [showModalBottomSheet] y no tiene ruta en `app_routes.dart`.
class WithdrawSheet extends StatelessWidget {
  const WithdrawSheet({
    super.key,
    required this.applicationId,
    this.onWithdrawn,
  });

  final String applicationId;
  final VoidCallback? onWithdrawn;

  static Future<void> show(
    BuildContext context, {
    required String applicationId,
    VoidCallback? onWithdrawn,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.card,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppTokens.radius * 3),
        ),
        side: BorderSide(
          color: AppColors.ink,
          width: AppTokens.borderWidth,
        ),
      ),
      builder: (_) => WithdrawSheet(
        applicationId: applicationId,
        onWithdrawn: onWithdrawn,
      ),
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
              '¿Cancelar tu postulación?',
              style: textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppTokens.gapM),
            Text(
              'Tu solicitud dejará de estar visible para el líder del proyecto. '
              'Podrás volver a postularte mientras el reclutamiento siga abierto.',
              style: textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppTokens.gapXl),
            ElevatedButton(
              onPressed: () async {
                final controller = Get.find<ApplicationController>();
                await controller.withdraw(applicationId);
                onWithdrawn?.call();
                if (context.mounted) {
                  Navigator.of(context).pop();
                }
              },
              child: const Text('Sí, cancelar postulación'),
            ),
            const SizedBox(height: AppTokens.gapS),
            OutlinedButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Volver'),
            ),
          ],
        ),
      ),
    );
  }
}
