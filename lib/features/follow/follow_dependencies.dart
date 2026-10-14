import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:roble/roble.dart';

import '../auth/domain/repositories/i_auth_repository.dart';
import 'data/datasources/i_follow_source.dart';
import 'data/datasources/local/local_follow_source.dart';
import 'data/datasources/remote/roble_follow_source.dart';
import 'data/repositories/follow_repository.dart';
import 'domain/repositories/i_follow_repository.dart';
import 'ui/viewmodels/follow_controller.dart';

void registerFollow() {
  Get.lazyPut<IFollowSource>(
    () => kIsWeb || !Get.testMode
        ? RobleFollowSource(Get.find<RobleApiDataBase>())
        : LocalFollowSource(),
    fenix: true,
  );
  
  Get.lazyPut<IFollowRepository>(
    () => FollowRepository(Get.find<IFollowSource>()),
    fenix: true,
  );
  
  Get.lazyPut(
    () => FollowController(
      Get.find<IFollowRepository>(),
      Get.find<IAuthRepository>(),
    ),
    fenix: true,
  );
}
