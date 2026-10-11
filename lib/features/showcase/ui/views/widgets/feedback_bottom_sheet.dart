import 'package:flutter/material.dart';

import 'package:f_clean_template/core/app_tokens.dart';
import 'package:f_clean_template/features/showcase/domain/models/project_feedback.dart';

class FeedbackBottomSheet extends StatefulWidget {
  const FeedbackBottomSheet({
    super.key,
    this.existingFeedback,
    required this.onSubmit,
  });

  final ProjectFeedback? existingFeedback;
  final Future<void> Function({
    required int usability,
    required int innovation,
    required int visualDesign,
    required int feasibility,
    String? comment,
  }) onSubmit;

  @override
  State<FeedbackBottomSheet> createState() => _FeedbackBottomSheetState();
}

class _FeedbackBottomSheetState extends State<FeedbackBottomSheet> {
  late int _usability;
  late int _innovation;
  late int _visualDesign;
  late int _feasibility;
  late final TextEditingController _commentController;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final prev = widget.existingFeedback;
    _usability = prev?.usability ?? 5;
    _innovation = prev?.innovation ?? 5;
    _visualDesign = prev?.visualDesign ?? 5;
    _feasibility = prev?.feasibility ?? 5;
    _commentController = TextEditingController(text: prev?.comment ?? '');
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Widget _scoreSelector({
    required String label,
    required int current,
    required ValueChanged<int> onSelected,
  }) {
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppTokens.gapM),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.ink,
                ),
              ),
              Text(
                '$current de 5',
                style: textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.persimmon,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppTokens.gapS),
          Row(
            children: List.generate(5, (index) {
              final score = index + 1;
              final isSelected = score <= current;

              return Expanded(
                child: GestureDetector(
                  onTap: () => onSelected(score),
                  child: Container(
                    height: 34,
                    margin: EdgeInsets.only(
                      right: index == 4 ? 0 : AppTokens.gapXs,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.persimmon : AppColors.card,
                      border: AppTokens.border(),
                      borderRadius: AppTokens.borderRadius,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      '$score',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: isSelected ? Colors.white : AppColors.ink,
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Future<void> _handleSave() async {
    setState(() => _isSaving = true);
    try {
      await widget.onSubmit(
        usability: _usability,
        innovation: _innovation,
        visualDesign: _visualDesign,
        feasibility: _feasibility,
        comment: _commentController.text.trim().isNotEmpty
            ? _commentController.text.trim()
            : null,
      );
      if (mounted) {
        Navigator.of(context).pop();
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final isEditing = widget.existingFeedback != null;

    return Padding(
      padding: EdgeInsets.only(
        left: AppTokens.gapL,
        right: AppTokens.gapL,
        top: AppTokens.gapL,
        bottom: MediaQuery.of(context).viewInsets.bottom + AppTokens.gapL,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  isEditing ? 'Editar retroalimentación' : 'Dar retroalimentación',
                  style: textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: AppTokens.gapS),
            Text(
              'Califica el prototipo en cada dimensión (1 a 5) y comparte tus sugerencias.',
              style: textTheme.bodySmall?.copyWith(
                color: AppColors.secondary,
              ),
            ),
            const SizedBox(height: AppTokens.gapL),
            _scoreSelector(
              label: 'Usabilidad',
              current: _usability,
              onSelected: (val) => setState(() => _usability = val),
            ),
            _scoreSelector(
              label: 'Innovación',
              current: _innovation,
              onSelected: (val) => setState(() => _innovation = val),
            ),
            _scoreSelector(
              label: 'Diseño visual',
              current: _visualDesign,
              onSelected: (val) => setState(() => _visualDesign = val),
            ),
            _scoreSelector(
              label: 'Factibilidad técnica',
              current: _feasibility,
              onSelected: (val) => setState(() => _feasibility = val),
            ),
            const SizedBox(height: AppTokens.gapM),
            Text(
              'Comentario u observaciones (opcional)',
              style: textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: AppTokens.gapS),
            TextField(
              controller: _commentController,
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: '¿Qué mejorarías de este prototipo?',
              ),
            ),
            const SizedBox(height: AppTokens.gapXl),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isSaving ? null : _handleSave,
                child: _isSaving
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text('Guardar'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
