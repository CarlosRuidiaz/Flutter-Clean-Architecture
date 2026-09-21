import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'features/auth/ui/viewmodels/authentication_controller.dart';
import 'features/auth/ui/views/login_page.dart';
import 'features/project/ui/views/home_page.dart';

/// Decide la primera pantalla segun haya sesion o no.
///
/// `AuthenticationController.onInit` restaura la sesion guardada, asi que
/// quien ya entro una vez no vuelve a ver el login.
class Central extends StatelessWidget {
  const Central({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthenticationController authenticationController = Get.find();

    return Obx(
      () => authenticationController.isLogged
          ? const HomePage()
          : const LoginPage(),
    );
  }
}
