import 'package:get/get.dart';

import '../project/domain/repositories/i_project_repository.dart';
import 'data/datasources/i_application_source.dart';
import 'data/datasources/local/local_application_source.dart';
import 'data/repositories/application_repository.dart';
import 'domain/repositories/i_application_repository.dart';
import 'ui/viewmodels/application_controller.dart';

/// Composition root del feature `application`: el unico archivo autorizado a
/// nombrar las clases concretas. Cambiar de fuente local a Roble es una linea
/// aqui. `ManagementController` tambien resuelve `IApplicationRepository` de
/// este registro.
void registerApplication() {
  Get.put<IApplicationSource>(LocalApplicationSource());
  Get.put<IApplicationRepository>(ApplicationRepository(Get.find()));
  // fenix: GetX descarta el controlador al cerrarse la ruta que lo uso. Sin
  // esto, el segundo `Get.find` tras volver de la pantalla 14 lanza
  // "ApplicationController not found".
  Get.lazyPut(
    () => ApplicationController(
      Get.find<IApplicationRepository>(),
      Get.find<IProjectRepository>(),
    ),
    fenix: true,
  );
}
