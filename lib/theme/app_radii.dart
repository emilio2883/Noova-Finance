import 'package:flutter/material.dart';

/// Corner radius scale. Use `context.app.radii.lg` or `.brLg`.
@immutable
class AppRadii {
  final double xs;
  final double sm;
  final double md;
  final double lg;
  final double xl;
  final double pill;

  const AppRadii({
    this.xs = 4,
    this.sm = 8,
    this.md = 12,
    this.lg = 16,
    this.xl = 24,
    this.pill = 999,
  });

  static const AppRadii standard = AppRadii();

  BorderRadius get brXs => BorderRadius.circular(xs);
  BorderRadius get brSm => BorderRadius.circular(sm);
  BorderRadius get brMd => BorderRadius.circular(md);
  BorderRadius get brLg => BorderRadius.circular(lg);
  BorderRadius get brXl => BorderRadius.circular(xl);
  BorderRadius get brPill => BorderRadius.circular(pill);
}
