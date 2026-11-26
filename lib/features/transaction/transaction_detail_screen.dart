import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';


import '../../core/utils/decimal_utils.dart';
import '../../data/models/transaction.dart';
import '../../shared/widgets/category_selector.dart';
import '../../shared/widgets/date_picker_field.dart';
import 'providers/transaction_provider.dart';
import 'package:noova_finance/theme/app_theme.dart';

/// Full-screen view/edit/delete for a single transaction.
/// Replaces the old fixed bottom sheet (draggable, scrollable).
class TransactionDetailScreen extends ConsumerStatefulWidget {
  final Transaction transaction;
  const TransactionDetailScreen({super.key, required this.transaction});

  @override
  ConsumerState<TransactionDetailScreen> createState() =>
      _TransactionDetailScreenState();
}

class _TransactionDetailScreenState
    extends ConsumerState<TransactionDetailScreen> {
  late TextEditingController _amountCtrl;
  late TextEditingController _descCtrl;
  late TransactionType _type;
  late int _categoryId;
  late DateTime _date;

  @override
  void initState() {
    super.initState();
    final t = widget.transaction;
    _amountCtrl = TextEditingController(text: t.amount.toString());
    _descCtrl = TextEditingController(text: t.description ?? '');
    _type = t.type;
    _categoryId = t.categoryId;
    _date = t.date;
  }

  @override
  void dispose() {
    _amountCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final amount = DecimalUtils.tryParse(_amountCtrl.text);
    if (amount == null || amount <= Decimal.zero) return;
    final t = widget.transaction
      ..amountBps = amount.shift(4).toBigInt().toInt()
      ..type = _type
      ..categoryId = _categoryId
      ..date = _date
      ..description = _descCtrl.text.trim().isEmpty ? null : _descCtrl.text.trim()
      ..updatedAt = DateTime.now();
    await ref.read(transactionServiceProvider).update(t);
    if (mounted) Navigator.pop(context);
  }

  Future<void> _delete() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eliminar transacción'),
        content: const Text('¿Seguro que deseas eliminar esta transacción?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(backgroundColor: context.app.colors.expense),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
    if (ok == true) {
      await ref.read(transactionServiceProvider).delete(widget.transaction.id);
      if (mounted) Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isExpense = _type == TransactionType.expense;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Transacción'),
        actions: [
          IconButton(
            icon: Icon(Icons.delete_outline, color: context.app.colors.expense),
            onPressed: _delete,
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          SegmentedButton<TransactionType>(
            segments: const [
              ButtonSegment(value: TransactionType.expense, label: Text('Gasto')),
              ButtonSegment(value: TransactionType.income, label: Text('Ingreso')),
            ],
            selected: {_type},
            onSelectionChanged: (s) => setState(() => _type = s.first),
          ),
          const SizedBox(height: 20),
          TextField(
            controller: _amountCtrl,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            decoration: const InputDecoration(labelText: 'Monto', prefixText: r'$ '),
          ),
          const SizedBox(height: 16),
          CategorySelector(
            type: _type,
            selectedId: _categoryId,
            onChanged: (id) => setState(() => _categoryId = id),
          ),
          const SizedBox(height: 16),
          DatePickerField(value: _date, onChanged: (d) => setState(() => _date = d)),
          const SizedBox(height: 16),
          TextField(
            controller: _descCtrl,
            decoration: const InputDecoration(labelText: 'Descripción (opcional)'),
          ),
          const SizedBox(height: 28),
          FilledButton(
            onPressed: _save,
            style: FilledButton.styleFrom(
              backgroundColor: isExpense ? context.app.colors.expense : context.app.colors.income,
              foregroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: const Text('Guardar cambios',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}
