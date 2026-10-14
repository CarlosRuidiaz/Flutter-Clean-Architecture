import 'package:get/get.dart';

import '../application/domain/repositories/i_application_repository.dart';
import '../auth/domain/repositories/i_auth_repository.dart';
import '../profile/domain/repositories/i_profile_repository.dart';
import '../project/domain/repositories/i_project_repository.dart';
import 'data/datasources/i_showcase_source.dart';
import 'data/datasources/remote/roble_showcase_source.dart';
import 'data/repositories/showcase_repository.dart';
import 'domain/repositories/i_showcase_repository.dart';
import 'ui/viewmodels/showcase_controller.dart';

void registerShowcase() {
  Get.put<IShowcaseSource>(RobleShowcaseSource(Get.find()));
  Get.put<IShowcaseRepository>(ShowcaseRepository(Get.find()));
  Get.lazyPut(
    () => ShowcaseController(
      Get.find<IProjectRepository>(),
      Get.find<IShowcaseRepository>(),
      Get.find<IProfileRepository>(),
      Get.find<IApplicationRepository>(),
      Get.find<IAuthRepository>(),
    ),
    fenix: true,
  );
}
