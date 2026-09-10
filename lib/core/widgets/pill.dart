import 'package:flutter/material.dart';

import '../app_tokens.dart';

/// Chip en pildora del sistema "Cartelera".
///
/// Es generico a proposito: no sabe nada de proyectos ni de etapas. Quien lo
/// usa le pasa el texto y el color de fondo. Asi `lib/core/` no depende de
/// ningun feature.
class Pill extends StatelessWidget {
  const Pill({
    super.key,
    required this.label,
    this.background = AppColors.card,
    this.foreground,
    this.outlined = true,
  });

  final String label;
  final Color background;

  /// Si no se pasa, se elige blanco o tinta segun el brillo del fondo.
  final Color? foreground;
  final bool outlined;

  @override
  Widget build(BuildContext context) {
    final Color text =
        foreground ??
        (ThemeData.estimateBrightnessForColor(background) == Brightness.dark
            ? Colors.white
            : AppColors.ink);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(999),
        border: outlined ? AppTokens.border() : null,
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: text,
          fontSize: 11.5,
          fontWeight: FontWeight.w600,
          height: 1.2,
        ),
      ),
    );
  }
}
