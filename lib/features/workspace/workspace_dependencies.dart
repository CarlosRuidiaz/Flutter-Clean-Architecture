import 'package:get/get.dart';

import '../application/domain/repositories/i_application_repository.dart';
import '../profile/domain/repositories/i_profile_repository.dart';
import 'data/datasources/i_workspace_source.dart';
import 'data/datasources/local/local_workspace_source.dart';
import 'data/repositories/workspace_repository.dart';
import 'domain/repositories/i_workspace_repository.dart';
import 'ui/viewmodels/workspace_controller.dart';

/// Composition root del feature `workspace`: el unico archivo que nombra a la
/// vez las clases concretas de las tres capas. Cambiar la fuente local por una
/// del servidor se hace aqui, en una linea.
///
/// `WorkspaceController` ademas resuelve `IApplicationRepository` e
/// `IProfileRepository`, que ya registraron `registerApplication()` y
/// `registerProfile()`. Por eso este va despues de esos dos en `main.dart`.
void registerWorkspace() {
  Get.put<IWorkspaceSource>(LocalWorkspaceSource());
  Get.put<IWorkspaceRepository>(WorkspaceRepository(Get.find()));
  // fenix: igual que en registerManagement. Sin esto, volver del espacio de
  // trabajo y entrar de nuevo lanza "WorkspaceController not found".
  Get.lazyPut(
    () => WorkspaceController(
      Get.find<IWorkspaceRepository>(),
      Get.find<IApplicationRepository>(),
      Get.find<IProfileRepository>(),
    ),
    fenix: true,
  );
}
