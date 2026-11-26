import 'package:flutter/material.dart';

/// Typography scale. Money uses tabular figures (aligned columns) — a premium
/// fintech detail. Font family is left to the platform default (Inter can be
/// bundled later without touching this API).
@immutable
class AppTypography {
  final TextStyle display;
  final TextStyle headline;
  final TextStyle title;
  final TextStyle subtitle;
  final TextStyle body;
  final TextStyle bodySmall;
  final TextStyle label;
  final TextStyle caption;
  final TextStyle moneyHero;
  final TextStyle money;

  const AppTypography({
    required this.display,
    required this.headline,
    required this.title,
    required this.subtitle,
    required this.body,
    required this.bodySmall,
    required this.label,
    required this.caption,
    required this.moneyHero,
    required this.money,
  });

  static const List<FontFeature> _tabular = <FontFeature>[
    FontFeature.tabularFigures(),
  ];

  static const AppTypography base = AppTypography(
    display: TextStyle(fontSize: 36, fontWeight: FontWeight.w800, letterSpacing: -0.6),
    headline: TextStyle(fontSize: 28, fontWeight: FontWeight.w700, letterSpacing: -0.4),
    title: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, letterSpacing: -0.2),
    subtitle: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
    body: TextStyle(fontSize: 15, fontWeight: FontWeight.w400),
    bodySmall: TextStyle(fontSize: 13, fontWeight: FontWeight.w400),
    label: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, letterSpacing: 1.2),
    caption: TextStyle(fontSize: 11, fontWeight: FontWeight.w500),
    moneyHero: TextStyle(
      fontSize: 34,
      fontWeight: FontWeight.w800,
      letterSpacing: -0.5,
      fontFeatures: _tabular,
    ),
    money: TextStyle(
      fontSize: 15,
      fontWeight: FontWeight.w700,
      fontFeatures: _tabular,
    ),
  );
}
