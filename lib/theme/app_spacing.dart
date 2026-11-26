import 'package:flutter/foundation.dart';

/// Spacing scale (4pt base grid). Use `context.app.spacing.md`.
@immutable
class AppSpacing {
  final double xxs;
  final double xs;
  final double sm;
  final double md;
  final double lg;
  final double xl;
  final double xxl;
  final double xxxl;

  const AppSpacing({
    this.xxs = 2,
    this.xs = 4,
    this.sm = 8,
    this.md = 16,
    this.lg = 24,
    this.xl = 32,
    this.xxl = 48,
    this.xxxl = 64,
  });

  static const AppSpacing standard = AppSpacing();
}
