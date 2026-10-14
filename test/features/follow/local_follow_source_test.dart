import 'package:flutter_test/flutter_test.dart';
import 'package:f_clean_template/features/follow/domain/models/follow.dart';
import 'package:f_clean_template/features/follow/data/datasources/local/local_follow_source.dart';

void main() {
  test('LocalFollowSource - Seguir y dejar de seguir no duplica fila', () async {
    final source = LocalFollowSource();
    
    // Primero, crear un follow
    final f1 = await source.setFollow(Follow(projectId: 'p1', userId: 'u1', active: true));
    
    // Validar que se creó y esta activo
    final list1 = await source.getFollowsByUser('u1');
    expect(list1.length, 2); // 1 (default de local source) + 1 nuevo
    
    // Dejar de seguir
    await source.setFollow(Follow(projectId: 'p1', userId: 'u1', active: false));
    final list2 = await source.getFollowsByUser('u1');
    expect(list2.any((f) => f.projectId == 'p1'), false);
    
    // Volver a seguir
    await source.setFollow(Follow(projectId: 'p1', userId: 'u1', active: true));
    final list3 = await source.getFollowsByUser('u1');
    final followed = list3.firstWhere((f) => f.projectId == 'p1');
    
    // Asegurarse de que reutilizó el id (f1.id) y no creo otro
    expect(followed.id, f1.id);
  });
}
