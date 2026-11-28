import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:noova_finance/theme/app_theme.dart';
import '../../core/utils/money_format.dart';
import '../../data/models/recurring_rule.dart';
import '../../data/models/transaction.dart';
import '../../data/providers.dart';
import '../../shared/ui/empty_state.dart';
import '../../shared/ui/loading_state.dart';
import '../dashboard/providers/dashboard_provider.dart';
import 'recurring_editor_sheet.dart';

class _Data {
  final List<RecurringRule> rules;
  final Map<int, String> catName;
  _Data(this.rules, this.catName);
}

/// Occurrences of [r] within [from, to] (inclusive, day-granularity).
List<DateTime> upcomingOccurrences(RecurringRule r, DateTime from, DateTime to) {
  if (!r.isActive) return const [];
  final res = <DateTime>[];
  final fromDay = DateTime(from.year, from.month, from.day);
  var cursor = DateTime(from.year, from.month, 1);
  while (!cursor.isAfter(to)) {
    final lastDay = DateTime(cursor.year, cursor.month + 1, 0).day;
    final day = r.activationDay > lastDay ? lastDay : r.activationDay;
    final d = DateTime(cursor.year, cursor.month, day);
    final okStart = !d.isBefore(r.startDate) && !d.isBefore(fromDay);
    final okEnd = !d.isAfter(to) && (r.endDate == null || !d.isAfter(r.endDate!));
    if (okStart && okEnd) res.add(d);
    cursor = DateTime(cursor.year, cursor.month + 1, 1);
  }
  return res;
}

class RecurringScreen extends ConsumerStatefulWidget {
  const RecurringScreen({super.key});

  @override
  ConsumerState<RecurringScreen> createState() => _RecurringScreenState();
}

class _RecurringScreenState extends ConsumerState<RecurringScreen> {
  late Future<_Data> _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<_Data> _load() async {
    final recRepo = await ref.read(recurringRepoProvider.future);
    final catRepo = await ref.read(categoryRepoProvider.future);
    final rules = await recRepo.getAll();
    final cats = await catRepo.getAll();
    return _Data(rules, {for (final c in cats) c.id: c.name});
  }

  void _reload() => setState(() => _future = _load());

  Future<void> _editOrCreate(RecurringRule? rule) async {
    final ok = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      builder: (_) => RecurringEditorSheet(rule: rule),
    );
    if (ok == true) {
      ref.invalidate(dashboardProvider);
      _reload();
    }
  }

  Future<void> _toggle(RecurringRule r, bool v) async {
    final recRepo = await ref.read(recurringRepoProvider.future);
    r.isActive = v;
    await recRepo.update(r);
    ref.invalidate(dashboardProvider);
    _reload();
  }

  Future<void> _delete(RecurringRule r) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Borrar regla'),
        content: const Text('¿Eliminar esta regla recurrente? Las transacciones ya generadas se conservan.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancelar')),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Borrar')),
        ],
      ),
    );
    if (ok == true) {
      final recRepo = await ref.read(recurringRepoProvider.future);
      await recRepo.delete(r.id);
      ref.invalidate(dashboardProvider);
      _reload();
    }
  }

  @override
  Widget build(BuildContext context) {
    final app = context.app;
    return Scaffold(
      appBar: AppBar(title: const Text('Recurrentes')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _editOrCreate(null),
        icon: const Icon(Icons.add),
        label: const Text('Nueva regla'),
      ),
      body: FutureBuilder<_Data>(
        future: _future,
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const LoadingState();
          }
          final data = snap.data!;
          final now = DateTime.now();
          final horizon = now.add(const Duration(days: 90));
          final upcoming = <(DateTime, RecurringRule)>[];
          for (final r in data.rules) {
            for (final d in upcomingOccurrences(r, now, horizon)) {
              upcoming.add((d, r));
            }
          }
          upcoming.sort((a, b) => a.$1.compareTo(b.$1));

          return ListView(
            padding: EdgeInsets.fromLTRB(
                app.spacing.md, app.spacing.sm, app.spacing.md, app.spacing.xxl),
            children: [
              Text('REGLAS (${data.rules.length})',
                  style: TextStyle(
                      color: app.colors.textSecondary,
                      fontSize: 12,
                      letterSpacing: 1.5)),
              SizedBox(height: app.spacing.sm),
              if (data.rules.isEmpty)
                const EmptyState(
                  icon: Icons.autorenew,
                  title: 'Sin reglas recurrentes',
                  message: 'Crea una regla para generar movimientos automáticamente.',
                )
              else
                for (final r in data.rules)
                  _RuleCard(
                    rule: r,
                    categoryName: data.catName[r.categoryId] ?? 'Categoría',
                    onToggle: (v) => _toggle(r, v),
                    onEdit: () => _editOrCreate(r),
                    onDelete: () => _delete(r),
                  ),
              SizedBox(height: app.spacing.lg),
              Text('PRÓXIMOS PAGOS (90 días)',
                  style: TextStyle(
                      color: app.colors.textSecondary,
                      fontSize: 12,
                      letterSpacing: 1.5)),
              SizedBox(height: app.spacing.sm),
              if (upcoming.isEmpty)
                Padding(
                  padding: EdgeInsets.all(app.spacing.md),
                  child: Text('Sin pagos programados.',
                      style: TextStyle(color: app.colors.textSecondary)),
                )
              else
                for (final entry in upcoming)
                  _UpcomingRow(
                    date: entry.$1,
                    rule: entry.$2,
                    categoryName: data.catName[entry.$2.categoryId] ?? 'Categoría',
                  ),
            ],
          );
        },
      ),
    );
  }
}

