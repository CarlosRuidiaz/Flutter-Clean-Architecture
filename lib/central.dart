import 'package:f_clean_template/features/project/ui/views/home_page.dart';
import 'package:flutter/material.dart';

// Comentados junto con el bloque de login de abajo. Se descomentan a la vez.
// import 'package:get/get.dart';
// import 'features/auth/ui/viewmodels/authentication_controller.dart';
// import 'features/auth/ui/views/login_page.dart';

class Central extends StatelessWidget {
  const Central({super.key});

  @override
  Widget build(BuildContext context) {
    // Esta semana no hay login: se entra directo al homepage.
    // El bloque de abajo se REACTIVA descomentandolo cuando entre Roble.
    return const HomePage();

    // AuthenticationController authenticationController = Get.find();
    // return Obx(
    //   () => authenticationController.isLogged
    //       ? const HomePage()
    //       : const LoginPage(),
    // );
  }
}
