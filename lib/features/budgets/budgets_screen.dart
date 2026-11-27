import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:noova_finance/theme/app_theme.dart';
import '../../core/utils/decimal_utils.dart';
import '../../core/utils/money_format.dart';
import '../../data/models/budget.dart';
import '../../data/models/transaction.dart';
import '../../data/providers.dart';
import '../../shared/widgets/main_nav_bar.dart';
import '../dashboard/providers/dashboard_provider.dart';

/// Presupuestos creados desde cero (elegir subcategoría + valor + límite).
class BudgetsScreen extends ConsumerStatefulWidget {
  const BudgetsScreen({super.key});
  @override
  ConsumerState<BudgetsScreen> createState() => _BudgetsScreenState();
}

class _BudgetsScreenState extends ConsumerState<BudgetsScreen> {
  Future<List<Budget>> _load() async {
    final repo = await ref.read(budgetRepoProvider.future);
    return repo.getActive();
  }

  Future<void> _edit(BuildContext context, {Budget? budget}) async {
    final budgetRepo = await ref.read(budgetRepoProvider.future);
    final catRepo = await ref.read(categoryRepoProvider.future);
    final leaves = await catRepo.getLeaves(TransactionType.expense);
    if (!context.mounted) return;
    final amountCtrl = TextEditingController(
        text: budget != null
            ? DecimalUtils.fromBps(budget.amountPerQuincenaBps).toStringAsFixed(2)
            : '');
    final limitCtrl = TextEditingController(text: (budget?.alertThreshold ?? 80).toString());
    int? selCat = budget?.categoryId;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSt) => AlertDialog(
          title: Text(budget == null ? 'Nuevo presupuesto' : 'Editar presupuesto'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<int>(
                value: selCat,
                isExpanded: true,
                decoration: const InputDecoration(labelText: 'Subcategoría'),
                items: [
                  for (final cat in leaves)
                    DropdownMenuItem(value: cat.id, child: Text(cat.name)),
                ],
                onChanged: (v) => setSt(() => selCat = v),
              ),
              const SizedBox(height: 8),
              TextField(
                  controller: amountCtrl,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(
                      labelText: 'Presupuesto (por quincena)', prefixText: r'$ ')),
              const SizedBox(height: 8),
              TextField(
                  controller: limitCtrl,
                  keyboardType: TextInputType.number,
                  decoration:
                      const InputDecoration(labelText: 'Límite de alerta (%)')),
            ],
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('Cancelar')),
            FilledButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: const Text('Guardar')),
          ],
        ),
      ),
    );
    if (ok != true || selCat == null) return;
    final amount = DecimalUtils.tryParse(amountCtrl.text);
    final bps = amount == null ? 0 : amount.shift(4).toBigInt().toInt();
    final limit = (int.tryParse(limitCtrl.text.trim()) ?? 80).clamp(1, 100);
    if (bps <= 0) return;
    if (budget != null) {
      budget
        ..amountPerQuincenaBps = bps
        ..alertThreshold = limit
        ..categoryId = selCat!;
      await budgetRepo.update(budget);
    } else {
      final existing = await budgetRepo.getByCategory(selCat!);
      if (existing != null) {
        existing
          ..amountPerQuincenaBps = bps
          ..alertThreshold = limit
          ..isActive = true;
        await budgetRepo.update(existing);
      } else {
        await budgetRepo.insert(Budget(
            categoryId: selCat!, amountPerQuincenaBps: bps, alertThreshold: limit));
      }
    }
    ref.invalidate(dashboardProvider);
    if (mounted) setState(() {});
  }

  Future<void> _delete(Budget b) async {
    final repo = await ref.read(budgetRepoProvider.future);
    await repo.delete(b.id);
    ref.invalidate(dashboardProvider);
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final c = context.app.colors;
    return Scaffold(
      appBar: AppBar(title: const Text('Presupuestos')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _edit(context),
        icon: const Icon(Icons.add),
        label: const Text('Nuevo presupuesto'),
      ),
      bottomNavigationBar: const MainNavBar(location: '/budgets'),
      body: FutureBuilder<List<Budget>>(
        future: _load(),
        builder: (context, snap) {
          if (!snap.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final budgets = snap.data!;
          final total = budgets.fold<Decimal>(
              Decimal.zero, (a, b) => a + b.amountPerQuincena);
          return FutureBuilder(
            future: ref.read(categoryRepoProvider.future).then((r) => r.getAll()),
            builder: (context, catSnap) {
              final cats = catSnap.data;
              String nameOf(int id) {
                if (cats == null) return 'Categoría';
                final m = {for (final x in cats) x.id: x};
                return m[id]?.name ?? 'Categoría';
              }

              return ListView(
                padding: const EdgeInsets.fromLTRB(12, 12, 12, 96),
                children: [
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Presupuesto global',
                              style: TextStyle(fontWeight: FontWeight.w600)),
                          Text(MoneyFormat.format(total),
                              style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: c.primary)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (budgets.isEmpty)
                    const Padding(
                      padding: EdgeInsets.all(32),
                      child: Center(
                          child: Text(
                              'Aún no hay presupuestos.\nCrea uno con el botón +')),
                    ),
                  for (final b in budgets)
                    Card(
                      child: ListTile(
                        title: Text(nameOf(b.categoryId)),
                        subtitle: Text(
                            '${MoneyFormat.format(b.amountPerQuincena)} / quincena · límite ${b.alertThreshold}%'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                                icon: Icon(Icons.edit_outlined, color: c.primary),
                                onPressed: () => _edit(context, budget: b)),
                            IconButton(
                                icon: Icon(Icons.delete_outline, color: c.expense),
                                onPressed: () => _delete(b)),
                          ],
                        ),
                      ),
                    ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}
