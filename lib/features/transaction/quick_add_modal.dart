import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme.dart';
import '../../core/utils/decimal_utils.dart';
import '../../data/models/transaction.dart';
import 'providers/transaction_provider.dart';
import '../../shared/widgets/amount_input.dart';
import '../../shared/widgets/category_selector.dart';
import '../../shared/widgets/date_picker_field.dart';
import '../../theme/app_radii.dart';

/// Quick transaction registration: amount -> category -> date -> save.
/// Max 3 taps from home (spec SC-001).
class QuickAddModal extends ConsumerStatefulWidget {
  final TransactionType initialType;
  final int? initialCategoryId;
  const QuickAddModal({
    super.key,
    this.initialType = TransactionType.expense,
    this.initialCategoryId,
  });

  @override
  ConsumerState<QuickAddModal> createState() => _QuickAddModalState();
}

class _QuickAddModalState extends ConsumerState<QuickAddModal> {
  TransactionType _type = TransactionType.expense;
  String _amountText = '';
  int? _categoryId;
  DateTime _date = DateTime.now();

  @override
  void initState() {
    super.initState();
    _type = widget.initialType;
    _categoryId = widget.initialCategoryId;
  }

  bool get _isValid {
    final amount = DecimalUtils.tryParse(_amountText);
    return amount != null && amount > Decimal.zero && _categoryId != null;
  }

  Future<void> _save() async {
    if (!_isValid) return;
    final service = ref.read(transactionServiceProvider);
    await service.insert(
      date: _date,
      amount: DecimalUtils.tryParse(_amountText)!,
      type: _type,
      categoryId: _categoryId!,
    );
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final isExpense = _type == TransactionType.expense;
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Income/Expense toggle
              SegmentedButton<TransactionType>(
                segments: const [
                  ButtonSegment(
                    value: TransactionType.expense,
                    label: Text('Gasto'),
                    icon: Icon(Icons.remove_circle_outline),
                  ),
                  ButtonSegment(
                    value: TransactionType.income,
                    label: Text('Ingreso'),
                    icon: Icon(Icons.add_circle_outline),
                  ),
                ],
                selected: {_type},
                onSelectionChanged: (s) => setState(() => _type = s.first),
              ),
              const SizedBox(height: 16),

              // Amount
              Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  borderRadius: AppRadii.standard.brMd,
                ),
                child: AmountInput(
                  onChanged: (v) => setState(() => _amountText = v),
                ),
              ),
              const SizedBox(height: 16),

              // Category
              CategorySelector(
                type: _type,
                selectedId: _categoryId,
                onChanged: (id) => setState(() => _categoryId = id),
              ),
              const SizedBox(height: 16),

              // Date
              DatePickerField(
                value: _date,
                onChanged: (d) => setState(() => _date = d),
              ),
              const SizedBox(height: 20),

              // Save
              FilledButton(
                onPressed: _isValid ? _save : null,
                style: FilledButton.styleFrom(
                  backgroundColor: isExpense ? NoovaTheme.expense : NoovaTheme.income,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: const Text(
                  'Guardar',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}
