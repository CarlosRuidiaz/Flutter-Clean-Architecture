import 'package:flutter/material.dart';

import 'package:f_clean_template/core/app_tokens.dart';
import 'package:f_clean_template/features/showcase/domain/models/feedback_summary.dart';

class FeedbackRatingBars extends StatelessWidget {
  const FeedbackRatingBars({
    super.key,
    required this.summary,
  });

  final FeedbackSummary summary;

  Widget _barRow({
    required BuildContext context,
    required String label,
    required double score,
  }) {
    final textTheme = Theme.of(context).textTheme;
    final int filledCount = score.round();
    final String scoreLabel = summary.isEmpty
        ? 'Sin datos'
        : '${score % 1 == 0 ? score.toInt() : score.toStringAsFixed(1)} de 5';

    return Padding(
      padding: const EdgeInsets.only(bottom: AppTokens.gapM),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.ink,
                ),
              ),
              Text(
                scoreLabel,
                style: textTheme.bodySmall?.copyWith(
                  color: AppColors.secondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppTokens.gapXs + 2),
          Row(
            children: List.generate(5, (index) {
              final isFilled = index < filledCount;
              return Expanded(
                child: Container(
                  height: 10,
                  margin: EdgeInsets.only(
                    right: index == 4 ? 0 : AppTokens.gapXs,
                  ),
                  decoration: BoxDecoration(
                    color: isFilled ? AppColors.persimmon : AppColors.card,
                    border: Border.all(
                      color: AppColors.ink,
                      width: 1.2,
                    ),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _barRow(
          context: context,
          label: 'Usabilidad',
          score: summary.usabilityAverage,
        ),
        _barRow(
          context: context,
          label: 'Innovación',
          score: summary.innovationAverage,
        ),
        _barRow(
          context: context,
          label: 'Diseño visual',
          score: summary.visualDesignAverage,
        ),
        _barRow(
          context: context,
          label: 'Factibilidad técnica',
          score: summary.feasibilityAverage,
        ),
      ],
    );
  }
}
