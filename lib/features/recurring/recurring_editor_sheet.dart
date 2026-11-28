import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:noova_finance/theme/app_theme.dart';
import '../../core/utils/decimal_utils.dart';
import '../../data/models/recurring_rule.dart';
import '../../data/models/transaction.dart';
import '../../data/providers.dart';
import '../../shared/widgets/amount_input.dart';
import '../../shared/widgets/category_selector.dart';
import '../../shared/widgets/date_picker_field.dart';
import '../dashboard/providers/dashboard_provider.dart';

/// Create/edit a recurring rule. Reused by Subscriptions (isSubscription=true).
class RecurringEditorSheet extends ConsumerStatefulWidget {
  final RecurringRule? rule;
  final bool isSubscription;
  const RecurringEditorSheet({super.key, this.rule, this.isSubscription = false});

  @override
  ConsumerState<RecurringEditorSheet> createState() => _RecurringEditorSheetState();
}

class _RecurringEditorSheetState extends ConsumerState<RecurringEditorSheet> {
  late TransactionType _type;
  late RecurringFrequency _frequency;
  late int _activationDay;
  late DateTime _startDate;
  DateTime? _endDate;
  late bool _active;
  int? _categoryId;
  String _amountText = '';
  late final TextEditingController _labelCtrl;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final r = widget.rule;
    _type = r?.type ?? TransactionType.expense;
    _frequency = r?.frequency ?? RecurringFrequency.monthly;
    _activationDay = r?.activationDay ?? DateTime.now().day;
    _startDate = r?.startDate ?? DateTime.now();
    _endDate = r?.endDate;
    _active = r?.isActive ?? true;
    _categoryId = r?.categoryId;
    _amountText = r == null ? '' : r.amount.toString();
    _labelCtrl = TextEditingController(text: r?.label ?? '');
  }

  @override
  void dispose() {
    _labelCtrl.dispose();
    super.dispose();
  }

  bool get _valid =>
      DecimalUtils.tryParse(_amountText) != null &&
      DecimalUtils.tryParse(_amountText)! > Decimal.zero &&
      _categoryId != null;

  Future<void> _save() async {
    if (!_valid) return;
    setState(() => _saving = true);
    final recRepo = await ref.read(recurringRepoProvider.future);
    final amountBps = DecimalUtils.tryParse(_amountText)!.shift(4).toBigInt().toInt();
    final existing = widget.rule;
    if (existing != null) {
      existing
        ..categoryId = _categoryId!
        ..amountBps = amountBps
        ..frequency = _frequency
        ..type = _type
        ..activationDay = _activationDay
        ..isActive = _active
        ..startDate = _startDate
        ..endDate = _endDate
        ..label = _labelCtrl.text.trim().isEmpty ? null : _labelCtrl.text.trim()
        ..isSubscription = widget.isSubscription || existing.isSubscription;
      await recRepo.update(existing);
    } else {
      await recRepo.insert(RecurringRule(
        categoryId: _categoryId!,
        amountBps: amountBps,
        frequency: _frequency,
        type: _type,
        activationDay: _activationDay,
        isActive: _active,
        startDate: _startDate,
        endDate: _endDate,
        label: _labelCtrl.text.trim().isEmpty ? null : _labelCtrl.text.trim(),
        isSubscription: widget.isSubscription,
      ));
    }
    try {
      final gen = await ref.read(recurringGeneratorProvider.future);
      await gen.generateDue();
    } catch (_) {}
    ref.invalidate(dashboardProvider);
    if (mounted) Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    final app = context.app;
    final days = _frequency == RecurringFrequency.quincenal
        ? const [1, 16]
        : List<int>.generate(31, (i) => i + 1);
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(app.spacing.md),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(widget.rule == null ? 'Nueva regla recurrente' : 'Editar regla',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              SizedBox(height: app.spacing.sm),
              TextField(
                controller: _labelCtrl,
                decoration: const InputDecoration(
                    labelText: 'Etiqueta (opcional)',
                    hintText: 'Ej. Netflix, Renta, Seguro'),
              ),
              SizedBox(height: app.spacing.sm),
              SegmentedButton<TransactionType>(
                segments: const [
                  ButtonSegment(value: TransactionType.expense, label: Text('Gasto')),
                  ButtonSegment(value: TransactionType.income, label: Text('Ingreso')),
                ],
                selected: {_type},
                onSelectionChanged: (s) => setState(() => _type = s.first),
              ),
              SizedBox(height: app.spacing.sm),
              Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  borderRadius: app.radii.brMd,
                ),
                child: AmountInput(
                  onChanged: (v) => setState(() => _amountText = v),
                ),
              ),
              SizedBox(height: app.spacing.sm),
              CategorySelector(
                type: _type,
                selectedId: _categoryId,
                onChanged: (id) => setState(() => _categoryId = id),
              ),
              SizedBox(height: app.spacing.sm),
              SegmentedButton<RecurringFrequency>(
                segments: const [
                  ButtonSegment(
                      value: RecurringFrequency.quincenal, label: Text('Quincenal')),
                  ButtonSegment(
                      value: RecurringFrequency.monthly, label: Text('Mensual')),
                ],
                selected: {_frequency},
                onSelectionChanged: (s) => setState(() {
                  _frequency = s.first;
                  _activationDay = s.first == RecurringFrequency.quincenal ? 1 : _activationDay;
                }),
              ),
              SizedBox(height: app.spacing.sm),
              DropdownButtonFormField<int>(
                value: days.contains(_activationDay) ? _activationDay : days.first,
                decoration: const InputDecoration(labelText: 'Día de activación'),
                items: [
                  for (final d in days)
                    DropdownMenuItem(value: d, child: Text('Día $d')),
                ],
                onChanged: (v) => setState(() => _activationDay = v ?? days.first),
              ),
              SizedBox(height: app.spacing.sm),
              DatePickerField(
                value: _startDate,
                onChanged: (d) => setState(() => _startDate = d),
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Tiene fecha de fin'),
                value: _endDate != null,
                onChanged: (v) => setState(() => _endDate =
                    v ? DateTime(_startDate.year + 1, _startDate.month, _startDate.day) : null),
              ),
              if (_endDate != null)
                DatePickerField(
                  value: _endDate!,
                  onChanged: (d) => setState(() => _endDate = d),
                ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Activa'),
                value: _active,
                onChanged: (v) => setState(() => _active = v),
              ),
              SizedBox(height: app.spacing.sm),
              FilledButton(
                onPressed: _valid && !_saving ? _save : null,
                child: Text(_saving ? 'Guardando…' : 'Guardar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
