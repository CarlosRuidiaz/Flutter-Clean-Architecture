import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../core/app_tokens.dart';
import '../../viewmodels/team_member.dart';
import '../../viewmodels/workspace_controller.dart';
import 'refrescar_listas.dart';

/// Hoja de confirmacion para que el lider remueva a un miembro.
class RemoveMemberSheet extends StatelessWidget {
  const RemoveMemberSheet({super.key, required this.member});

  final TeamMember member;

  static Future<void> show(BuildContext context, TeamMember member) {
    return showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.card,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppTokens.radius * 3),
        ),
        side: BorderSide(color: AppColors.ink, width: AppTokens.borderWidth),
      ),
      builder: (_) => RemoveMemberSheet(member: member),
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
              '¿Remover a ${member.name}?',
              style: textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppTokens.gapM),
            Text(
              'Saldrá del equipo y perderá el acceso al espacio de trabajo. '
              'No podrá volver a postularse a este proyecto.',
              style: textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppTokens.gapXl),
            ElevatedButton(
              onPressed: () async {
                await Get.find<WorkspaceController>().removeMember(member);
                refrescarListasDeProyectos();
                if (context.mounted) Navigator.of(context).pop();
              },
              child: const Text('Sí, remover'),
            ),
            const SizedBox(height: AppTokens.gapS),
            OutlinedButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
          ],
        ),
      ),
    );
  }
}
