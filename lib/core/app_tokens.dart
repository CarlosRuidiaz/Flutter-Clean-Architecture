import 'package:flutter/material.dart';

/// Identidad visual "Cartelera" — los mismos valores del prototipo de Figma
/// ("Semana 5 prototipo"). Este archivo es la UNICA fuente de verdad de color,
/// radio, borde y sombra. Ninguna pantalla escribe un Color(0x...) a mano.
abstract final class AppColors {
  /// Fondo de la app: papel.
  static const paper = Color(0xFFF5F0E6);

  /// Fondo de tarjetas y superficies elevadas.
  static const card = Color(0xFFFFFCF5);

  /// Texto principal y bordes.
  static const ink = Color(0xFF17150F);

  /// Texto secundario y bordes suaves.
  static const secondary = Color(0xFF6B665A);

  /// Acento principal (acciones destacadas, pestaña activa).
  static const persimmon = Color(0xFFE8552F);

  /// Acento de apoyo.
  static const petrol = Color(0xFF0F5C56);

  /// Acento de atencion.
  static const gold = Color(0xFFF2B705);
}

/// Colores de las seis etapas de un proyecto. Viven aqui, en la capa de UI,
/// porque `Color` es de Flutter y el dominio no puede importar Flutter.
abstract final class AppStageColors {
  static const idea = Color(0xFFF2B705);
  static const teamFormation = Color(0xFFE8552F);
  static const research = Color(0xFF2D5BFF);
  static const prototype = Color(0xFF0F5C56);
  static const testing = Color(0xFF6B4EE6);
  static const finished = Color(0xFF17150F);
}

/// Medidas del sistema: radio 4, borde 1.5 y sombra dura de 3px sin difuminado.
abstract final class AppTokens {
  static const double radius = 4;
  static const double borderWidth = 1.5;
  static const double shadowOffset = 3;

  static const BorderRadius borderRadius = BorderRadius.all(
    Radius.circular(radius),
  );

  static Border border({Color color = AppColors.ink}) =>
      Border.all(color: color, width: borderWidth);

  /// Sombra dura: desplazada, sin blur y sin spread. Es el rasgo que mas
  /// distingue a "Cartelera" de un Material por defecto.
  static List<BoxShadow> hardShadow({
    Color color = AppColors.ink,
    double offset = shadowOffset,
  }) => [
    BoxShadow(color: color, offset: Offset(offset, offset), blurRadius: 0),
  ];

  /// Espaciados usados en las pantallas.
  static const double gapXs = 4;
  static const double gapS = 8;
  static const double gapM = 12;
  static const double gapL = 16;
  static const double gapXl = 24;
}
