import 'package:flutter/material.dart';

import '../../../domain/models/project.dart';
import 'stage_chip.dart';

class ProjectCard extends StatelessWidget {
  const ProjectCard({super.key, required this.project});

  final Project project;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              project.title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ) ??
                  const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                StageChip(stage: project.stage),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    project.academicProgram,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[700],
                        ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              project.isFull
                  ? 'Equipo completo (${project.currentMembers}/${project.maxMembers})'
                  : '${project.currentMembers} de ${project.maxMembers} miembros',
              style: TextStyle(
                color: project.isFull ? Colors.red[700] : Colors.grey[800],
                fontWeight: project.isFull ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
            if (project.skillsWanted.isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(
                'Busca: ${project.skillsWanted.join(" · ")}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey[600],
                    ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}