import 'package:get/get.dart';

import '../../application/domain/repositories/i_application_repository.dart';
import '../../auth/domain/repositories/i_auth_repository.dart';
import '../../profile/domain/repositories/i_profile_repository.dart';
import '../../project/domain/repositories/i_project_repository.dart';
import 'ui/viewmodels/my_projects_controller.dart';

void registerMyProjects() {
  Get.lazyPut(
    () => MyProjectsController(
      Get.find<IProjectRepository>(),
      Get.find<IApplicationRepository>(),
      Get.find<IProfileRepository>(),
      Get.find<IAuthRepository>(),
    ),
    fenix: true,
  );
}
