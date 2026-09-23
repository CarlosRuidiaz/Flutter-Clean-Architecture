import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../core/app_tokens.dart';
import '../../../ui/viewmodels/workspace_controller.dart';

/// Hoja modal para que el lider anada un hito nuevo.
///
/// No sale en el prototipo, pero hace falta: sin ella un proyecto nuevo nunca
/// tendria hitos y la barra de avance se quedaria en 0 para siempre.
class AddMilestoneSheet extends StatefulWidget {
  const AddMilestoneSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.card,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppTokens.radius * 3),
        ),
        side: BorderSide(color: AppColors.ink, width: AppTokens.borderWidth),
      ),
      builder: (_) => const AddMilestoneSheet(),
    );
  }

  @override
  State<AddMilestoneSheet> createState() => _AddMilestoneSheetState();
}

class _AddMilestoneSheetState extends State<AddMilestoneSheet> {
  final TextEditingController _tituloController = TextEditingController();
  DateTime _fecha = DateTime.now();

  @override
  void dispose() {
    _tituloController.dispose();
    super.dispose();
  }

  Future<void> _elegirFecha() async {
    final DateTime? elegida = await showDatePicker(
      context: context,
      initialDate: _fecha,
      firstDate: DateTime.now().subtract(const Duration(days: 1)),
      lastDate: DateTime.now().add(const Duration(days: 730)),
    );
    if (elegida != null) setState(() => _fecha = elegida);
  }

  @override
  Widget build(BuildContext context) {
    final WorkspaceController controller = Get.find();
    final TextTheme textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: EdgeInsets.fromLTRB(
        AppTokens.gapL,
        AppTokens.gapXl,
        AppTokens.gapL,
        AppTokens.gapL + MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Nuevo hito',
              style: textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppTokens.gapL),
            TextField(
              controller: _tituloController,
              decoration: const InputDecoration(labelText: 'Título'),
            ),
            const SizedBox(height: AppTokens.gapM),
            OutlinedButton(
              onPressed: _elegirFecha,
              child: Text(
                'Fecha: ${_fecha.day}/${_fecha.month}/${_fecha.year}',
              ),
            ),
            const SizedBox(height: AppTokens.gapXl),
            ElevatedButton(
              onPressed: () async {
                final String titulo = _tituloController.text.trim();
                if (titulo.isEmpty) return;
                await controller.addMilestone(titulo, _fecha);
                if (context.mounted) Navigator.of(context).pop();
              },
              child: const Text('Añadir hito'),
            ),
          ],
        ),
      ),
    );
  }
}
