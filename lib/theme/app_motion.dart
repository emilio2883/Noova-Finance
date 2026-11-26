import 'package:flutter/animation.dart';

/// Motion tokens following Material 3 motion guidance.
/// Use `AppMotion.short` (duration) and `AppMotion.standard` (curve).
/// These are constants, not theme-dependent, so they are plain statics.
class AppMotion {
  AppMotion._();

  // Durations
  static const Duration short = Duration(milliseconds: 150);
  static const Duration medium = Duration(milliseconds: 300);
  static const Duration long = Duration(milliseconds: 500);
  static const Duration extraLong = Duration(milliseconds: 700);

  // Curves (Material 3)
  static const Curve standard = Cubic(0.2, 0.0, 0.0, 1.0);
  static const Curve standardDecelerate = Cubic(0.0, 0.0, 0.0, 1.0);
  static const Curve standardAccelerate = Cubic(0.3, 0.0, 1.0, 1.0);
  static const Curve emphasized = Cubic(0.05, 0.7, 0.1, 1.0);
  static const Curve emphasizedDecelerate = Cubic(0.05, 0.7, 0.1, 1.0);
  static const Curve emphasizedAccelerate = Cubic(0.3, 0.0, 0.8, 0.15);
}
