import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../project/domain/models/project.dart';

/// Pantalla 18 de Figma. Esqueleto: la llena el carril `management`.
class ApplicantsPage extends StatelessWidget {
  const ApplicantsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final Project? project =
        Get.arguments is Project ? Get.arguments as Project : null;

    return Scaffold(
      appBar: AppBar(title: const Text('Gestion de postulantes')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Pantalla 18 - Gestion de postulantes.\n'
                'Falta: la lista de postulantes con nombre, programa y '
                'semestre, los botones aceptar/rechazar y "Cerrar '
                'reclutamiento". Solo la abre quien es project.leaderId.\n'
                'Carril: management.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                project == null
                    ? 'Get.arguments llego vacio: se esperaba un Project.'
                    : 'Get.arguments: ${project.title} '
                        '(lider: ${project.leaderId}, '
                        'reclutamiento abierto: ${project.recruitmentOpen})',
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
