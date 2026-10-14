import 'package:loggy/loggy.dart';
import 'package:roble/roble.dart';

import '../../../domain/models/project_comment.dart';
import '../../../domain/models/project_feedback.dart';
import '../i_showcase_source.dart';

class RobleShowcaseSource with UiLoggy implements IShowcaseSource {
  RobleShowcaseSource(this.roble);

  final RobleApiDataBase roble;

  @override
  Future<List<ProjectComment>> getComments(String projectId) async {
    loggy.debug('RobleShowcaseSource.getComments: consultando para $projectId');
    final records = await roble.read(
      'comments',
      filters: {'project_id': projectId},
    );
    return records.map(ProjectComment.fromJson).toList();
  }

  @override
  Future<ProjectComment> addComment(ProjectComment comment) async {
    loggy.debug('RobleShowcaseSource.addComment: insertando comentario');
    final record = await roble.create('comments', comment.toJsonNoId());
    return ProjectComment.fromJson(record);
  }

  @override
  Future<List<ProjectFeedback>> getFeedback(String projectId) async {
    loggy.debug('RobleShowcaseSource.getFeedback: consultando para $projectId');
    final records = await roble.read(
      'feedback',
      filters: {'project_id': projectId},
    );
    return records.map(ProjectFeedback.fromJson).toList();
  }

  @override
  Future<ProjectFeedback> saveFeedback(ProjectFeedback feedback) async {
    loggy.debug(
      'RobleShowcaseSource.saveFeedback: guardando feedback de ${feedback.authorId}',
    );
    if (feedback.id != null && feedback.id!.isNotEmpty) {
      final updated = await roble.update(
        'feedback',
        feedback.id!,
        feedback.toJsonNoId(),
      );
      return ProjectFeedback.fromJson(
        updated.isNotEmpty ? updated : feedback.toJson(),
      );
    }

    final existing = await roble.read(
      'feedback',
      filters: {
        'project_id': feedback.projectId,
        'author_id': feedback.authorId,
      },
    );

    if (existing.isNotEmpty) {
      final existingId =
          (existing.first['_id'] ?? existing.first['id'])?.toString();
      if (existingId != null && existingId.isNotEmpty) {
        final updated = await roble.update(
          'feedback',
          existingId,
          feedback.toJsonNoId(),
        );
        return ProjectFeedback.fromJson(
          updated.isNotEmpty
              ? updated
              : {...feedback.toJson(), '_id': existingId},
        );
      }
    }

    final created = await roble.create('feedback', feedback.toJsonNoId());
    return ProjectFeedback.fromJson(created);
  }
}
