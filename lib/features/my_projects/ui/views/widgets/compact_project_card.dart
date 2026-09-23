import 'package:flutter/material.dart';

import '../../../../../core/app_tokens.dart';
import '../../../../../core/widgets/paper_card.dart';
import '../../../../project/domain/models/project.dart';
import '../../../../project/ui/views/widgets/stage_chip.dart';

/// Tarjeta compacta de proyecto, usada en el perfil y en "Mis proyectos".
///
/// Muestra el título, la etapa como [StageChip] y "N de M miembros".
/// Acepta un [bottomWidget] opcional (por ejemplo, el rol del usuario) y un
/// [trailing] (por ejemplo, una píldora de pendientes).
class CompactProjectCard extends StatelessWidget {
  const CompactProjectCard({
    super.key,
    required this.project,
    this.bottomWidget,
    this.trailing,
    this.onTap,
  });

  final Project project;
  final Widget? bottomWidget;
  final Widget? trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return PaperCard(
      onTap: onTap,
      margin: const EdgeInsets.only(
        right: AppTokens.shadowOffset,
        bottom: AppTokens.shadowOffset,
      ),
      padding: const EdgeInsets.all(AppTokens.gapM),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  project.title,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: AppTokens.gapXs),
                Row(
                  children: [
                    StageChip(stage: project.stage),
                    const SizedBox(width: AppTokens.gapS),
                    Flexible(
                      child: Text(
                        '${project.currentMembers} de ${project.maxMembers} miembros',
                        style: theme.textTheme.bodySmall,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                if (bottomWidget != null) ...[
                  const SizedBox(height: AppTokens.gapXs),
                  bottomWidget!,
                ],
              ],
            ),
          ),
          if (trailing != null) ...[
            const SizedBox(width: AppTokens.gapS),
            trailing!,
          ],
        ],
      ),
    );
  }
}
