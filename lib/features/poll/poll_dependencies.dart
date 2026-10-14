import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:roble/roble.dart';

import '../../application/domain/repositories/i_application_repository.dart';
import '../../auth/domain/repositories/i_auth_repository.dart';
import '../../profile/domain/repositories/i_profile_repository.dart';
import '../../project/domain/repositories/i_project_repository.dart';
import 'data/datasources/i_poll_source.dart';
import 'data/datasources/local/local_poll_source.dart';
import 'data/datasources/remote/roble_poll_source.dart';
import 'data/repositories/poll_repository.dart';
import 'domain/repositories/i_poll_repository.dart';
import 'ui/viewmodels/poll_controller.dart';

void registerPoll() {
  Get.lazyPut<IPollSource>(
    () => kIsWeb || !Get.testMode
        ? RoblePollSource(Get.find<RobleApiDataBase>())
        : LocalPollSource(),
    fenix: true,
  );
  
  Get.lazyPut<IPollRepository>(
    () => PollRepository(Get.find<IPollSource>()),
    fenix: true,
  );
  
  Get.lazyPut(
    () => PollController(
      Get.find<IPollRepository>(),
      Get.find<IAuthRepository>(),
      Get.find<IProfileRepository>(),
      Get.find<IProjectRepository>(),
      Get.find<IApplicationRepository>(),
    ),
    fenix: true,
  );
}
