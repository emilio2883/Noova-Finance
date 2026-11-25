import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme.dart';
import '../../core/utils/money_format.dart';
import '../../data/models/category.dart';
import '../../data/models/transaction.dart';
import '../../data/providers.dart';
import 'budget_editor_sheet.dart';

class _ParentBudget {
  final Category parent;
  final List<Category> variableChildren;
  final Decimal total;
  _ParentBudget(this.parent, this.variableChildren, this.total);
}

/// Budgets by principal category, with a global total (US7, hierarchy-aware).
class BudgetsScreen extends ConsumerWidget {
  const BudgetsScreen({super.key});

  Future<List<_ParentBudget>> _load(WidgetRef ref) async {
    final catRepo = await ref.read(categoryRepoProvider.future);
    final budgetRepo = await ref.read(budgetRepoProvider.future);
    final principals = await catRepo.getTopLevel(TransactionType.expense);
    final budgets = await budgetRepo.getActive();
    final byCat = {for (final b in budgets) b.categoryId: b.amountPerQuincena};

    final result = <_ParentBudget>[];
    for (final p in principals) {
      final children = await catRepo.getChildren(p.id);
      final variable = children.where((c) => c.isVariable).toList();
      var total = Decimal.zero;
      for (final c in variable) {
        total += byCat[c.id] ?? Decimal.zero;
      }
      result.add(_ParentBudget(p, variable, total));
    }
    return result;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Presupuestos')),
      body: FutureBuilder<List<_ParentBudget>>(
        future: _load(ref),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final items = snapshot.data!;
          final global = items.fold<Decimal>(
              Decimal.zero, (acc, e) => acc + e.total);

          return ListView(
            padding: const EdgeInsets.all(12),
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Presupuesto global',
                          style: TextStyle(fontWeight: FontWeight.w600)),
                      Text(MoneyFormat.format(global),
                          style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: NoovaTheme.accent)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8),
              for (final item in items)
                Card(
                  child: ListTile(
                    title: Text(item.parent.name),
                    subtitle: Text(
                      item.variableChildren.isEmpty
                          ? 'Sin subcategorías variables'
                          : '${item.variableChildren.length} subcategorías · ${MoneyFormat.format(item.total)} por quincena',
                      style: const TextStyle(fontSize: 12),
                    ),
                    trailing: const Icon(Icons.chevron_right, size: 18),
                    enabled: item.variableChildren.isNotEmpty,
                    onTap: item.variableChildren.isEmpty
                        ? null
                        : () async {
                            await showModalBottomSheet(
                              context: context,
                              isScrollControlled: true,
                              backgroundColor:
                                  Theme.of(context).colorScheme.surface,
                              shape: const RoundedRectangleBorder(
                                borderRadius: BorderRadius.vertical(
                                    top: Radius.circular(20)),
                              ),
                              builder: (_) => BudgetEditorSheet(
                                  categories: item.variableChildren),
                            );
                          },
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
