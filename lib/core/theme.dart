import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_motion.dart';
import '../theme/app_radii.dart';
import '../theme/app_theme.dart';

/// Noova theme — built FROM design tokens (single source of truth = AppColors).
/// The static color getters are backward-compatible aliases over AppColors so
/// existing widgets keep working while screens are migrated incrementally.
/// Light is the default brand look (light body + navy hero); dark mirrors it.
class NoovaTheme {
  // Backward-compat aliases (dark palette) — single source: AppColors.
  static const Color income = kDarkMint;
  static const Color expense = kDarkExpense;
  static const Color accent = kDarkPrimary;
  static const Color warning = kDarkWarning;
  static const Color background = kDarkBackground;
  static const Color surface = kDarkSurface;
  static const Color surfaceVariant = kDarkSurfaceVariant;
  static const Color card = kDarkCard;
  static const Color textPrimary = kDarkTextPrimary;
  static const Color textSecondary = kDarkTextSecondary;

  static ThemeData _build(AppColors c, Brightness b) {
    final base = b == Brightness.dark
        ? ThemeData.dark(useMaterial3: true)
        : ThemeData.light(useMaterial3: true);
    final radii = AppRadii.standard;
    final scheme = ColorScheme.fromSeed(seedColor: c.primary, brightness: b)
        .copyWith(
      primary: c.primary,
      secondary: c.secondary,
      error: c.expense,
      surface: c.surface,
      onSurface: c.textPrimary,
      onPrimary: c.textOnPrimary,
    );

    return base.copyWith(
      scaffoldBackgroundColor: c.background,
      colorScheme: scheme,
      appBarTheme: AppBarTheme(
        backgroundColor: c.hero,
        foregroundColor: c.onHero,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: c.onHero),
        actionsIconTheme: IconThemeData(color: c.onHero),
      ),
      cardTheme: CardThemeData(
        color: c.card,
        elevation: b == Brightness.dark ? 2 : 1,
        shadowColor: Colors.black26,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        shape: RoundedRectangleBorder(borderRadius: radii.brLg),
      ),
      dialogTheme: DialogThemeData(backgroundColor: c.surface),
      bottomSheetTheme: BottomSheetThemeData(backgroundColor: c.surface),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: c.primary,
        foregroundColor: c.textOnPrimary,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: c.surfaceVariant,
        border: OutlineInputBorder(
          borderRadius: radii.brMd,
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: radii.brMd,
          borderSide: BorderSide(color: c.primary, width: 2),
        ),
        labelStyle: TextStyle(color: c.textSecondary),
      ),
      textTheme: base.textTheme.apply(
        bodyColor: c.textPrimary,
        displayColor: c.textPrimary,
      ),
      navigationBarTheme: NavigationBarThemeData(backgroundColor: c.surface),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: c.surfaceVariant,
        contentTextStyle: TextStyle(color: c.textPrimary),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: radii.brSm),
      ),
      pageTransitionsTheme: const PageTransitionsTheme(builders: {
        TargetPlatform.android: _FadeSlidePageTransitionsBuilder(),
        TargetPlatform.iOS: _FadeSlidePageTransitionsBuilder(),
        TargetPlatform.macOS: _FadeSlidePageTransitionsBuilder(),
        TargetPlatform.windows: _FadeSlidePageTransitionsBuilder(),
        TargetPlatform.linux: _FadeSlidePageTransitionsBuilder(),
      }),
      extensions: [b == Brightness.dark ? AppTheme.dark : AppTheme.light],
    );
  }

  static ThemeData get darkTheme => _build(AppColors.dark, Brightness.dark);
  static ThemeData get lightTheme => _build(AppColors.light, Brightness.light);
}

/// Subtle fade + tiny vertical slide page transition driven by AppMotion tokens.
class _FadeSlidePageTransitionsBuilder extends PageTransitionsBuilder {
  const _FadeSlidePageTransitionsBuilder();

  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    final curved = CurvedAnimation(
      parent: animation,
      curve: AppMotion.standardDecelerate,
      reverseCurve: AppMotion.standardAccelerate,
    );
    final slide = Tween<Offset>(
      begin: const Offset(0, 0.02),
      end: Offset.zero,
    ).animate(curved);
    return FadeTransition(
      opacity: curved,
      child: SlideTransition(position: slide, child: child),
    );
  }
}
