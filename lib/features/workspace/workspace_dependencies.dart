import 'package:get/get.dart';

import '../application/domain/repositories/i_application_repository.dart';
import '../profile/domain/repositories/i_profile_repository.dart';
import '../project/domain/repositories/i_project_repository.dart';
import 'data/datasources/i_workspace_source.dart';
import 'data/datasources/remote/roble_workspace_source.dart';
import 'data/repositories/workspace_repository.dart';
import 'domain/repositories/i_workspace_repository.dart';
import 'ui/viewmodels/workspace_controller.dart';

/// Composition root del feature `workspace`: el unico archivo que nombra a la
/// vez las clases concretas de las tres capas. Cambiar la fuente local por una
/// del servidor se hace aqui, en una linea.
///
/// `WorkspaceController` ademas resuelve `IApplicationRepository`,
/// `IProfileRepository` e `IProjectRepository`, que ya registraron
/// `registerApplication()`, `registerProfile()` y `registerProject()`. Por eso
/// este va despues de esos tres en `main.dart`.
void registerWorkspace({IWorkspaceSource? source}) {
  Get.put<IWorkspaceSource>(source ?? RobleWorkspaceSource(Get.find()));
  Get.put<IWorkspaceRepository>(WorkspaceRepository(Get.find()));
  // fenix: igual que en registerManagement. Sin esto, volver del espacio de
  // trabajo y entrar de nuevo lanza "WorkspaceController not found".
  Get.lazyPut(
    () => WorkspaceController(
      Get.find<IWorkspaceRepository>(),
      Get.find<IApplicationRepository>(),
      Get.find<IProfileRepository>(),
      Get.find<IProjectRepository>(),
    ),
    fenix: true,
  );
}
