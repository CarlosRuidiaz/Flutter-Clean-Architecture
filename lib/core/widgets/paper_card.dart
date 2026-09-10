import 'package:flutter/material.dart';

import '../app_tokens.dart';

/// Tarjeta de papel del sistema "Cartelera": fondo crema, borde de 1.5 y
/// sombra dura de 3px sin difuminado.
///
/// Compartida por todos los features. Si una pantalla necesita una tarjeta,
/// usa esta en vez de `Card`, para que el borde y la sombra sean identicos.
class PaperCard extends StatelessWidget {
  const PaperCard({
    super.key,
    required this.child,
    this.onTap,
    this.padding = const EdgeInsets.all(AppTokens.gapL),
    this.margin = const EdgeInsets.only(
      left: AppTokens.gapL,
      right: AppTokens.gapL + AppTokens.shadowOffset,
      bottom: AppTokens.gapM + AppTokens.shadowOffset,
    ),
    this.borderColor = AppColors.ink,
    this.background = AppColors.card,
  });

  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry margin;
  final Color borderColor;
  final Color background;

  @override
  Widget build(BuildContext context) {
    final Widget body = Container(
      padding: padding,
      decoration: BoxDecoration(
        color: background,
        borderRadius: AppTokens.borderRadius,
        border: AppTokens.border(color: borderColor),
        boxShadow: AppTokens.hardShadow(color: borderColor),
      ),
      child: child,
    );

    return Padding(
      padding: margin,
      child: onTap == null
          ? body
          : InkWell(
              onTap: onTap,
              borderRadius: AppTokens.borderRadius,
              child: body,
            ),
    );
  }
}
