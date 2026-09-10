import 'package:get/get.dart';

import 'ui/viewmodels/management_controller.dart';

/// Composition root del feature `management`.
///
/// No registra ninguna fuente ni ningun repositorio porque el feature no tiene
/// los suyos: los dos `Get.find()` resuelven `IApplicationRepository` e
/// `IProjectRepository`, que ya registraron `registerApplication()` y
/// `registerProject()`. Por eso este va despues de esos dos en `main.dart`.
void registerManagement() {
  Get.lazyPut(() => ManagementController(Get.find(), Get.find()));
}
