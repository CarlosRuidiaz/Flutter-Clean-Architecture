import '../../../domain/models/follow.dart';
import '../i_follow_source.dart';

class LocalFollowSource implements IFollowSource {
  final List<Follow> _follows = [
    Follow(id: 'f1', projectId: '2', userId: 'u8', active: true),
  ];
  int _nextId = 2;

  @override
  Future<List<Follow>> getFollowsByUser(String userId) async {
    return _follows.where((f) => f.userId == userId && f.active).toList();
  }

  @override
  Future<Follow?> getFollow(String userId, String projectId) async {
    final matches = _follows.where(
        (f) => f.userId == userId && f.projectId == projectId);
    if (matches.isEmpty) return null;
    return matches.first;
  }

  @override
  Future<Follow> setFollow(Follow follow) async {
    final index = _follows.indexWhere(
        (f) => f.userId == follow.userId && f.projectId == follow.projectId);
    
    if (index >= 0) {
      _follows[index] = _follows[index].copyWith(active: follow.active);
      return _follows[index];
    } else {
      // We mutate the list directly. To simulate DB IDs:
      final f = Follow(
        id: 'f${_nextId++}',
        projectId: follow.projectId,
        userId: follow.userId,
        active: follow.active,
      );
      _follows.add(f);
      return f;
    }
  }
}
