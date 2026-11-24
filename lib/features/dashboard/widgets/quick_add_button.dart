import 'package:flutter/material.dart';

import '../../../core/theme.dart';
import '../../transaction/quick_add_modal.dart';

/// FAB that opens the QuickAddModal.
class QuickAddButton extends StatelessWidget {
  const QuickAddButton({super.key});

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton.large(
      onPressed: () => _openModal(context),
      backgroundColor: NoovaTheme.accent,
      foregroundColor: Colors.black,
      child: const Icon(Icons.add, size: 36),
    );
  }

  void _openModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: NoovaTheme.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => const QuickAddModal(),
    );
  }
}
