import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:noova_finance/theme/app_theme.dart';
import '../../../core/utils/money_format.dart';
import '../../budgets/budget_editor_sheet.dart';
import '../../transaction/quick_add_modal.dart';
import '../providers/dashboard_provider.dart';
import '../../../shared/widgets/animated_progress_bar.dart';
import '../../../theme/app_radii.dart';

/// One category dashboard card: name, amount, dynamic bar, budget rollup.
/// Tap -> detail sheet. Swipe down -> add expense, swipe up -> edit budgets.
class CategoryDashboardCard extends ConsumerWidget {
  final CategorySpend spend;
  final double maxTotal;

  const CategoryDashboardCard({
    super.key,
    required this.spend,
    required this.maxTotal,
  });

  double get _fraction {
    final t = spend.total.toDouble();
    return maxTotal <= 0 ? 0 : (t / maxTotal).clamp(0.0, 1.0);
  }

  Future<void> _openAdd(BuildContext context) async {
    final catId = spend.children.isNotEmpty
        ? spend.children.first.category.id
        : spend.parent.id;
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => QuickAddModal(initialCategoryId: catId),
    );
  }

  Future<void> _openBudgets(BuildContext context) async {
    final variable = spend.children.map((c) => c.category).toList();
    if (variable.isEmpty) return;
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => BudgetEditorSheet(categories: variable),
    );
  }

  void _openDetail(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.5,
        maxChildSize: 0.9,
        builder: (ctx, controller) => ListView(
          controller: controller,
          padding: const EdgeInsets.all(20),
          children: [
            Text(spend.parent.name,
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text('Gasto del mes: ${MoneyFormat.format(spend.total)}',
                style: TextStyle(color: context.app.colors.textSecondary)),
            const SizedBox(height: 16),
            for (final child in spend.children)
              _ChildRow(child: child),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: FilledButton.icon(
                    onPressed: () {
                      Navigator.pop(ctx);
                      _openAdd(context);
                    },
                    icon: const Icon(Icons.add),
                    label: const Text('Agregar gasto'),
                    style: FilledButton.styleFrom(
                      backgroundColor: context.app.colors.income,
                      foregroundColor: Colors.black,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: () {
                      Navigator.pop(ctx);
                      _openBudgets(context);
                    },
                    icon: const Icon(Icons.savings_outlined),
                    label: const Text('Presupuesto'),
                    style: FilledButton.styleFrom(
                      backgroundColor: context.app.colors.primary,
                      foregroundColor: Colors.black,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
        child: InkWell(
          borderRadius: AppRadii.standard.brMd,
          onTap: () => _openDetail(context),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(spend.parent.name,
                          style: const TextStyle(
                              fontSize: 15, fontWeight: FontWeight.w600)),
                    ),
                    Text(MoneyFormat.format(spend.total),
                        style: const TextStyle(
                            fontSize: 15, fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(height: 8),
                AnimatedProgressBar(
                  value: _fraction,
                  minHeight: 8,
                  borderRadius: AppRadii.standard.brXs,
                  backgroundColor:
                      Theme.of(context).colorScheme.surfaceContainerHighest,
                  color: context.app.colors.expense,
                ),
                if (spend.hasBudget) ...[
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Presupuesto: ${MoneyFormat.format(spend.budget)}',
                        style: TextStyle(
                            fontSize: 11, color: context.app.colors.textSecondary),
                      ),
                      Text(
                        '${spend.percentUsed}%',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: spend.percentUsed >= 100
                              ? context.app.colors.expense
                              : spend.percentUsed >= 80
                                  ? context.app.colors.warning
                                  : context.app.colors.income,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  AnimatedProgressBar(
                    value: (spend.percentUsed / 100).clamp(0.0, 1.0),
                    minHeight: 5,
                    borderRadius: AppRadii.standard.brXs,
                    backgroundColor:
                        Theme.of(context).colorScheme.surfaceContainerHighest,
                    color: spend.percentUsed >= 100
                        ? context.app.colors.expense
                        : spend.percentUsed >= 80
                            ? context.app.colors.warning
                            : context.app.colors.primary,
                  ),
                ],
              ],
            ),
          ),
        ),
    );
  }
}

class _ChildRow extends StatelessWidget {
  final ChildSpend child;
  const _ChildRow({required this.child});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(child: Text(child.category.name)),
          Text(MoneyFormat.format(child.spent),
              style: const TextStyle(fontWeight: FontWeight.w600)),
          if (child.budget > Decimal.zero) ...[
            const SizedBox(width: 8),
            Text(' / ${MoneyFormat.format(child.budget)}',
                style: TextStyle(
                    fontSize: 12, color: context.app.colors.textSecondary)),
          ],
        ],
      ),
    );
  }
}
