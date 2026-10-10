import 'project_feedback.dart';

class FeedbackSummary {
  const FeedbackSummary({
    required this.usabilityAverage,
    required this.innovationAverage,
    required this.visualDesignAverage,
    required this.feasibilityAverage,
    required this.overallAverage,
    required this.totalCount,
  });

  final double usabilityAverage;
  final double innovationAverage;
  final double visualDesignAverage;
  final double feasibilityAverage;
  final double overallAverage;
  final int totalCount;

  bool get isEmpty => totalCount == 0;

  factory FeedbackSummary.fromList(List<ProjectFeedback> feedbacks) {
    if (feedbacks.isEmpty) {
      return const FeedbackSummary(
        usabilityAverage: 0.0,
        innovationAverage: 0.0,
        visualDesignAverage: 0.0,
        feasibilityAverage: 0.0,
        overallAverage: 0.0,
        totalCount: 0,
      );
    }

    final count = feedbacks.length;
    double sumUsability = 0;
    double sumInnovation = 0;
    double sumVisualDesign = 0;
    double sumFeasibility = 0;

    for (final f in feedbacks) {
      sumUsability += f.usability;
      sumInnovation += f.innovation;
      sumVisualDesign += f.visualDesign;
      sumFeasibility += f.feasibility;
    }

    final avgUsability = _roundOneDecimal(sumUsability / count);
    final avgInnovation = _roundOneDecimal(sumInnovation / count);
    final avgVisualDesign = _roundOneDecimal(sumVisualDesign / count);
    final avgFeasibility = _roundOneDecimal(sumFeasibility / count);
    final avgOverall = _roundOneDecimal(
      (avgUsability + avgInnovation + avgVisualDesign + avgFeasibility) / 4.0,
    );

    return FeedbackSummary(
      usabilityAverage: avgUsability,
      innovationAverage: avgInnovation,
      visualDesignAverage: avgVisualDesign,
      feasibilityAverage: avgFeasibility,
      overallAverage: avgOverall,
      totalCount: count,
    );
  }

  static double _roundOneDecimal(double value) {
    return (value * 10).roundToDouble() / 10;
  }
}
