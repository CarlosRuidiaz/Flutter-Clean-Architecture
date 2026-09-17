import 'package:get/get.dart';

import '../application/domain/repositories/i_application_repository.dart';
import '../project/domain/repositories/i_project_repository.dart';
import 'ui/viewmodels/management_controller.dart';

/// Composition root del feature `management`.
///
/// No registra ninguna fuente ni ningun repositorio porque el feature no tiene
/// los suyos: los dos `Get.find()` resuelven `IApplicationRepository` e
/// `IProjectRepository`, que ya registraron `registerApplication()` y
/// `registerProject()`. Por eso este va despues de esos dos en `main.dart`.
void registerManagement() {
  // fenix: GetX descarta el controlador al cerrarse la ruta que lo instancio.
  // Sin esto, volver de la pantalla 18 y entrar por segunda vez lanza
  // "ManagementController not found". Mismo motivo que en registerApplication.
  Get.lazyPut(
    () => ManagementController(
      Get.find<IApplicationRepository>(),
      Get.find<IProjectRepository>(),
    ),
    fenix: true,
  );
}
