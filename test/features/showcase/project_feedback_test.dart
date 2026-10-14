import 'package:flutter_test/flutter_test.dart';
import 'package:f_clean_template/features/showcase/domain/models/feedback_summary.dart';
import 'package:f_clean_template/features/showcase/domain/models/project_feedback.dart';

void main() {
  group('ProjectFeedback y FeedbackSummary', () {
    test('Conversión de ida y vuelta con comentario opcional', () {
      final fecha = DateTime(2026, 10, 10, 12, 0);
      final original = ProjectFeedback(
        id: 'fb1',
        projectId: 'p1',
        authorId: 'u2',
        authorName: 'Laura',
        usability: 4,
        innovation: 5,
        visualDesign: 4,
        feasibility: 3,
        comment: 'Muy buena idea de diseño.',
        createdAt: fecha,
      );

      final json = original.toJson();
      expect(json['_id'], 'fb1');
      expect(json['project_id'], 'p1');
      expect(json['author_id'], 'u2');
      expect(json['usability'], 4);
      expect(json['innovation'], 5);
      expect(json['visual_design'], 4);
      expect(json['feasibility'], 3);
      expect(json['comment'], 'Muy buena idea de diseño.');

      final reconstruido = ProjectFeedback.fromJson(json);
      expect(reconstruido.id, original.id);
      expect(reconstruido.projectId, original.projectId);
      expect(reconstruido.authorId, original.authorId);
      expect(reconstruido.usability, 4);
      expect(reconstruido.innovation, 5);
      expect(reconstruido.visualDesign, 4);
      expect(reconstruido.feasibility, 3);
      expect(reconstruido.comment, 'Muy buena idea de diseño.');
      expect(reconstruido.createdAt, fecha);
    });

    test('Feedback sin comentarios ni id', () {
      final fb = ProjectFeedback(
        projectId: 'p1',
        authorId: 'u3',
        authorName: 'Mario',
        usability: 5,
        innovation: 4,
        visualDesign: 5,
        feasibility: 5,
      );

      final jsonNoId = fb.toJsonNoId();
      expect(jsonNoId.containsKey('_id'), isFalse);
      expect(jsonNoId.containsKey('comment'), isFalse);
      expect(jsonNoId['usability'], 5);
      expect(jsonNoId['feasibility'], 5);
    });

    test('FeedbackSummary con lista vacía devuelve 0.0 y conteo 0', () {
      final summary = FeedbackSummary.fromList([]);
      expect(summary.isEmpty, isTrue);
      expect(summary.totalCount, 0);
      expect(summary.usabilityAverage, 0.0);
      expect(summary.innovationAverage, 0.0);
      expect(summary.visualDesignAverage, 0.0);
      expect(summary.feasibilityAverage, 0.0);
      expect(summary.overallAverage, 0.0);
    });

    test('FeedbackSummary calcula promedios correctos con 1 decimal', () {
      final lista = [
        ProjectFeedback(
          projectId: 'p1',
          authorId: 'u1',
          authorName: 'A',
          usability: 4,
          innovation: 5,
          visualDesign: 4,
          feasibility: 3,
        ),
        ProjectFeedback(
          projectId: 'p1',
          authorId: 'u2',
          authorName: 'B',
          usability: 5,
          innovation: 4,
          visualDesign: 3,
          feasibility: 4,
        ),
      ];

      final summary = FeedbackSummary.fromList(lista);
      expect(summary.isEmpty, isFalse);
      expect(summary.totalCount, 2);
      // Usability: (4+5)/2 = 4.5
      expect(summary.usabilityAverage, 4.5);
      // Innovation: (5+4)/2 = 4.5
      expect(summary.innovationAverage, 4.5);
      // Visual design: (4+3)/2 = 3.5
      expect(summary.visualDesignAverage, 3.5);
      // Feasibility: (3+4)/2 = 3.5
      expect(summary.feasibilityAverage, 3.5);
      // Overall: (4.5 + 4.5 + 3.5 + 3.5) / 4 = 4.0
      expect(summary.overallAverage, 4.0);
    });
  });
}
