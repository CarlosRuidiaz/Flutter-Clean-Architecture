import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../domain/models/project.dart';

/// Pantalla 11 de Figma. Esqueleto: la llena el carril `idea`.
class IdeaPublishedPage extends StatelessWidget {
  const IdeaPublishedPage({super.key});

  @override
  Widget build(BuildContext context) {
    // El proyecto recien creado, tal como lo devolvio createProject.
    final Project? project =
        Get.arguments is Project ? Get.arguments as Project : null;

    return Scaffold(
      appBar: AppBar(title: const Text('Idea publicada')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Pantalla 11 - Idea publicada.\n'
                'Falta: la confirmacion y los botones para ver la idea o '
                'volver al inicio.\n'
                'Carril: idea.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                project == null
                    ? 'Get.arguments llego vacio: se esperaba el Project creado.'
                    : 'Get.arguments: ${project.title}',
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
