import '../../../domain/models/project_comment.dart';
import '../../../domain/models/project_feedback.dart';
import '../i_showcase_source.dart';

class LocalShowcaseSource implements IShowcaseSource {
  final List<ProjectComment> _comments = [];
  final List<ProjectFeedback> _feedbacks = [];
  int _nextCommentId = 1;
  int _nextFeedbackId = 1;

  @override
  Future<List<ProjectComment>> getComments(String projectId) async {
    return _comments.where((c) => c.projectId == projectId).toList();
  }

  @override
  Future<ProjectComment> addComment(ProjectComment comment) async {
    final created = comment.copyWith(
      id: comment.id ?? 'comment_${_nextCommentId++}',
    );
    _comments.add(created);
    return created;
  }

  @override
  Future<List<ProjectFeedback>> getFeedback(String projectId) async {
    return _feedbacks.where((f) => f.projectId == projectId).toList();
  }

  @override
  Future<ProjectFeedback> saveFeedback(ProjectFeedback feedback) async {
    final index = _feedbacks.indexWhere(
      (f) =>
          f.projectId == feedback.projectId &&
          ((feedback.id != null && f.id == feedback.id) ||
              f.authorId == feedback.authorId),
    );

    if (index != -1) {
      final existing = _feedbacks[index];
      final updated = feedback.copyWith(id: existing.id);
      _feedbacks[index] = updated;
      return updated;
    }

    final created = feedback.copyWith(
      id: feedback.id ?? 'feedback_${_nextFeedbackId++}',
    );
    _feedbacks.add(created);
    return created;
  }
}
