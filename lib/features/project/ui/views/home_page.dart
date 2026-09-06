import 'package:flutter/material.dart';

/// ESQUELETO. A partir de aqui es de la PAREJA PROJECT (persona 2).
///
/// Existe desde el primer dia para que los cuatro puedan correr la app
/// mientras trabajan. Todavia no pide datos a nadie: no llama a Get.find(),
/// porque ningun controlador esta registrado aun.
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Innovation Hub')),
      body: Column(
        children: const [
          // AQUI VA el widget de la pareja PROFILE:
          //     const ProfileSkillsLine(),
          // Se pone cuando esa pareja lo haya mergeado. Mientras tanto:
          SizedBox(height: 8),

          Expanded(
            child: Center(child: Text('Aqui va la lista de proyectos')),
          ),
        ],
      ),
    );
  }
}
