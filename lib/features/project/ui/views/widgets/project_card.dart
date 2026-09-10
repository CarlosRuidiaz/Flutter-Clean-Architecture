import 'package:flutter/material.dart';

import '../../../../../core/app_tokens.dart';
import '../../../../../core/widgets/paper_card.dart';
import '../../../domain/models/project.dart';
import 'stage_chip.dart';

class ProjectCard extends StatelessWidget {
  const ProjectCard({super.key, required this.project, this.onTap});

  final Project project;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final TextTheme text = Theme.of(context).textTheme;

    return PaperCard(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(project.title, style: text.titleMedium),
          const SizedBox(height: AppTokens.gapS),
          Row(
            children: [
              StageChip(stage: project.stage),
              const SizedBox(width: AppTokens.gapS),
              Expanded(
                child: Text(
                  project.academicProgram,
                  style: text.bodySmall,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppTokens.gapS),
          Text(
            project.isFull
                ? 'Equipo completo (${project.currentMembers}/${project.maxMembers})'
                : '${project.currentMembers} de ${project.maxMembers} miembros',
            style: text.bodyMedium?.copyWith(
              color: project.isFull ? AppColors.persimmon : AppColors.ink,
              fontWeight: project.isFull ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
          if (project.skillsWanted.isNotEmpty) ...[
            const SizedBox(height: AppTokens.gapXs + 2),
            Text(
              'Busca: ${project.skillsWanted.join(" · ")}',
              style: text.bodySmall,
            ),
          ],
        ],
      ),
    );
  }
}
