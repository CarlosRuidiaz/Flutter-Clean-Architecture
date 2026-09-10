import 'package:flutter/material.dart';

import '../../../domain/models/project.dart';

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
        return const Color(0xFFF2B705);
      case ProjectStage.teamFormation:
        return const Color(0xFFE8552F);
      case ProjectStage.research:
        return const Color(0xFF2D5BFF);
      case ProjectStage.prototype:
        return const Color(0xFF0F5C56);
      case ProjectStage.testing:
        return const Color(0xFF6B4EE6);
      case ProjectStage.finished:
        return const Color(0xFF17150F);
    }
  }

  static Color _textColor(ProjectStage s) {
    switch (s) {
      case ProjectStage.idea:
        return Colors.black87;
      default:
        return Colors.white;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: _color(stage),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        _label(stage),
        style: TextStyle(
          color: _textColor(stage),
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}