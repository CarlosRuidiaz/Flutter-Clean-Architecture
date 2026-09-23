import 'package:get/get.dart';

import '../auth/domain/repositories/i_auth_repository.dart';
import '../profile/domain/repositories/i_profile_repository.dart';
import 'data/datasources/i_project_source.dart';
import 'data/datasources/remote/roble_project_source.dart';
import 'data/repositories/project_repository.dart';
import 'domain/repositories/i_project_repository.dart';
import 'ui/viewmodels/project_controller.dart';

/// Composition root del feature `project`.
///
/// `ProjectController` resuelve ademas `IProfileRepository`, que registro
/// `registerProfile()`. Por eso este va despues de aquel en `main.dart`, y
/// antes de `registerApplication()` y `registerManagement()`, que resuelven
/// `IProjectRepository` de aqui.
void registerProject() {
  Get.put<IProjectSource>(RobleProjectSource(Get.find()));
  Get.put<IProjectRepository>(ProjectRepository(Get.find()));
  Get.lazyPut(
    () => ProjectController(
      Get.find<IProjectRepository>(),
      Get.find<IProfileRepository>(),
      Get.find<IAuthRepository>(),
    ),
  );
}
