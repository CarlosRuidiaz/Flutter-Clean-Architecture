import 'package:get/get.dart';

import 'data/datasources/i_profile_source.dart';
import 'package:roble/roble.dart';

import '../auth/domain/repositories/i_auth_repository.dart';

import 'data/datasources/remote/roble_profile_source.dart';
import 'data/repositories/profile_repository.dart';
import 'domain/repositories/i_profile_repository.dart';
import 'ui/viewmodels/profile_controller.dart';

/// Composition root del feature `profile`: el unico archivo que nombra a la vez
/// las clases concretas de las tres capas. Cambiar de fuente local a Roble se
/// hace aqui, en una linea, sin tocar repositorio ni controlador.
void registerProfile() {
  // La instancia de Roble la registro main.dart: aqui solo se recibe.
  Get.put<IProfileSource>(RobleProfileSource(Get.find<RobleApiDataBase>()));
  Get.put<IProfileRepository>(ProfileRepository(Get.find()));
  Get.lazyPut(
    () => ProfileController(
      Get.find<IProfileRepository>(),
      Get.find<IAuthRepository>(),
    ),
  );
}
