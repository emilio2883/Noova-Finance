import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';


import '../../core/utils/decimal_utils.dart';
import '../../data/models/budget.dart';
import '../../data/models/category.dart';
import '../../data/providers.dart';
import 'package:noova_finance/theme/app_theme.dart';

/// Edit per-quincena budgets for a list of (variable) subcategories.
class BudgetEditorSheet extends ConsumerStatefulWidget {
  final List<Category> categories;
  const BudgetEditorSheet({super.key, required this.categories});

  @override
  ConsumerState<BudgetEditorSheet> createState() => _BudgetEditorSheetState();
}

class _BudgetEditorSheetState extends ConsumerState<BudgetEditorSheet> {
  final Map<int, TextEditingController> _controllers = {};
  final Map<int, int> _budgetIds = {};
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
      _budgetIds[cat.id] = existing?.id ?? 0;
      _controllers[cat.id] = TextEditingController(
        text: existing != null
            ? existing.amountPerQuincena.toStringAsFixed(2)
            : '',
      );
    }
    if (mounted) setState(() => _loaded = true);
  }

  @override
  void dispose() {
    for (final c in _controllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _save() async {
    final repo = await ref.read(budgetRepoProvider.future);
    for (final cat in widget.categories) {
      final text = _controllers[cat.id]?.text ?? '';
      final amount = DecimalUtils.tryParse(text);
      final bps = amount == null ? 0 : amount.shift(4).toBigInt().toInt();
      final existingId = _budgetIds[cat.id] ?? 0;
      if (bps <= 0) {
        if (existingId != 0) await repo.delete(existingId);
        continue;
      }
      if (existingId != 0) {
        final b = await repo.getById(existingId);
        if (b != null) {
          b.amountPerQuincenaBps = bps;
          await repo.update(b);
          continue;
        }
      }
      await repo.insert(Budget(categoryId: cat.id, amountPerQuincenaBps: bps));
    }
    if (mounted) Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: _loaded
          ? Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text('Presupuestos por quincena',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  for (final cat in widget.categories) ...[
                    TextField(
                      controller: _controllers[cat.id],
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      decoration: InputDecoration(
                        labelText: cat.name,
                        prefixText: r'$ ',
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],
                  const SizedBox(height: 8),
                  FilledButton(
                    onPressed: _save,
                    style: FilledButton.styleFrom(
                      backgroundColor: context.app.colors.primary,
                      foregroundColor: Colors.black,
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
