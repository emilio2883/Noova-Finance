import 'package:flutter/material.dart';

import '../../core/theme.dart';
import '../../data/models/category.dart';
import '../../data/models/transaction.dart';
import '../../data/providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Dropdown to pick a category, filtered by transaction type.
class CategorySelector extends ConsumerWidget {
  final TransactionType type;
  final int? selectedId;
  final ValueChanged<int> onChanged;

  const CategorySelector({
    super.key,
    required this.type,
    this.selectedId,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesAsync = ref.watch(categoryRepoProvider);

    return categoriesAsync.when(
      loading: () => const CircularProgressIndicator(),
      error: (e, _) => Text('Error: $e'),
      data: (repo) => FutureBuilder<List<Category>>(
        future: repo.getActive(type),
        builder: (context, snapshot) {
          final categories = snapshot.data ?? [];
          if (categories.isEmpty) {
            return const Text('Sin categorías');
          }
          // Auto-select first if none selected
          if (selectedId == null && categories.isNotEmpty) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              onChanged(categories.first.id);
            });
          }
          return DropdownButtonFormField<int>(
            value: categories.any((c) => c.id == selectedId) ? selectedId : null,
            hint: const Text('Categoría'),
            dropdownColor: NoovaTheme.surface,
            items: categories
                .map((c) => DropdownMenuItem(
                      value: c.id,
                      child: Text(c.name),
                    ))
                .toList(),
            onChanged: (v) {
              if (v != null) onChanged(v);
            },
          );
        },
      ),
    );
  }
}
