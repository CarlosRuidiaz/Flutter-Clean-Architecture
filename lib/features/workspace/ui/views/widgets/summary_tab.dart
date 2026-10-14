import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../core/app_tokens.dart';
import '../../../../../core/widgets/paper_card.dart';
import '../../../../../core/widgets/pill.dart';
import '../../../ui/viewmodels/team_member.dart';
import '../../../ui/viewmodels/workspace_controller.dart';
import 'leave_project_sheet.dart';
import 'remove_member_sheet.dart';
import 'stage_selector.dart';
import '../../../../poll/ui/views/widgets/workspace_polls_block.dart';

/// Pestania "Resumen": estado actual, equipo y tarjeta de reclutamiento.
class WorkspaceSummaryTab extends StatelessWidget {
  const WorkspaceSummaryTab({super.key});

  static const List<Color> _coloresIniciales = [
    AppColors.petrol,
    AppColors.persimmon,
    AppColors.gold,
  ];

  String _iniciales(String nombre) {
    final partes = nombre
        .trim()
        .split(RegExp(r'\s+'))
        .where((p) => p.isNotEmpty);
    final letras = partes.take(2).map((p) => p[0].toUpperCase()).join();
    return letras.isEmpty ? '?' : letras;
  }

  Widget _memberRow(
    BuildContext context,
    TeamMember member,
    int index, {
    required bool puedeRemover,
  }) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    final String subtitulo = member.academicProgram.isEmpty
        ? member.role
        : '${member.academicProgram} · ${member.role}';

    return Padding(
      padding: const EdgeInsets.only(bottom: AppTokens.gapM),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: _coloresIniciales[index % _coloresIniciales.length],
            child: Text(
              _iniciales(member.name),
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: AppTokens.gapM),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(member.name, style: textTheme.titleMedium),
                Text(subtitulo, style: textTheme.bodySmall),
              ],
            ),
          ),
          if (puedeRemover && !member.isLeader)
            TextButton(
              style: TextButton.styleFrom(
                foregroundColor: AppColors.persimmon,
              ),
              onPressed: () => RemoveMemberSheet.show(context, member),
              child: const Text('Remover'),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final WorkspaceController controller = Get.find();
    final TextTheme textTheme = Theme.of(context).textTheme;

    return RefreshIndicator(
      onRefresh: controller.reload,
      child: Obx(() {
      final project = controller.project;
      if (project == null) return const SizedBox.shrink();

      final int cuposRestantes = project.maxMembers - project.currentMembers;

      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(AppTokens.gapL),
        children: [
          Text('Estado actual', style: textTheme.titleMedium),
          const SizedBox(height: AppTokens.gapS),
          WorkspaceStageSelector(stage: project.stage),
          const SizedBox(height: AppTokens.gapXl),
          Text('Miembros del equipo', style: textTheme.titleMedium),
          const SizedBox(height: AppTokens.gapM),
          for (int i = 0; i < controller.members.length; i++)
            _memberRow(
              context,
              controller.members[i],
              i,
              puedeRemover: controller.isLeader,
            ),
          const SizedBox(height: AppTokens.gapS),
          PaperCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Reclutamiento', style: textTheme.titleMedium),
                    Pill(
                      label: project.recruitmentOpen ? 'Abierto' : 'Cerrado',
                      background: project.recruitmentOpen
                          ? AppColors.petrol
                          : AppColors.card,
                      foreground: project.recruitmentOpen ? Colors.white : null,
                    ),
                  ],
                ),
                const SizedBox(height: AppTokens.gapS),
                Text(
                  cuposRestantes > 0
                      ? 'Quedan $cuposRestantes '
                          '${cuposRestantes == 1 ? 'cupo' : 'cupos'} de '
                          '${project.maxMembers}.'
                      : 'Sin cupos disponibles.',
                  style: textTheme.bodyMedium,
                ),
              ],
            ),
          ),
          if (controller.canLeave) ...[
            const SizedBox(height: AppTokens.gapXl),
            OutlinedButton(
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.persimmon,
                side: const BorderSide(
                  color: AppColors.persimmon,
                  width: AppTokens.borderWidth,
                ),
              ),
              onPressed: () => LeaveProjectSheet.show(context),
              child: const Text('Salir del proyecto'),
            ),
          ],
          const SizedBox(height: AppTokens.gapXl),
          WorkspacePollsBlock(project: project),
        ],
      );
    }),
    );
  }
}
