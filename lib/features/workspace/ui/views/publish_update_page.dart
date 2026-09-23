import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/app_tokens.dart';
import '../../../../core/widgets/pill.dart';
import '../../../project/domain/models/project.dart';
import '../../domain/models/milestone.dart';
import '../viewmodels/workspace_controller.dart';

/// Publicar un avance: titulo, descripcion, un enlace de video opcional y,
/// tambien opcional, el hito que este avance cumple.
class PublishUpdatePage extends StatefulWidget {
  const PublishUpdatePage({super.key});

  @override
  State<PublishUpdatePage> createState() => _PublishUpdatePageState();
}

class _PublishUpdatePageState extends State<PublishUpdatePage> {
  final WorkspaceController _controller = Get.find();
  final TextEditingController _tituloController = TextEditingController();
  final TextEditingController _descripcionController = TextEditingController();
  final TextEditingController _videoController = TextEditingController();
  Milestone? _hitoElegido;

  @override
  void dispose() {
    _tituloController.dispose();
    _descripcionController.dispose();
    _videoController.dispose();
    super.dispose();
  }

  Future<void> _publicar() async {
    final String titulo = _tituloController.text.trim();
    final String descripcion = _descripcionController.text.trim();
    if (titulo.isEmpty || descripcion.isEmpty) return;

    final String video = _videoController.text.trim();
    await _controller.publishUpdate(
      title: titulo,
      description: descripcion,
      videoUrl: video.isEmpty ? null : video,
      milestoneId: _hitoElegido?.id,
    );

    // Al publicar vuelve a la pestania de avances.
    _controller.tabIndex.value = 1;
    Get.back();
  }

  @override
  Widget build(BuildContext context) {
    final Project? project =
        Get.arguments is Project ? Get.arguments as Project : null;
    final TextTheme textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Publicar avance')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppTokens.gapL),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (project != null) ...[
              Text(project.title, style: textTheme.bodySmall),
              const SizedBox(height: AppTokens.gapL),
            ],
            TextField(
              controller: _tituloController,
              decoration: const InputDecoration(labelText: 'Título'),
            ),
            const SizedBox(height: AppTokens.gapM),
            TextField(
              controller: _descripcionController,
              maxLines: 4,
              decoration: const InputDecoration(labelText: 'Descripción'),
            ),
            const SizedBox(height: AppTokens.gapM),
            TextField(
              controller: _videoController,
              decoration: const InputDecoration(
                labelText: 'Enlace de video (opcional)',
              ),
            ),
            const SizedBox(height: AppTokens.gapXl),
            Text(
              '¿Este avance cumple un hito?',
              style: textTheme.titleMedium,
            ),
            const SizedBox(height: AppTokens.gapS),
            Obx(() {
              final pendientes = _controller.pendingMilestones;
              if (pendientes.isEmpty) {
                return Text(
                  'No hay hitos pendientes por cumplir.',
                  style: textTheme.bodySmall,
                );
              }

              return Wrap(
                spacing: AppTokens.gapS,
                runSpacing: AppTokens.gapS,
                children: [
                  InkWell(
                    onTap: () => setState(() => _hitoElegido = null),
                    borderRadius: BorderRadius.circular(999),
                    child: Pill(
                      label: 'Ninguno',
                      background: _hitoElegido == null
                          ? AppColors.persimmon
                          : AppColors.card,
                    ),
                  ),
                  for (final hito in pendientes)
                    InkWell(
                      onTap: () => setState(() => _hitoElegido = hito),
                      borderRadius: BorderRadius.circular(999),
                      child: Pill(
                        label:
                            '${hito.title} · ${hito.dueDate.day}/'
                            '${hito.dueDate.month}/${hito.dueDate.year}',
                        background: _hitoElegido?.id == hito.id
                            ? AppColors.persimmon
                            : AppColors.card,
                      ),
                    ),
                ],
              );
            }),
            const SizedBox(height: AppTokens.gapXl),
            ElevatedButton(
              onPressed: _publicar,
              child: const Text('Publicar avance'),
            ),
          ],
        ),
      ),
    );
  }
}
