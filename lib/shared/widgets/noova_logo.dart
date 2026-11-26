import 'package:flutter/material.dart';

import 'package:noova_finance/theme/app_theme.dart';

/// The Noova brand mark used as the centre nav button. Rendered as a glyph in
/// the logo colours (navy background, white letter).
class NoovaMark extends StatelessWidget {
  final double size;
  final Color background;
  final Color foreground;
  final bool circle;
  final String letter;

  const NoovaMark({
    super.key,
    this.size = 36,
    required this.background,
    required this.foreground,
    this.circle = false,
    this.letter = 'N',
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: background,
        borderRadius: circle
            ? BorderRadius.all(Radius.circular(size / 2))
            : BorderRadius.all(Radius.circular(size * 0.28)),
        boxShadow: const [
          BoxShadow(color: Colors.black26, blurRadius: 8, offset: Offset(0, 3)),
        ],
      ),
      child: Center(
        child: Text(
          letter,
          style: TextStyle(
            color: foreground,
            fontWeight: FontWeight.w800,
            fontSize: size * 0.52,
            height: 1,
            letterSpacing: -0.5,
          ),
        ),
      ),
    );
  }
}

/// Header title: the original Noova app logo (white wordmark on navy).
class NoovaHeader extends StatelessWidget {
  const NoovaHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final c = context.app.colors;
    return ClipRRect(
      borderRadius: BorderRadius.all(Radius.circular(8)),
      child: Image.asset(
        'assets/icon/app_icon.png',
        height: 30,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) =>
            NoovaMark(size: 26, background: c.hero, foreground: c.onHero),
      ),
    );
  }
}
