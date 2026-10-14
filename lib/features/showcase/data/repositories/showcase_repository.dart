import '../../domain/models/project_comment.dart';
import '../../domain/models/project_feedback.dart';
import '../../domain/repositories/i_showcase_repository.dart';
import '../datasources/i_showcase_source.dart';

class ShowcaseRepository implements IShowcaseRepository {
  ShowcaseRepository(this.source);

  final IShowcaseSource source;

  @override
  Future<List<ProjectComment>> getComments(String projectId) =>
      source.getComments(projectId);

  @override
  Future<ProjectComment> addComment(ProjectComment comment) =>
      source.addComment(comment);

  @override
  Future<List<ProjectFeedback>> getFeedback(String projectId) =>
      source.getFeedback(projectId);

  @override
  Future<ProjectFeedback> saveFeedback(ProjectFeedback feedback) =>
      source.saveFeedback(feedback);
}
