import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:noova_finance/theme/app_theme.dart';
import '../../core/services/notification_service.dart';
import '../../core/utils/money_format.dart';
import '../../data/models/recurring_rule.dart';
import '../../data/models/transaction.dart';
import '../../data/providers.dart';
import '../../shared/ui/empty_state.dart';
import '../../shared/ui/loading_state.dart';
import '../dashboard/providers/dashboard_provider.dart';
import '../recurring/recurring_editor_sheet.dart';
import '../recurring/recurring_screen.dart' show upcomingOccurrences;
import 'subscriptions_logic.dart';

class _Data {
  final List<RecurringRule> subs;
  final Map<int, String> catName;
  _Data(this.subs, this.catName);
}

class SubscriptionsScreen extends ConsumerStatefulWidget {
  const SubscriptionsScreen({super.key});

  @override
  ConsumerState<SubscriptionsScreen> createState() => _SubscriptionsScreenState();
}

class _SubscriptionsScreenState extends ConsumerState<SubscriptionsScreen> {
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
    return _Data(
      rules.where((r) => r.isSubscription).toList(),
      {for (final c in cats) c.id: c.name},
    );
  }

  void _reload() => setState(() => _future = _load());

  Future<void> _scheduleFor(RecurringRule r) async {
    if (!r.isActive) return;
    final now = DateTime.now();
    final occ = upcomingOccurrences(r, now, now.add(const Duration(days: 366)));
    if (occ.isEmpty) return;
    final when = occ.first.subtract(Duration(days: r.reminderDaysBefore));
    try {
      await NotificationService.scheduleBillReminder(
        id: 2000 + r.id,
        when: when,
        title: 'Pago programado',
        body: '${r.label ?? 'Suscripción'} · ${r.type == TransactionType.expense ? 'Cargo' : 'Ingreso'}',
      );
    } catch (_) {}
  }

  Future<void> _editOrCreate(RecurringRule? rule) async {
    final ok = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      builder: (_) => RecurringEditorSheet(rule: rule, isSubscription: true),
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
    if (v) await _scheduleFor(r);
    ref.invalidate(dashboardProvider);
    _reload();
  }

  Future<void> _delete(RecurringRule r) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Borrar suscripción'),
        content: const Text('¿Eliminar esta suscripción?'),
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
      appBar: AppBar(title: const Text('Suscripciones')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _editOrCreate(null),
        icon: const Icon(Icons.add),
        label: const Text('Nueva suscripción'),
      ),
      body: FutureBuilder<_Data>(
        future: _future,
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const LoadingState();
          }
          final data = snap.data!;
          final monthly = subscriptionsMonthlyTotal(data.subs);
          final annual = subscriptionsAnnualTotal(data.subs);
          return ListView(
            padding: EdgeInsets.fromLTRB(
                app.spacing.md, app.spacing.sm, app.spacing.md, app.spacing.xxl),
            children: [
              Card(
                child: Padding(
                  padding: EdgeInsets.all(app.spacing.md),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _stat(app, 'Total mensual', MoneyFormat.format(monthly)),
                      _stat(app, 'Proyección anual', MoneyFormat.format(annual)),
                    ],
                  ),
                ),
              ),
              SizedBox(height: app.spacing.md),
              Text('SUSCRIPCIONES (${data.subs.length})',
                  style: TextStyle(
                      color: app.colors.textSecondary,
                      fontSize: 12,
                      letterSpacing: 1.5)),
              SizedBox(height: app.spacing.sm),
              if (data.subs.isEmpty)
                const EmptyState(
                  icon: Icons.subscriptions_outlined,
                  title: 'Sin suscripciones',
                  message: 'Agrega tus servicios recurrentes para ver su costo real.',
                )
              else
                for (final r in data.subs)
                  _SubCard(
                    rule: r,
                    categoryName: data.catName[r.categoryId] ?? 'Categoría',
                    onToggle: (v) => _toggle(r, v),
                    onEdit: () => _editOrCreate(r),
                    onDelete: () => _delete(r),
                  ),
            ],
          );
        },
      ),
    );
  }

  Widget _stat(AppTheme app, String label, String value) => Column(
        children: [
          Text(label.toUpperCase(),
              style: TextStyle(color: app.colors.textSecondary, fontSize: 10)),
          SizedBox(height: app.spacing.xxs),
          Text(value,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        ],
      );
}

class _SubCard extends StatelessWidget {
  final RecurringRule rule;
  final String categoryName;
  final ValueChanged<bool> onToggle;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _SubCard({
    required this.rule,
    required this.categoryName,
    required this.onToggle,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final app = context.app;
    final now = DateTime.now();
    final next = upcomingOccurrences(rule, now, now.add(const Duration(days: 366)));
    final freq = rule.frequency == RecurringFrequency.monthly ? 'Mensual' : 'Quincenal';
    final nextLabel =
        next.isEmpty ? 'Sin próxima' : '${next.first.day}/${next.first.month}/${next.first.year}';
    return Card(
      child: ListTile(
        onTap: onEdit,
        leading: Icon(Icons.subscriptions_outlined, color: app.colors.primary),
        title: Text(rule.label ?? categoryName,
            style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(
            '$categoryName · $freq · Próx: $nextLabel${rule.isActive ? '' : ' · PAUSADA'}',
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
