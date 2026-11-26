import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/utils/decimal_utils.dart';
import '../../core/utils/money_format.dart';
import '../../data/models/savings_goal.dart';
import '../../data/providers.dart';
import 'goals_providers.dart';
import '../../shared/ui/empty_state.dart';
import '../../shared/ui/error_state.dart';
import '../../shared/ui/loading_state.dart';
import '../../shared/widgets/animated_progress_bar.dart';
import '../../theme/app_radii.dart';
import '../../theme/app_theme.dart';

class GoalsScreen extends ConsumerWidget {
  const GoalsScreen({super.key});

  Future<void> _create(BuildContext context, WidgetRef ref) async {
    final nameCtrl = TextEditingController();
    final targetCtrl = TextEditingController();
    final monthsCtrl = TextEditingController();
    final created = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Nueva meta'),
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
              child: const Text('Crear')),
        ],
      ),
    );
    if (created != true) return;
    final target = DecimalUtils.tryParse(targetCtrl.text);
    final name = nameCtrl.text.trim();
    if (target == null || target <= Decimal.zero || name.isEmpty) return;
    final repo = await ref.read(savingsGoalRepoProvider.future);
    final months = int.tryParse(monthsCtrl.text.trim()) ?? 0;
    await repo.insert(SavingsGoal(
        name: name,
        targetBps: DecimalUtils.toBps(target),
        periodMonths: months));
    ref.invalidate(savingsGoalsProvider);
  }

  Future<void> _contribute(
      BuildContext context, WidgetRef ref, SavingsGoal g) async {
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

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(savingsGoalsProvider);
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/dashboard');
            }
          },
        ),
        title: const Text('Metas de ahorro'),
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
              message:
                  'Crea tu primera meta de ahorro para empezar a apartar dinero.',
              actionLabel: 'Crear meta',
              onAction: () => _create(context, ref),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
            itemCount: goals.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, i) => _GoalCard(
                goal: goals[i], onContribute: () => _contribute(context, ref, goals[i])),
          );
        },
      ),
    );
  }
}

class _GoalCard extends StatelessWidget {
  final SavingsGoal goal;
  final VoidCallback onContribute;

  const _GoalCard({required this.goal, required this.onContribute});

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
                            fontSize: 16, fontWeight: FontWeight.w600))),
                Text('${(pct * 100).round()}%',
                    style: TextStyle(
                        color: c.textSecondary, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 12),
            AnimatedProgressBar(
                value: pct,
                minHeight: 8,
                borderRadius: AppRadii.standard.brXs,
                color: done ? c.income : c.primary),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('${MoneyFormat.format(saved)} de ${MoneyFormat.format(target)}',
                        style: TextStyle(fontSize: 12, color: c.textSecondary)),
                    if (goal.periodMonths > 0)
                      Text(
                          'Aporte: ${MoneyFormat.format(DecimalUtils.fromBps(goal.targetBps ~/ goal.periodMonths))}/mes · ${goal.periodMonths} meses',
                          style: TextStyle(fontSize: 11, color: c.textSecondary)),
                  ],
                ),
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
