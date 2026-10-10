import '../../domain/models/project_comment.dart';
import '../../domain/models/project_feedback.dart';

abstract interface class IShowcaseSource {
  Future<List<ProjectComment>> getComments(String projectId);
  Future<ProjectComment> addComment(ProjectComment comment);
  Future<List<ProjectFeedback>> getFeedback(String projectId);
  Future<ProjectFeedback> saveFeedback(ProjectFeedback feedback);
}
