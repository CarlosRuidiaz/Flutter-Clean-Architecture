import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:f_clean_template/features/follow/domain/models/follow.dart';

void main() {
  test('Follow to y from Json', () {
    final follow = Follow(id: '1', projectId: 'p1', userId: 'u1', active: true);
    final json = follow.toJsonNoId();
    
    expect(json['project_id'], 'p1');
    expect(json['active'], true);
    
    final parsed = Follow.fromJson({'_id': '1', ...json});
    expect(parsed.id, '1');
    expect(parsed.active, true);
  });
}
