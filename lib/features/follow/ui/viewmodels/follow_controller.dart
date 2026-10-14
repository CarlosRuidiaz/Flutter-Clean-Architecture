import 'dart:async';

import 'package:get/get.dart';
import 'package:loggy/loggy.dart';

import '../../../auth/domain/repositories/i_auth_repository.dart';
import '../../domain/models/follow.dart';
import '../../domain/repositories/i_follow_repository.dart';

class FollowController extends GetxController with UiLoggy {
  FollowController(this.followRepo, this.authRepo);

  final IFollowRepository followRepo;
  final IAuthRepository authRepo;

  StreamSubscription<bool>? _sessionSub;
  
  final RxBool isLoading = false.obs;
  final RxList<Follow> follows = <Follow>[].obs;

  @override
  void onInit() {
    super.onInit();
    _loadData();
    _sessionSub = authRepo.sessionChanges.listen((haySesion) {
      loggy.debug('FollowController: cambio de sesion (activa: $haySesion)');
      if (haySesion) {
        _loadData();
      } else {
        follows.clear();
      }
    });
  }

  @override
  void onClose() {
    _sessionSub?.cancel();
    super.onClose();
  }

  Future<void> reload() async => _loadData();

  Future<void> _loadData() async {
    loggy.debug('FollowController: _loadData()');
    isLoading.value = true;
    try {
      final user = await authRepo.getLoggedUser();
      if (user == null) {
        follows.clear();
        return;
      }
      follows.value = await followRepo.getFollowsByUser(user.id!);
    } catch (e) {
      loggy.error('Error cargando seguimientos: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> toggleFollow(String projectId, bool active) async {
    final user = await authRepo.getLoggedUser();
    if (user == null) return;
    
    try {
      final result = await followRepo.toggleFollow(user.id!, projectId, active);
      
      final index = follows.indexWhere((f) => f.projectId == projectId);
      if (active) {
        if (index == -1) follows.add(result);
      } else {
        if (index != -1) follows.removeAt(index);
      }
    } catch (e) {
      loggy.error('Error actualizando seguimiento: $e');
    }
  }

  bool isFollowing(String projectId) {
    return follows.any((f) => f.projectId == projectId);
  }
}
