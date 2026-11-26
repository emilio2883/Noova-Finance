import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Noova themes — brand "navy" identity (deep navy field + white mark look).
/// Dark is the default; a light variant is also provided. The palette mirrors
/// the Noova logo: deep navy background, soft navy surfaces, white text,
/// a cyan accent, and functional income/expense colors.
class NoovaTheme {
  // Semantic colors (theme-independent)
  static const Color income = Color(0xFF3DDC97); // mint green
  static const Color expense = Color(0xFFFF6B6B); // coral
  static const Color accent = Color(0xFF35C7EE); // brand cyan
  static const Color warning = Color(0xFFF6C453); // amber

  // Dark palette (Noova navy)
  static const Color background = Color(0xFF071C2C);
  static const Color surface = Color(0xFF0E2A40);
  static const Color surfaceVariant = Color(0xFF123A57);
  static const Color card = Color(0xFF0D2740);
  static const Color textPrimary = Color(0xFFEAF1F6);
  static const Color textSecondary = Color(0xFF93A7B8);

  // Light palette (navy-on-light)
  static const Color _lightBg = Color(0xFFF4F5F7);
  static const Color _lightSurface = Color(0xFFFFFFFF);
  static const Color _lightText = Color(0xFF0B2135);
  static const Color _lightTextSecondary = Color(0xFF5C6B7A);
  static const Color _brandNavy = Color(0xFF0B2F49);

  static ThemeData get darkTheme {
    final base = ThemeData.dark(useMaterial3: true);
    return base.copyWith(
      extensions: [AppTheme.dark],
      scaffoldBackgroundColor: background,
      colorScheme: const ColorScheme.dark(
        primary: accent,
        secondary: income,
        error: expense,
        surface: surface,
        onPrimary: Color(0xFF04121D),
        onSecondary: Color(0xFF04121D),
        onSurface: textPrimary,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: surface,
        foregroundColor: textPrimary,
        elevation: 0,
        centerTitle: true,
      ),
      cardTheme: const CardThemeData(
        color: card,
        elevation: 2,
        shadowColor: Colors.black54,
        margin: EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      ),
      dialogTheme: const DialogThemeData(backgroundColor: surface),
      bottomSheetTheme: const BottomSheetThemeData(backgroundColor: surface),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: accent,
        foregroundColor: Color(0xFF04121D),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceVariant,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: accent, width: 2),
        ),
        labelStyle: const TextStyle(color: textSecondary),
      ),
      textTheme: base.textTheme.apply(bodyColor: textPrimary, displayColor: textPrimary),
      navigationBarTheme: const NavigationBarThemeData(backgroundColor: surface),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: surfaceVariant,
        contentTextStyle: const TextStyle(color: textPrimary),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  static ThemeData get lightTheme {
    final base = ThemeData.light(useMaterial3: true);
    return base.copyWith(
      extensions: [AppTheme.light],
      scaffoldBackgroundColor: _lightBg,
      colorScheme: const ColorScheme.light(
        primary: _brandNavy,
        secondary: Color(0xFF00A152),
        error: Color(0xFFD32F2F),
        surface: _lightSurface,
        onSurface: _lightText,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: _lightSurface,
        foregroundColor: _lightText,
        elevation: 0,
        centerTitle: true,
      ),
      cardTheme: CardThemeData(
        color: _lightSurface,
        elevation: 1,
        shadowColor: Colors.black.withValues(alpha: 0.08),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      ),
      dialogTheme: const DialogThemeData(backgroundColor: _lightSurface),
      bottomSheetTheme: const BottomSheetThemeData(backgroundColor: _lightSurface),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: _brandNavy,
        foregroundColor: Colors.white,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFFEDEEF2),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _brandNavy, width: 2),
        ),
        labelStyle: const TextStyle(color: _lightTextSecondary),
      ),
      textTheme: base.textTheme.apply(bodyColor: _lightText, displayColor: _lightText),
      navigationBarTheme: const NavigationBarThemeData(backgroundColor: _lightSurface),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: const Color(0xFF323232),
        contentTextStyle: const TextStyle(color: Colors.white),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }
}
