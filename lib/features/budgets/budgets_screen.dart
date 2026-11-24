import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme.dart';
import '../../data/providers.dart';

/// Budgets for variable categories with historical suggestions (US7).
class BudgetsScreen extends ConsumerWidget {
  const BudgetsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final budgetRepoAsync = ref.watch(budgetRepoProvider);
    final categoryRepoAsync = ref.watch(categoryRepoProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Presupuestos')),
      body: budgetRepoAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (budgetRepo) => categoryRepoAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('Error: $e')),
          data: (categoryRepo) => FutureBuilder(
            future: () async {
              final budgets = await budgetRepo.getAll();
              final variableCats =
                  await categoryRepo.getActive(TransactionType.expense);
              final variableOnly =
                  variableCats.where((c) => c.isVariable).toList();
              return {'budgets': budgets, 'cats': variableOnly};
            }(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }
              final budgets = snapshot.data!['budgets'] as List;
              final cats = snapshot.data!['cats'] as List;

              return ListView(
                padding: const EdgeInsets.all(12),
                children: [
                  for (final cat in cats)
                    _BudgetTile(
                      categoryName: cat.name,
                      budget: budgets.where((b) => b.categoryId == cat.id).firstOrNull,
                      categoryId: cat.id,
                    ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _BudgetTile extends ConsumerWidget {
  final String categoryName;
  final dynamic budget;
  final int categoryId;

  const _BudgetTile({
    required this.categoryName,
    this.budget,
    required this.categoryId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hasBudget = budget != null && budget.isActive;
    return Card(
      child: ListTile(
        title: Text(categoryName),
        subtitle: Text(hasBudget
            ? 'Cuota quincenal: \${budget.amountPerQuincena} (alerta \${budget.alertThreshold}%)'
            : 'Sin presupuesto'),
        trailing: Switch(
          value: hasBudget,
          activeColor: NoovaTheme.accent,
          onChanged: (v) async {
            final repo = await ref.read(budgetRepoProvider.future);
            if (v) {
              // Create with placeholder; user edits amount
              await repo.insert(Budget(
                categoryId: categoryId,
                amountPerQuincenaBps: 0,
              ));
            } else if (budget != null) {
              await repo.deactivate(budget);
            }
            ref.invalidate(budgetRepoProvider);
          },
        ),
        onTap: hasBudget ? () => _editAmount(context, ref) : null,
      ),
    );
  }

  Future<void> _editAmount(BuildContext context, WidgetRef ref) async {
    final controller = TextEditingController(
      text: budget.amountPerQuincena.toString(),
    );
    final result = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: NoovaTheme.surface,
        title: Text('Presupuesto: \$categoryName'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(labelText: 'Monto por quincena'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, controller.text),
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
    if (result != null) {
      final parsed = DecimalUtils.tryParse(result);
      if (parsed != null) {
        budget.amountPerQuincenaBps = parsed.shift(4).toBigInt().toInt();
        final repo = await ref.read(budgetRepoProvider.future);
        await repo.update(budget);
        ref.invalidate(budgetRepoProvider);
      }
    }
  }
}
