import 'package:flutter/material.dart';

import 'package:noova_finance/theme/app_motion.dart';
import 'package:noova_finance/theme/app_theme.dart';

/// Progress bar that animates its fill on mount / value change, using M3 motion
/// tokens. Drop-in replacement for a static LinearProgressIndicator.
class AnimatedProgressBar extends StatelessWidget {
  final double value; // 0..1
  final double minHeight;
  final Color color;
  final Color? backgroundColor;
  final BorderRadius borderRadius;

  const AnimatedProgressBar({
    super.key,
    required this.value,
    required this.color,
    required this.borderRadius,
    this.minHeight = 8,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final target = value.isNaN ? 0.0 : value.clamp(0.0, 1.0);
    return ClipRRect(
      borderRadius: borderRadius,
      child: TweenAnimationBuilder<double>(
        tween: Tween<double>(begin: 0, end: target),
        duration: AppMotion.long,
        curve: AppMotion.emphasizedDecelerate,
        builder: (context, v, _) => LinearProgressIndicator(
          value: v,
          minHeight: minHeight,
          color: color,
          backgroundColor: backgroundColor ?? context.app.colors.surfaceVariant,
        ),
      ),
    );
  }
}
