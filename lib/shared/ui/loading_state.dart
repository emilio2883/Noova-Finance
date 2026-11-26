import 'package:flutter/material.dart';

import 'package:noova_finance/theme/app_theme.dart';

/// Simple centered loading indicator with optional label.
class LoadingState extends StatelessWidget {
  final String? label;
  const LoadingState({super.key, this.label});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(),
          if (label != null) ...[
            const SizedBox(height: 12),
            Text(label!,
                style: TextStyle(color: context.app.colors.textSecondary)),
          ],
        ],
      ),
    );
  }
}
