import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_tokens.dart';

/// Tema "Cartelera" de Innovation Hub.
///
/// Sustituye al tema de flex_color_scheme del template. Todo lo visual sale de
/// [AppColors] y [AppTokens]; las pantallas no deben repetir colores ni radios.
///
/// Tipografias: Fraunces para titulares, Archivo para interfaz. Se cargan con
/// `google_fonts` (descarga y cachea en el primer arranque). Si mas adelante se
/// quieren empaquetar como assets para funcionar 100% sin red, solo cambian las
/// dos funciones [_display] y [_body] de este archivo.
abstract final class AppTheme {
  static TextStyle _display(TextStyle base) => GoogleFonts.fraunces(
    textStyle: base,
  );

  static TextStyle _body(TextStyle base) => GoogleFonts.archivo(
    textStyle: base,
  );

  static ThemeData get light {
    final base = ThemeData.light(useMaterial3: true);

    final textTheme = base.textTheme.copyWith(
      displayLarge: _display(
        const TextStyle(fontSize: 32, fontWeight: FontWeight.w700, color: AppColors.ink),
      ),
      headlineMedium: _display(
        const TextStyle(fontSize: 26, fontWeight: FontWeight.w700, color: AppColors.ink),
      ),
      titleLarge: _display(
        const TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.ink),
      ),
      titleMedium: _display(
        const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.ink),
      ),
      bodyLarge: _body(
        const TextStyle(fontSize: 15, color: AppColors.ink),
      ),
      bodyMedium: _body(
        const TextStyle(fontSize: 13.5, color: AppColors.ink),
      ),
      bodySmall: _body(
        const TextStyle(fontSize: 12, color: AppColors.secondary),
      ),
      labelLarge: _body(
        const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.ink),
      ),
    );

    return base.copyWith(
      scaffoldBackgroundColor: AppColors.paper,
      canvasColor: AppColors.paper,
      textTheme: textTheme,
      colorScheme: base.colorScheme.copyWith(
        primary: AppColors.persimmon,
        onPrimary: Colors.white,
        secondary: AppColors.petrol,
        onSecondary: Colors.white,
        surface: AppColors.card,
        onSurface: AppColors.ink,
        error: AppColors.persimmon,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.paper,
        foregroundColor: AppColors.ink,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: _display(
          const TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: AppColors.ink),
        ),
      ),
      tabBarTheme: TabBarThemeData(
        labelColor: AppColors.ink,
        unselectedLabelColor: AppColors.secondary,
        indicatorColor: AppColors.persimmon,
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: AppColors.ink,
        labelStyle: _body(
          const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        ),
        unselectedLabelStyle: _body(const TextStyle(fontSize: 14)),
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.ink,
        thickness: AppTokens.borderWidth,
        space: AppTokens.borderWidth,
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: AppColors.card,
        selectedItemColor: AppColors.persimmon,
        unselectedItemColor: AppColors.secondary,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
        selectedLabelStyle: _body(
          const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
        ),
        unselectedLabelStyle: _body(const TextStyle(fontSize: 11)),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.persimmon,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          textStyle: _body(
            const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
          ),
          shape: const RoundedRectangleBorder(
            borderRadius: AppTokens.borderRadius,
            side: BorderSide(color: AppColors.ink, width: AppTokens.borderWidth),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          backgroundColor: AppColors.card,
          foregroundColor: AppColors.ink,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          textStyle: _body(
            const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
          ),
          side: const BorderSide(color: AppColors.ink, width: AppTokens.borderWidth),
          shape: const RoundedRectangleBorder(
            borderRadius: AppTokens.borderRadius,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.persimmon,
          textStyle: _body(
            const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.card,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        hintStyle: _body(const TextStyle(fontSize: 14, color: AppColors.secondary)),
        labelStyle: _body(const TextStyle(fontSize: 14, color: AppColors.secondary)),
        border: const OutlineInputBorder(
          borderRadius: AppTokens.borderRadius,
          borderSide: BorderSide(color: AppColors.ink, width: AppTokens.borderWidth),
        ),
        enabledBorder: const OutlineInputBorder(
          borderRadius: AppTokens.borderRadius,
          borderSide: BorderSide(color: AppColors.ink, width: AppTokens.borderWidth),
        ),
        focusedBorder: const OutlineInputBorder(
          borderRadius: AppTokens.borderRadius,
          borderSide: BorderSide(color: AppColors.persimmon, width: 2),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.ink,
        contentTextStyle: _body(const TextStyle(fontSize: 14, color: Colors.white)),
        behavior: SnackBarBehavior.floating,
        shape: const RoundedRectangleBorder(borderRadius: AppTokens.borderRadius),
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.persimmon,
      ),
    );
  }

  /// "Cartelera" es un sistema de papel claro: no hay variante oscura. Se
  /// devuelve el mismo tema para que la app se vea igual con el sistema en
  /// modo oscuro, en vez de caer al Material morado por defecto.
  static ThemeData get dark => light;
}
