import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_radii.dart';
import 'app_spacing.dart';
import 'app_typography.dart';

/// Single ThemeExtension bundling all design tokens.
/// Access via `context.app` (see [AppThemeX]).
@immutable
class AppTheme extends ThemeExtension<AppTheme> {
  final AppColors colors;
  final AppSpacing spacing;
  final AppRadii radii;
  final AppTypography typography;
  final List<BoxShadow> cardShadow;

  const AppTheme({
    required this.colors,
    required this.spacing,
    required this.radii,
    required this.typography,
    required this.cardShadow,
  });

  /// Dark token set.
  static AppTheme dark = AppTheme(
    colors: AppColors.dark,
    spacing: AppSpacing.standard,
    radii: AppRadii.standard,
    typography: AppTypography.base,
    cardShadow: const [
      BoxShadow(color: Color(0x14000000), blurRadius: 8, offset: Offset(0, 2)),
    ],
  );

  /// Light token set.
  static AppTheme light = AppTheme(
    colors: AppColors.light,
    spacing: AppSpacing.standard,
    radii: AppRadii.standard,
    typography: AppTypography.base,
    cardShadow: const [
      BoxShadow(color: Color(0x14000000), blurRadius: 8, offset: Offset(0, 2)),
    ],
  );

  @override
  AppTheme copyWith({
    AppColors? colors,
    AppSpacing? spacing,
    AppRadii? radii,
    AppTypography? typography,
    List<BoxShadow>? cardShadow,
  }) {
    return AppTheme(
      colors: colors ?? this.colors,
      spacing: spacing ?? this.spacing,
      radii: radii ?? this.radii,
      typography: typography ?? this.typography,
      cardShadow: cardShadow ?? this.cardShadow,
    );
  }

  @override
  AppTheme lerp(ThemeExtension<AppTheme>? other, double t) {
    if (other is! AppTheme) return this;
    return AppTheme(
      colors: AppColors.lerp(colors, other.colors, t),
      spacing: t < 0.5 ? spacing : other.spacing,
      radii: t < 0.5 ? radii : other.radii,
      typography: t < 0.5 ? typography : other.typography,
      cardShadow: t < 0.5 ? cardShadow : other.cardShadow,
    );
  }
}

/// `context.app` accessor for design tokens.
extension AppThemeX on BuildContext {
  AppTheme get app {
    final ext = Theme.of(this).extension<AppTheme>();
    if (ext != null) return ext;
    return Theme.of(this).brightness == Brightness.dark
        ? AppTheme.dark
        : AppTheme.light;
  }
}
