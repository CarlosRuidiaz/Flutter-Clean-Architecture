import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/app_routes.dart';
import '../../domain/models/project.dart';

/// Pantalla 07 de Figma. Esqueleto: la llena el carril `application`.
class ProjectDetailPage extends StatelessWidget {
  const ProjectDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    final Project? project =
        Get.arguments is Project ? Get.arguments as Project : null;

    return Scaffold(
      appBar: AppBar(title: const Text('Detalle')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Pantalla 07 - Detalle del proyecto.\n'
                'Falta: problema, descripcion, equipo, habilidades buscadas y '
                'el boton "Postularme", que solo aparece si '
                'project.acceptsApplications es true.\n'
                'Carril: application.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                project == null
                    ? 'Get.arguments llego vacio: se esperaba un Project.'
                    : 'Get.arguments: ${project.title} '
                        '(acepta postulaciones: ${project.acceptsApplications})',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              // TODO(carril application): quitar, esto es solo para poder
              // navegar durante el desarrollo.
              TextButton(
                onPressed: () => Get.toNamed(AppRoutes.applicationStatus),
                child: const Text('/application-status'),
              ),
              // TODO(carril management): quitar, esto es solo para poder
              // navegar durante el desarrollo.
              TextButton(
                onPressed: () =>
                    Get.toNamed(AppRoutes.applicants, arguments: project),
                child: const Text('/applicants'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
