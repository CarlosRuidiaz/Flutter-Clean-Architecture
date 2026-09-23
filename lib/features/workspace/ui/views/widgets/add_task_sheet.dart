import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../core/app_tokens.dart';
import '../../../../../core/widgets/pill.dart';
import '../../../ui/viewmodels/team_member.dart';
import '../../../ui/viewmodels/workspace_controller.dart';

/// Hoja modal para anadir una tarea. El responsable se elige de la lista de
/// miembros, con las mismas pildoras seleccionables que usan los filtros de
/// la cartelera.
class AddTaskSheet extends StatefulWidget {
  const AddTaskSheet({super.key});

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
      builder: (_) => const AddTaskSheet(),
    );
  }

  @override
  State<AddTaskSheet> createState() => _AddTaskSheetState();
}

class _AddTaskSheetState extends State<AddTaskSheet> {
  final TextEditingController _tituloController = TextEditingController();
  TeamMember? _responsable;

  @override
  void dispose() {
    _tituloController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final WorkspaceController controller = Get.find();
    final TextTheme textTheme = Theme.of(context).textTheme;
    _responsable ??=
        controller.members.isNotEmpty ? controller.members.first : null;

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
              'Nueva tarea',
              style: textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppTokens.gapL),
            TextField(
              controller: _tituloController,
              decoration: const InputDecoration(labelText: 'Título'),
            ),
            const SizedBox(height: AppTokens.gapM),
            Text('Responsable', style: textTheme.bodyMedium),
            const SizedBox(height: AppTokens.gapS),
            Wrap(
              spacing: AppTokens.gapS,
              runSpacing: AppTokens.gapS,
              children: [
                for (final member in controller.members)
                  InkWell(
                    onTap: () => setState(() => _responsable = member),
                    borderRadius: BorderRadius.circular(999),
                    child: Pill(
                      label: member.name,
                      background: _responsable?.id == member.id
                          ? AppColors.persimmon
                          : AppColors.card,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: AppTokens.gapXl),
            ElevatedButton(
              onPressed: () async {
                final String titulo = _tituloController.text.trim();
                final TeamMember? responsable = _responsable;
                if (titulo.isEmpty || responsable == null) return;
                await controller.addTask(titulo, responsable.name);
                if (context.mounted) Navigator.of(context).pop();
              },
              child: const Text('Añadir tarea'),
            ),
          ],
        ),
      ),
    );
  }
}
