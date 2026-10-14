import '../../domain/models/follow.dart';

abstract class IFollowSource {
  Future<List<Follow>> getFollowsByUser(String userId);
  Future<Follow?> getFollow(String userId, String projectId);
  Future<Follow> setFollow(Follow follow);
}
