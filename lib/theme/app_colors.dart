import 'package:flutter/material.dart';

/// Semantic color tokens. Immutable, const-friendly, theme-aware.
/// Palette mirrors the Noova "Look and Feel" reference: a deep-navy hero over a
/// light body, coral for CTAs/alerts, cyan accent, mint income. Raw Color(0x…)
/// values live ONLY in the theme package.
@immutable
class AppColors {
  final Color background;
  final Color surface;
  final Color surfaceVariant;
  final Color card;

  /// Interactive accent (cyan in both themes).
  final Color primary;
  final Color secondary;

  /// Deep-navy hero surface (dark header area) + its foreground.
  final Color hero;
  final Color onHero;

  final Color income;
  final Color expense;
  final Color warning;
  final Color success;
  final Color danger;
  final Color textPrimary;
  final Color textSecondary;
  final Color textOnPrimary;
  final Color divider;
  final Color border;
  final Color scrim;

  const AppColors({
    required this.background,
    required this.surface,
    required this.surfaceVariant,
    required this.card,
    required this.primary,
    required this.secondary,
    required this.hero,
    required this.onHero,
    required this.income,
    required this.expense,
    required this.warning,
    required this.success,
    required this.danger,
    required this.textPrimary,
    required this.textSecondary,
    required this.textOnPrimary,
    required this.divider,
    required this.border,
    required this.scrim,
  });

  /// Light theme — the reference look (light body + navy hero).
  static const AppColors light = AppColors(
    background: Color(0xFFF4F6F9),
    surface: Color(0xFFFFFFFF),
    surfaceVariant: Color(0xFFEEF1F5),
    card: Color(0xFFFFFFFF),
    primary: Color(0xFF12A8D8), // cyan link/accent
    secondary: Color(0xFF22A06B), // green
    hero: Color(0xFF0B2C45), // deep navy hero
    onHero: Color(0xFFFFFFFF),
    income: Color(0xFF22A06B),
    expense: Color(0xFFFA6F76), // coral CTA/alert
    warning: Color(0xFFF05A3C), // flame/overdue
    success: Color(0xFF22A06B),
    danger: Color(0xFFFA6F76),
    textPrimary: Color(0xFF0B2135),
    textSecondary: Color(0xFF6F7B86),
    textOnPrimary: Color(0xFFFFFFFF),
    divider: Color(0xFFE6EAEF),
    border: Color(0xFFDDE3E9),
    scrim: Color(0x660B2C45),
  );

  /// Dark theme (Noova navy — default brand look).
  static const AppColors dark = AppColors(
    background: Color(0xFF071C2C),
    surface: Color(0xFF0E2A40),
    surfaceVariant: Color(0xFF123A57),
    card: Color(0xFF0D2740),
    primary: Color(0xFF35C7EE), // cyan accent
    secondary: Color(0xFF3DDC97),
    hero: Color(0xFF0D2740),
    onHero: Color(0xFFEAF1F6),
    income: Color(0xFF3DDC97), // mint
    expense: Color(0xFFFF6B6B),
    warning: Color(0xFFF6C453),
    success: Color(0xFF3DDC97),
    danger: Color(0xFFFF6B6B),
    textPrimary: Color(0xFFEAF1F6),
    textSecondary: Color(0xFF93A7B8),
    textOnPrimary: Color(0xFF04121D),
    divider: Color(0xFF12354E),
    border: Color(0xFF1C4A6B),
    scrim: Color(0x99000000),
  );

  static AppColors lerp(AppColors a, AppColors b, double t) => AppColors(
        background: Color.lerp(a.background, b.background, t)!,
        surface: Color.lerp(a.surface, b.surface, t)!,
        surfaceVariant: Color.lerp(a.surfaceVariant, b.surfaceVariant, t)!,
        card: Color.lerp(a.card, b.card, t)!,
        primary: Color.lerp(a.primary, b.primary, t)!,
        secondary: Color.lerp(a.secondary, b.secondary, t)!,
        hero: Color.lerp(a.hero, b.hero, t)!,
        onHero: Color.lerp(a.onHero, b.onHero, t)!,
        income: Color.lerp(a.income, b.income, t)!,
        expense: Color.lerp(a.expense, b.expense, t)!,
        warning: Color.lerp(a.warning, b.warning, t)!,
        success: Color.lerp(a.success, b.success, t)!,
        danger: Color.lerp(a.danger, b.danger, t)!,
        textPrimary: Color.lerp(a.textPrimary, b.textPrimary, t)!,
        textSecondary: Color.lerp(a.textSecondary, b.textSecondary, t)!,
        textOnPrimary: Color.lerp(a.textOnPrimary, b.textOnPrimary, t)!,
        divider: Color.lerp(a.divider, b.divider, t)!,
        border: Color.lerp(a.border, b.border, t)!,
        scrim: Color.lerp(a.scrim, b.scrim, t)!,
      );
}
