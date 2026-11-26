import 'package:flutter/material.dart';

import 'package:noova_finance/theme/app_theme.dart';

/// Text glyph fallback for the brand mark (used only if the image is missing).
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
      ),
      child: Center(
        child: Text(letter,
            style: TextStyle(
                color: foreground,
                fontWeight: FontWeight.w800,
                fontSize: size * 0.52,
                height: 1)),
      ),
    );
  }
}

/// The app logo (white wordmark, transparent) for the header — left aligned.
class NoovaLogoImage extends StatelessWidget {
  final double height;
  const NoovaLogoImage({super.key, this.height = 26});

  @override
  Widget build(BuildContext context) {
    final c = context.app.colors;
    return Image.asset(
      'assets/brand/noova_logo.png',
      height: height,
      fit: BoxFit.contain,
      alignment: Alignment.centerLeft,
      errorBuilder: (_, __, ___) => Row(mainAxisSize: MainAxisSize.min, children: [
        NoovaMark(size: 24, background: c.primary, foreground: c.textOnPrimary),
        const SizedBox(width: 8),
        Text('Noova',
            style: TextStyle(
                color: c.onHero, fontWeight: FontWeight.w700, fontSize: 18)),
      ]),
    );
  }
}

/// The first character of the logo, white mark inside a navy circle (centre button).
class NoovaMarkImage extends StatelessWidget {
  final double size;
  const NoovaMarkImage({super.key, this.size = 52});

  @override
  Widget build(BuildContext context) {
    final c = context.app.colors;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: c.hero,
        shape: BoxShape.circle,
        boxShadow: const [
          BoxShadow(color: Colors.black26, blurRadius: 8, offset: Offset(0, 3)),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(size * 0.2),
        child: Image.asset(
          'assets/brand/noova_mark.png',
          fit: BoxFit.contain,
          errorBuilder: (_, __, ___) => Center(
            child: Text('N',
                style: TextStyle(
                    color: c.onHero,
                    fontWeight: FontWeight.w800,
                    fontSize: size * 0.5)),
          ),
        ),
      ),
    );
  }
}
