import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:noova_finance/theme/app_theme.dart';
import '../../core/utils/decimal_utils.dart';
import '../../data/models/budget.dart';
import '../../data/models/category.dart';
import '../../data/providers.dart';

/// Edit per-quincena budgets (amount + alert threshold %) for subcategories.
class BudgetEditorSheet extends ConsumerStatefulWidget {
  final List<Category> categories;
  const BudgetEditorSheet({super.key, required this.categories});

  @override
  ConsumerState<BudgetEditorSheet> createState() => _BudgetEditorSheetState();
}

class _BudgetEditorSheetState extends ConsumerState<BudgetEditorSheet> {
  final Map<int, TextEditingController> _amount = {};
  final Map<int, TextEditingController> _threshold = {};
  final Map<int, int> _ids = {};
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final repo = await ref.read(budgetRepoProvider.future);
    final all = await repo.getAll();
    for (final cat in widget.categories) {
      final existing =
          all.where((b) => b.categoryId == cat.id && b.isActive).firstOrNull;
      _ids[cat.id] = existing?.id ?? 0;
      _amount[cat.id] = TextEditingController(
          text: existing != null ? existing.amountPerQuincena.toStringAsFixed(2) : '');
      _threshold[cat.id] =
          TextEditingController(text: (existing?.alertThreshold ?? 80).toString());
    }
    if (mounted) setState(() => _loaded = true);
  }

  @override
  void dispose() {
    for (final c in _amount.values) { c.dispose(); }
    for (final c in _threshold.values) { c.dispose(); }
    super.dispose();
  }

  Future<void> _save() async {
    final repo = await ref.read(budgetRepoProvider.future);
    for (final cat in widget.categories) {
      final amount = DecimalUtils.tryParse(_amount[cat.id]?.text ?? '');
      final bps = amount == null ? 0 : amount.shift(4).toBigInt().toInt();
      final thr = (int.tryParse(_threshold[cat.id]?.text.trim() ?? '') ?? 80).clamp(1, 100);
      final existingId = _ids[cat.id] ?? 0;
      if (bps <= 0) {
        if (existingId != 0) await repo.delete(existingId);
        continue;
      }
      if (existingId != 0) {
        final b = await repo.getById(existingId);
        if (b != null) {
          b.amountPerQuincenaBps = bps;
          b.alertThreshold = thr;
          await repo.update(b);
          continue;
        }
      }
      await repo.insert(Budget(
          categoryId: cat.id, amountPerQuincenaBps: bps, alertThreshold: thr));
    }
    if (mounted) Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: _loaded
          ? SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text('Presupuestos por quincena',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text('Monto y umbral de alerta (%) por subcategoría',
                      style: TextStyle(
                          fontSize: 12, color: context.app.colors.textSecondary)),
                  const SizedBox(height: 16),
                  for (final cat in widget.categories) ...[
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          flex: 3,
                          child: TextField(
                            controller: _amount[cat.id],
                            keyboardType: const TextInputType.numberWithOptions(
                                decimal: true),
                            decoration: InputDecoration(
                                labelText: cat.name, prefixText: r'$ '),
                          ),
                        ),
                        const SizedBox(width: 8),
                        SizedBox(
                          width: 96,
                          child: TextField(
                            controller: _threshold[cat.id],
                            keyboardType: TextInputType.number,
                            decoration:
                                const InputDecoration(labelText: 'Umbral %'),
                          ),
                        ),
                        IconButton(
                          tooltip: 'Eliminar',
                          icon: Icon(Icons.delete_outline,
                              color: context.app.colors.expense),
                          onPressed: () =>
                              setState(() => _amount[cat.id]?.clear()),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                  ],
                  const SizedBox(height: 8),
                  FilledButton(
                    onPressed: _save,
                    style: FilledButton.styleFrom(
                      backgroundColor: context.app.colors.primary,
                      foregroundColor: context.app.colors.textOnPrimary,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: const Text('Guardar presupuestos'),
                  ),
                ],
              ),
            )
          : const Padding(
              padding: EdgeInsets.all(40),
              child: Center(child: CircularProgressIndicator()),
            ),
    );
  }
}
