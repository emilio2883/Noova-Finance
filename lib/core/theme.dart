import 'package:flutter/material.dart';

/// Noova Finance themes: dark (default) + light.
/// Semantic accent colors (income green, expense coral, teal accent) work on
/// both. Surface/background colors come from ThemeData so widgets adapt.
class NoovaTheme {
  // Semantic colors (theme-independent)
  static const Color income = Color(0xFF00C853); // green
  static const Color expense = Color(0xFFFF5252); // coral red
  static const Color accent = Color(0xFF00BCD4); // teal
  static const Color warning = Color(0xFFFFB74D);

  // Dark palette
  static const Color background = Color(0xFF121212);
  static const Color surface = Color(0xFF1E1E2E);
  static const Color surfaceVariant = Color(0xFF16213E);
  static const Color card = Color(0xFF1A1A2E);
  static const Color textPrimary = Color(0xFFE0E0E0);
  static const Color textSecondary = Color(0xFF9E9E9E);

  // Light palette
  static const Color _lightBg = Color(0xFFF4F5F7);
  static const Color _lightSurface = Color(0xFFFFFFFF);
  static const Color _lightText = Color(0xFF1A1A1A);
  static const Color _lightTextSecondary = Color(0xFF6B6B76);

  static ThemeData get darkTheme {
    final base = ThemeData.dark(useMaterial3: true);
    return base.copyWith(
      scaffoldBackgroundColor: background,
      colorScheme: const ColorScheme.dark(
        primary: accent,
        secondary: income,
        error: expense,
        surface: surface,
        onPrimary: Colors.black,
        onSecondary: Colors.black,
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
        margin: EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      ),
      dialogTheme: const DialogThemeData(backgroundColor: surface),
      bottomSheetTheme: const BottomSheetThemeData(backgroundColor: surface),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: accent,
        foregroundColor: Colors.black,
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
      scaffoldBackgroundColor: _lightBg,
      colorScheme: const ColorScheme.light(
        primary: Color(0xFF00838F),
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
        backgroundColor: Color(0xFF00838F),
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
          borderSide: const BorderSide(color: Color(0xFF00838F), width: 2),
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
