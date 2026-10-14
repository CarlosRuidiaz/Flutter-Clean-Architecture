import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../core/app_tokens.dart';
import '../../../../../core/widgets/pill.dart';
import '../../../../project/domain/models/project.dart';
import '../../../../project/ui/views/widgets/stage_chip.dart';
import '../../viewmodels/workspace_controller.dart';
import 'refrescar_listas.dart';

/// La etapa actual del proyecto. Para el equipo es una etiqueta; para el lider,
/// las seis etapas como pildoras seleccionables, con la misma traduccion y el
/// mismo color que usan los filtros de la cartelera.
class WorkspaceStageSelector extends StatelessWidget {
  const WorkspaceStageSelector({super.key, required this.stage});

  final ProjectStage stage;

  @override
  Widget build(BuildContext context) {
    final WorkspaceController controller = Get.find();

    return Obx(() {
      if (!controller.isLeader) return StageChip(stage: stage);

      return Wrap(
        spacing: AppTokens.gapS,
        runSpacing: AppTokens.gapS,
        children: [
          for (final etapa in ProjectStage.values)
            InkWell(
              onTap: () async {
                if (etapa == stage) return;
                await controller.updateStage(etapa);
                refrescarListasDeProyectos();
              },
              borderRadius: BorderRadius.circular(999),
              child: Pill(
                label: StageChip.labelOf(etapa),
                background: etapa == stage
                    ? StageChip.colorOf(etapa)
                    : AppColors.card,
              ),
            ),
        ],
      );
    });
  }
}
