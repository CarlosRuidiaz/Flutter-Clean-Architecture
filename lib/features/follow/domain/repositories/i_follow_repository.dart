import '../models/follow.dart';

abstract class IFollowRepository {
  Future<List<Follow>> getFollowsByUser(String userId);
  Future<Follow?> getFollow(String userId, String projectId);
  Future<Follow> toggleFollow(String userId, String projectId, bool active);
}
