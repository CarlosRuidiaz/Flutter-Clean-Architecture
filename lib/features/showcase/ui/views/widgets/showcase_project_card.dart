import 'package:flutter/material.dart';

import 'package:f_clean_template/core/app_tokens.dart';
import 'package:f_clean_template/core/widgets/paper_card.dart';
import 'package:f_clean_template/features/project/domain/models/project.dart';
import 'package:f_clean_template/features/project/ui/views/widgets/stage_chip.dart';

class ShowcaseProjectCard extends StatelessWidget {
  const ShowcaseProjectCard({
    super.key,
    required this.project,
    required this.commentCount,
    required this.overallAverage,
    required this.onTap,
  });

  final Project project;
  final int commentCount;
  final double overallAverage;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    final String statsText = overallAverage > 0
        ? '$commentCount comentarios · ${overallAverage.toStringAsFixed(1)} ★'
        : '$commentCount comentarios · Sin calificaciones';

    return PaperCard(
      onTap: onTap,
      padding: const EdgeInsets.all(AppTokens.gapM),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Cuadrado ilustrativo con patrón sutil
          Container(
            width: 76,
            height: 76,
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              color: AppColors.paper,
              borderRadius: AppTokens.borderRadius,
              border: AppTokens.border(),
            ),
            child: CustomPaint(
              painter: _HatchPatternPainter(),
            ),
          ),
          const SizedBox(width: AppTokens.gapM),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        project.title,
                        style: textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: AppTokens.gapXs),
                    const StageChip(stage: ProjectStage.prototype),
                  ],
                ),
                const SizedBox(height: AppTokens.gapXs),
                Text(
                  project.academicProgram,
                  style: textTheme.bodySmall?.copyWith(
                    color: AppColors.secondary,
                  ),
                ),
                const SizedBox(height: AppTokens.gapS),
                Text(
                  statsText,
                  style: textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.ink,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HatchPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.clipRRect(
      RRect.fromRectAndRadius(
        Offset.zero & size,
        const Radius.circular(AppTokens.radius),
      ),
    );
    final paint = Paint()
      ..color = AppColors.hatch
      ..strokeWidth = 2.0;

    for (double i = -size.height; i < size.width; i += 10) {
      canvas.drawLine(
        Offset(i, 0),
        Offset(i + size.height, size.height),
        paint,
      );
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
