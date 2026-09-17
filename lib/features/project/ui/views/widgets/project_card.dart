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
          StageChip(stage: project.stage),
          const SizedBox(height: AppTokens.gapS),
          Text(
            '${project.academicProgram} · '
            '${project.currentMembers} de ${project.maxMembers} miembros',
            style: text.bodyMedium,
          ),
          const SizedBox(height: AppTokens.gapXs + 2),
          if (project.acceptsApplications)
            // Solo tiene sentido decir que busca gente si aun puede recibirla.
            if (project.skillsWanted.isNotEmpty)
              Text(
                'Busca: ${project.skillsWanted.join(" · ")}',
                style: text.bodySmall,
              )
            else
              Text('Abierto a postulaciones', style: text.bodySmall)
          else
            Text(
              // Un equipo de 3 de 4 con el reclutamiento cerrado no esta
              // completo: decir "Equipo completo" ahi seria mentira.
              project.isFull
                  ? 'Equipo completo · reclutamiento cerrado'
                  : 'Reclutamiento cerrado',
              style: text.bodySmall?.copyWith(
                color: AppColors.persimmon,
                fontWeight: FontWeight.w600,
              ),
            ),
        ],
      ),
    );
  }
}
