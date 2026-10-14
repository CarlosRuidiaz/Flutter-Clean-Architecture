import 'package:loggy/loggy.dart';
import 'package:roble/roble.dart';

import '../../../domain/models/follow.dart';
import '../i_follow_source.dart';

class RobleFollowSource with UiLoggy implements IFollowSource {
  RobleFollowSource(this.roble);

  final RobleApiDataBase roble;

  @override
  Future<List<Follow>> getFollowsByUser(String userId) async {
    loggy.debug('RobleFollowSource: buscando seguidos por $userId');
    final records = await roble.read('follows', filters: {'user_id': userId, 'active': true});
    return records.map(Follow.fromJson).toList();
  }

  @override
  Future<Follow?> getFollow(String userId, String projectId) async {
    loggy.debug('RobleFollowSource: buscando si $userId sigue a $projectId');
    final records = await roble.read('follows', filters: {
      'user_id': userId,
      'project_id': projectId,
    });
    if (records.isEmpty) return null;
    return Follow.fromJson(records.first);
  }

  @override
  Future<Follow> setFollow(Follow follow) async {
    loggy.debug('RobleFollowSource: actualizando follow a ${follow.active}');
    final records = await roble.read('follows', filters: {
      'user_id': follow.userId,
      'project_id': follow.projectId,
    });
    
    if (records.isNotEmpty) {
      final existing = Follow.fromJson(records.first);
      if (existing.active != follow.active) {
        await roble.update('follows', existing.id!, {'active': follow.active});
      }
      return existing.copyWith(active: follow.active);
    } else {
      final record = await roble.create('follows', follow.toJsonNoId());
      return Follow.fromJson(record);
    }
  }
}
