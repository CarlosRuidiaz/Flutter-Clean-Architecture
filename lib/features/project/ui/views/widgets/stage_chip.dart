import 'package:flutter/material.dart';

import '../../../../../core/app_tokens.dart';
import '../../../../../core/widgets/pill.dart';
import '../../../domain/models/project.dart';

/// La etapa de un proyecto, pintada como pildora.
///
/// Traducir la etapa a espaniol y darle un color es trabajo de la UI: la
/// entidad no sabe de idiomas ni de `Color`.
class StageChip extends StatelessWidget {
  const StageChip({super.key, required this.stage});

  final ProjectStage stage;

  static String _label(ProjectStage s) {
    switch (s) {
      case ProjectStage.idea:
        return 'Idea';
      case ProjectStage.teamFormation:
        return 'Formando equipo';
      case ProjectStage.research:
        return 'Investigación';
      case ProjectStage.prototype:
        return 'Prototipo';
      case ProjectStage.testing:
        return 'Pruebas';
      case ProjectStage.finished:
        return 'Terminado';
    }
  }

  static Color _color(ProjectStage s) {
    switch (s) {
      case ProjectStage.idea:
        return AppStageColors.idea;
      case ProjectStage.teamFormation:
        return AppStageColors.teamFormation;
      case ProjectStage.research:
        return AppStageColors.research;
      case ProjectStage.prototype:
        return AppStageColors.prototype;
      case ProjectStage.testing:
        return AppStageColors.testing;
      case ProjectStage.finished:
        return AppStageColors.finished;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Pill(label: _label(stage), background: _color(stage));
  }
}
