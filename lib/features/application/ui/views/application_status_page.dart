import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../domain/models/application.dart';

/// Pantallas 14 y 19 de Figma: son la misma pantalla. Solo cambian el icono, el
/// titulo, el texto y los botones del pie segun `Application.status`. Una sola
/// clase, dirigida por el estado. Esqueleto: la llena el carril `application`.
class ApplicationStatusPage extends StatelessWidget {
  const ApplicationStatusPage({super.key});

  @override
  Widget build(BuildContext context) {
    final Application? application =
        Get.arguments is Application ? Get.arguments as Application : null;

    return Scaffold(
      appBar: AppBar(title: const Text('Mi postulacion')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Pantallas 14 y 19 - Estado de la postulacion.\n'
                'Falta: icono, titulo, texto y botones del pie segun '
                'application.status; "Cancelar postulacion" solo mientras '
                'canWithdraw. El titulo y la etapa del proyecto se piden a '
                'IProjectRepository con application.projectId.\n'
                'Carril: application.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                application == null
                    ? 'Get.arguments llego vacio: se esperaba una Application.'
                    : 'Get.arguments: postulacion ${application.id} '
                        'al proyecto ${application.projectId}, '
                        'estado ${application.status.name}',
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
