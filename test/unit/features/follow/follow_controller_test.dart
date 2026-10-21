import 'package:flutter_test/flutter_test.dart';
import 'package:f_clean_template/features/auth/domain/models/authentication_user.dart';
import 'package:f_clean_template/features/follow/domain/models/follow.dart';
import 'package:f_clean_template/features/follow/domain/repositories/i_follow_repository.dart';
import 'package:f_clean_template/features/follow/ui/viewmodels/follow_controller.dart';

import '../auth/fake_auth_repository.dart';

class _FakeFollowRepository implements IFollowRepository {
  final List<Follow> follows = [];
  bool shouldThrow = false;
  int toggleCallCount = 0;

  @override
  Future<List<Follow>> getFollowsByUser(String userId) async {
    if (shouldThrow) {
      throw Exception('Error cargando seguimientos');
    }
    return follows.where((f) => f.userId == userId && f.active).toList();
  }

  @override
  Future<Follow?> getFollow(String userId, String projectId) async {
    final match = follows.where((f) => f.userId == userId && f.projectId == projectId);
    return match.isEmpty ? null : match.first;
  }

  @override
  Future<Follow> toggleFollow(String userId, String projectId, bool active) async {
    toggleCallCount++;
    if (shouldThrow) {
      throw Exception('Error al alternar seguimiento');
    }
    final index = follows.indexWhere((f) => f.userId == userId && f.projectId == projectId);
    if (index != -1) {
      final updated = follows[index].copyWith(active: active);
      follows[index] = updated;
      return updated;
    } else {
      final nuevo = Follow(id: 'f_${follows.length + 1}', projectId: projectId, userId: userId, active: active);
      follows.add(nuevo);
      return nuevo;
    }
  }
}

class _FakeAuthRepoWithUser extends FakeAuthRepository {
  AuthenticationUser? currentUser;

  @override
  Future<AuthenticationUser?> getLoggedUser() async => currentUser;
}

void main() {
  group('FollowController', () {
    late _FakeFollowRepository followRepo;
    late _FakeAuthRepoWithUser authRepo;
    late FollowController controller;

    setUp(() {
      followRepo = _FakeFollowRepository();
      authRepo = _FakeAuthRepoWithUser();
      controller = FollowController(followRepo, authRepo);
    });

    tearDown(() {
      controller.onClose();
    });

    test('cargar seguimientos al inicio expone los proyectos seguidos', () async {
      authRepo.currentUser = AuthenticationUser(
        id: 'u1',
        email: 'u1@test.com',
        name: 'User 1',
        password: '',
      );
      followRepo.follows.add(Follow(id: 'f1', projectId: 'p1', userId: 'u1', active: true));

      controller.onInit();
      await Future<void>.delayed(const Duration(milliseconds: 50));

      expect(controller.follows.length, 1);
      expect(controller.isFollowing('p1'), isTrue);
      expect(controller.isFollowing('p2'), isFalse);
      expect(controller.isLoading.value, isFalse);
    });

    test('isLoading vuelve a false incluso si el repositorio falla al cargar', () async {
      authRepo.currentUser = AuthenticationUser(
        id: 'u1',
        email: 'u1@test.com',
        name: 'User 1',
        password: '',
      );
      followRepo.shouldThrow = true;

      controller.onInit();
      await Future<void>.delayed(const Duration(milliseconds: 50));

      expect(controller.isLoading.value, isFalse);
      expect(controller.follows, isEmpty);
    });

    test('seguir, dejar de seguir y volver a seguir actualiza la lista reactiva', () async {
      authRepo.currentUser = AuthenticationUser(
        id: 'u1',
        email: 'u1@test.com',
        name: 'User 1',
        password: '',
      );
      controller.onInit();
      await Future<void>.delayed(const Duration(milliseconds: 50));

      // 1. Seguir
      await controller.toggleFollow('p1', true);
      expect(controller.isFollowing('p1'), isTrue);
      expect(controller.follows.length, 1);

      // 2. Dejar de seguir
      await controller.toggleFollow('p1', false);
      expect(controller.isFollowing('p1'), isFalse);
      expect(controller.follows.isEmpty, isTrue);

      // 3. Volver a seguir
      await controller.toggleFollow('p1', true);
      expect(controller.isFollowing('p1'), isTrue);
      expect(controller.follows.length, 1);
      expect(followRepo.toggleCallCount, 3);
    });

    test('sin usuario autenticado no se puede seguir un proyecto', () async {
      authRepo.currentUser = null;
      controller.onInit();
      await Future<void>.delayed(const Duration(milliseconds: 50));

      await controller.toggleFollow('p1', true);

      expect(followRepo.toggleCallCount, 0);
      expect(controller.follows, isEmpty);
      expect(controller.isFollowing('p1'), isFalse);
    });

    test('cerrar sesion vacia los seguimientos y volver a iniciar recarga', () async {
      authRepo.currentUser = AuthenticationUser(
        id: 'u1',
        email: 'u1@test.com',
        name: 'User 1',
        password: '',
      );
      followRepo.follows.add(Follow(id: 'f1', projectId: 'p1', userId: 'u1', active: true));

      controller.onInit();
      await Future<void>.delayed(const Duration(milliseconds: 50));
      expect(controller.isFollowing('p1'), isTrue);

      // Cerrar sesion
      authRepo.emitirSesion(false);
      await Future<void>.delayed(const Duration(milliseconds: 50));
      expect(controller.follows, isEmpty);
      expect(controller.isFollowing('p1'), isFalse);

      // Iniciar sesion
      authRepo.emitirSesion(true);
      await Future<void>.delayed(const Duration(milliseconds: 50));
      expect(controller.follows.length, 1);
      expect(controller.isFollowing('p1'), isTrue);
    });
  });
}
