import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:noova_finance/theme/app_theme.dart';
import '../../core/utils/decimal_utils.dart';
import '../../core/utils/money_format.dart';
import '../../data/models/savings_contribution.dart';
import '../../data/models/savings_goal.dart';
import '../../data/providers.dart';
import '../../shared/ui/empty_state.dart';
import '../../shared/ui/error_state.dart';
import '../../shared/ui/loading_state.dart';
import '../../shared/widgets/animated_progress_bar.dart';
import '../../theme/app_radii.dart';
import 'goals_providers.dart';

class GoalsScreen extends ConsumerWidget {
  const GoalsScreen({super.key});

  Future<SavingsGoal?> _dialog(BuildContext context, {SavingsGoal? goal}) async {
    final nameCtrl = TextEditingController(text: goal?.name ?? '');
    final targetCtrl = TextEditingController(
        text: goal != null ? DecimalUtils.fromBps(goal.targetBps).toString() : '');
    final monthsCtrl = TextEditingController(
        text: (goal?.periodMonths ?? 0) > 0 ? goal!.periodMonths.toString() : '');
    final saved = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(goal == null ? 'Nueva meta' : 'Editar meta'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
                controller: nameCtrl,
                decoration: const InputDecoration(
                    labelText: 'Nombre (ej. Viaje, Fondo de emergencia)')),
            const SizedBox(height: 8),
            TextField(
                controller: targetCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Monto objetivo')),
            const SizedBox(height: 8),
            TextField(
                controller: monthsCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                    labelText: 'Periodo en meses (opcional)')),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancelar')),
          FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: Text(goal == null ? 'Crear' : 'Guardar')),
        ],
      ),
    );
    if (saved != true) return null;
    final target = DecimalUtils.tryParse(targetCtrl.text);
    final name = nameCtrl.text.trim();
    if (target == null || target <= Decimal.zero || name.isEmpty) return null;
    final months = int.tryParse(monthsCtrl.text.trim()) ?? 0;
    return SavingsGoal(
      name: name,
      targetBps: DecimalUtils.toBps(target),
      savedBps: goal?.savedBps ?? 0,
      periodMonths: months,
    );
  }

  Future<void> _create(BuildContext context, WidgetRef ref) async {
    final g = await _dialog(context);
    if (g == null) return;
    final repo = await ref.read(savingsGoalRepoProvider.future);
    await repo.insert(g);
    ref.invalidate(savingsGoalsProvider);
  }

  Future<void> _edit(BuildContext context, WidgetRef ref, SavingsGoal goal) async {
    final updated = await _dialog(context, goal: goal);
    if (updated == null) return;
    final repo = await ref.read(savingsGoalRepoProvider.future);
    goal
      ..name = updated.name
      ..targetBps = updated.targetBps
      ..periodMonths = updated.periodMonths;
    await repo.update(goal);
    ref.invalidate(savingsGoalsProvider);
  }

  Future<void> _delete(BuildContext context, WidgetRef ref, SavingsGoal goal) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eliminar meta'),
        content: Text('¿Eliminar "${goal.name}"?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancelar')),
          FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              style:
                  FilledButton.styleFrom(backgroundColor: context.app.colors.expense),
              child: const Text('Eliminar')),
        ],
      ),
    );
    if (ok != true) return;
    final repo = await ref.read(savingsGoalRepoProvider.future);
    await repo.delete(goal.id);
    ref.invalidate(savingsGoalsProvider);
  }

  Future<void> _contribute(BuildContext context, WidgetRef ref, SavingsGoal g) async {
    final ctrl = TextEditingController();
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Aportar a ${g.name}'),
        content: TextField(
            controller: ctrl,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'Monto a aportar')),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancelar')),
          FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Aportar')),
        ],
      ),
    );
    if (ok != true) return;
    final amount = DecimalUtils.tryParse(ctrl.text);
    if (amount == null || amount <= Decimal.zero) return;
    final repo = await ref.read(savingsGoalRepoProvider.future);
    await repo.addContribution(g.id, DecimalUtils.toBps(amount));
    ref.invalidate(savingsGoalsProvider);
  }

  Future<void> _showContributions(
      BuildContext context, WidgetRef ref, SavingsGoal g) async {
    final repo = await ref.read(savingsGoalRepoProvider.future);
    if (!context.mounted) return;
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => FutureBuilder<List<SavingsContribution>>(
        future: repo.getContributions(g.id),
        builder: (ctx, snap) {
          final list = snap.data ?? [];
          return DraggableScrollableSheet(
            expand: false,
            initialChildSize: 0.5,
            maxChildSize: 0.9,
            builder: (ctx, controller) => ListView(
              controller: controller,
              padding: const EdgeInsets.all(20),
              children: [
                Text('Aportes a ${g.name}',
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                if (list.isEmpty)
                  const Padding(
                      padding: EdgeInsets.all(24),
                      child: Center(child: Text('Aún no hay aportes')))
                else
                  for (final c in list)
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Icon(Icons.savings_outlined,
                          color: context.app.colors.income),
                      title: Text(MoneyFormat.format(DecimalUtils.fromBps(c.amountBps))),
                      subtitle: Text(
                          '${c.date.day}/${c.date.month}/${c.date.year}'),
                      trailing: IconButton(
                        tooltip: 'Eliminar aporte',
                        icon: Icon(Icons.delete_outline,
                            color: context.app.colors.expense),
                        onPressed: () async {
                          await repo.deleteContribution(g.id, c);
                          ref.invalidate(savingsGoalsProvider);
                          if (ctx.mounted) Navigator.pop(ctx);
                        },
                      ),
                    ),
              ],
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(savingsGoalsProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Metas de ahorro'),
        leading: IconButton(
          icon: const Icon(Icons.home_outlined),
          tooltip: 'Inicio',
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/dashboard');
            }
          },
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _create(context, ref),
        icon: const Icon(Icons.add),
        label: const Text('Nueva meta'),
      ),
      body: async.when(
        loading: () => const LoadingState(),
        error: (e, _) => ErrorState(
            message: 'No pudimos cargar tus metas.',
            onRetry: () => ref.invalidate(savingsGoalsProvider)),
        data: (goals) {
          if (goals.isEmpty) {
            return EmptyState(
              icon: Icons.savings_outlined,
              title: 'Aún no tienes metas',
              message: 'Crea tu primera meta de ahorro para empezar a apartar dinero.',
              actionLabel: 'Crear meta',
              onAction: () => _create(context, ref),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
            itemCount: goals.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, i) {
              final g = goals[i];
              return _GoalCard(
                goal: g,
                onContribute: () => _contribute(context, ref, g),
                onShowContributions: () => _showContributions(context, ref, g),
                onEdit: () => _edit(context, ref, g),
                onDelete: () => _delete(context, ref, g),
              );
            },
          );
        },
      ),
    );
  }
}

class _GoalCard extends StatelessWidget {
  final SavingsGoal goal;
  final VoidCallback onContribute;
  final VoidCallback onShowContributions;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _GoalCard({
    required this.goal,
    required this.onContribute,
    required this.onShowContributions,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.app.colors;
    final target = DecimalUtils.fromBps(goal.targetBps);
    final saved = DecimalUtils.fromBps(goal.savedBps);
    final pct = goal.targetBps <= 0
        ? 0.0
        : (goal.savedBps / goal.targetBps).clamp(0.0, 1.0).toDouble();
    final done = goal.targetBps > 0 && goal.savedBps >= goal.targetBps;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(done ? Icons.check_circle : Icons.savings_outlined,
                    color: done ? c.income : c.primary),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(goal.name,
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w600)),
                ),
                Text('${(pct * 100).round()}%',
                    style: TextStyle(
                        color: c.textSecondary, fontWeight: FontWeight.bold)),
                PopupMenuButton<String>(
                  onSelected: (v) {
                    if (v == 'edit') onEdit();
                    if (v == 'delete') onDelete();
                  },
                  itemBuilder: (_) => const [
                    PopupMenuItem(value: 'edit', child: Text('Editar')),
                    PopupMenuItem(value: 'delete', child: Text('Eliminar')),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),
            AnimatedProgressBar(
                value: pct,
                minHeight: 8,
                borderRadius: AppRadii.standard.brXs,
                color: done ? c.income : c.primary),
            const SizedBox(height: 8),
            Text('${MoneyFormat.format(saved)} de ${MoneyFormat.format(target)}',
                style: TextStyle(fontSize: 12, color: c.textSecondary)),
            if (goal.periodMonths > 0)
              Text(
                  'Aporte: ${MoneyFormat.format(DecimalUtils.fromBps(goal.targetBps ~/ goal.periodMonths))}/mes · ${goal.periodMonths} meses',
                  style: TextStyle(fontSize: 11, color: c.textSecondary)),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton.icon(
                    onPressed: onShowContributions,
                    icon: const Icon(Icons.receipt_long, size: 16),
                    label: const Text('Aportes')),
                TextButton.icon(
                    onPressed: onContribute,
                    icon: const Icon(Icons.add, size: 16),
                    label: const Text('Aportar')),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
