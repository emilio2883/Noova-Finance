import 'package:flutter/material.dart';

import 'package:noova_finance/theme/app_theme.dart';
import '../../transaction/quick_add_modal.dart';

/// FAB that opens the QuickAddModal.
class QuickAddButton extends StatelessWidget {
  const QuickAddButton({super.key});

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton.large(
      onPressed: () => _openModal(context),
      backgroundColor: context.app.colors.primary,
      foregroundColor: context.app.colors.textOnPrimary,
      child: const Icon(Icons.add, size: 36),
    );
  }

  void _openModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => const QuickAddModal(),
    );
  }
}