class _RuleCard extends StatelessWidget {
  final RecurringRule rule;
  final String categoryName;
  final ValueChanged<bool> onToggle;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _RuleCard({
    required this.rule,
    required this.categoryName,
    required this.onToggle,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final app = context.app;
    final freq = rule.frequency == RecurringFrequency.monthly
        ? 'Mensual · día ${rule.activationDay}'
        : 'Quincenal · día ${rule.activationDay}';
    final isIncome = rule.type == TransactionType.income;
    final next = upcomingOccurrences(rule, DateTime.now(), DateTime.now().add(const Duration(days: 366)));
    final nextLabel = next.isEmpty
        ? 'Sin próxima fecha'
        : 'Próx: ${next.first.day}/${next.first.month}/${next.first.year}';
    return Card(
      child: ListTile(
        onTap: onEdit,
        leading: Icon(
          isIncome ? Icons.arrow_downward : Icons.arrow_upward,
          color: isIncome ? app.colors.income : app.colors.expense,
        ),
        title: Text(rule.label ?? categoryName,
            style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text('$categoryName · $freq · $nextLabel',
            style: const TextStyle(fontSize: 12)),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(MoneyFormat.format(rule.amount),
                style: const TextStyle(fontWeight: FontWeight.bold)),
            Switch(value: rule.isActive, onChanged: onToggle),
            IconButton(
              icon: Icon(Icons.delete_outline, color: app.colors.expense),
              onPressed: onDelete,
              tooltip: 'Borrar',
            ),
          ],
        ),
      ),
    );
  }
}

class _UpcomingRow extends StatelessWidget {
  final DateTime date;
  final RecurringRule rule;
  final String categoryName;

  const _UpcomingRow({
    required this.date,
    required this.rule,
    required this.categoryName,
  });

  @override
  Widget build(BuildContext context) {
    final app = context.app;
    final isIncome = rule.type == TransactionType.income;
    return Padding(
      padding: EdgeInsets.symmetric(vertical: app.spacing.xs),
      child: Row(
        children: [
          SizedBox(
            width: 64,
            child: Text('${date.day}/${date.month}',
                style: TextStyle(fontSize: 12, color: app.colors.textSecondary)),
          ),
          Expanded(
            child: Text(rule.label ?? categoryName,
                maxLines: 1, overflow: TextOverflow.ellipsis),
          ),
          Text(
            '${isIncome ? '+' : '-'}${MoneyFormat.format(rule.amount)}',
            style: TextStyle(
                fontWeight: FontWeight.w600,
                color: isIncome ? app.colors.income : app.colors.expense),
          ),
        ],
      ),
    );
  }
}
