import '../../domain/models/follow.dart';
import '../datasources/i_follow_source.dart';
import '../../domain/repositories/i_follow_repository.dart';

class FollowRepository implements IFollowRepository {
  FollowRepository(this.source);

  final IFollowSource source;

  @override
  Future<List<Follow>> getFollowsByUser(String userId) async {
    return source.getFollowsByUser(userId);
  }

  @override
  Future<Follow?> getFollow(String userId, String projectId) async {
    return source.getFollow(userId, projectId);
  }

  @override
  Future<Follow> toggleFollow(String userId, String projectId, bool active) async {
    return source.setFollow(Follow(
      projectId: projectId,
      userId: userId,
      active: active,
    ));
  }
}
