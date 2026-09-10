import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/app_routes.dart';

/// Pantalla 10 de Figma. Esqueleto: la llena el carril `idea`.
class CreateIdeaPage extends StatelessWidget {
  const CreateIdeaPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Crear idea')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Pantalla 10 - Crear idea.\n'
                'Falta: el formulario (titulo, problema, descripcion, etapa, '
                'programa, cupos, habilidades buscadas y tags) y la llamada a '
                'createProject.\n'
                'Carril: idea.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              // TODO(carril idea): quitar, esto es solo para poder navegar
              // durante el desarrollo.
              TextButton(
                onPressed: () => Get.toNamed(AppRoutes.ideaPublished),
                child: const Text('/idea-published'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
