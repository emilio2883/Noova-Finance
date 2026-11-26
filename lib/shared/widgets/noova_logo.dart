import 'package:flutter/material.dart';

import 'package:noova_finance/theme/app_theme.dart';

/// The Noova "N" brand mark, rendered as text so it stays crisp at any size
/// (no image asset needed). Used in the header and as the centre nav button.
class NoovaMark extends StatelessWidget {
  final double size;
  final Color background;
  final Color foreground;
  final bool circle;

  const NoovaMark({
    super.key,
    this.size = 36,
    required this.background,
    required this.foreground,
    this.circle = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: background,
        borderRadius:
            circle ? BorderRadius.all(Radius.circular(size / 2)) : BorderRadius.all(Radius.circular(size * 0.28)),
        boxShadow: const [
          BoxShadow(color: Colors.black26, blurRadius: 8, offset: Offset(0, 3)),
        ],
      ),
      child: Center(
        child: Text(
          'N',
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

/// Header title: Noova mark + wordmark, tuned for a navy AppBar.
class NoovaHeader extends StatelessWidget {
  const NoovaHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final c = context.app.colors;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        NoovaMark(size: 26, background: c.primary, foreground: c.textOnPrimary),
        const SizedBox(width: 10),
        Text(
          'Noova',
          style: TextStyle(
            color: c.onHero,
            fontWeight: FontWeight.w700,
            fontSize: 20,
            letterSpacing: 0.3,
          ),
        ),
      ],
    );
  }
}
