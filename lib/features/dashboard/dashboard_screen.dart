import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:noova_finance/theme/app_theme.dart';
import '../../core/utils/money_format.dart';
import '../../shared/widgets/main_nav_bar.dart';
import 'providers/dashboard_provider.dart';
import 'widgets/category_dashboard_card.dart';
import 'widgets/saldo_card.dart';
import 'widgets/utilidad_card.dart';
import '../../shared/widgets/animated_progress_bar.dart';
import '../../theme/app_motion.dart';
import '../../theme/app_radii.dart';

/// Home: dynamic finance dashboard — saldo, monthly summary, global budget,
/// and per-category dashboards (bars sorted by spending).
class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashboardAsync = ref.watch(dashboardProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Noova Finance'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => context.go('/settings'),
          ),
        ],
      ),
      body: AnimatedSwitcher(
        duration: AppMotion.medium,
        switchInCurve: AppMotion.standardDecelerate,
        switchOutCurve: AppMotion.standardAccelerate,
        child: dashboardAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (d) {
          final spends = d.categorySpending
              .where((s) => s.total > Decimal.zero)
              .toList();
          final maxTotal = spends.isEmpty ? 0.0 : spends.first.total.toDouble();

          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(dashboardProvider),
            child: ListView(
              padding: const EdgeInsets.only(bottom: 24),
              children: [
                SaldoCard(saldoFormatted: MoneyFormat.format(d.saldo)),
                UtilidadCard(
                  ingresos: MoneyFormat.compact(d.ingresosMes),
                  gastos: MoneyFormat.compact(d.gastosMes),
                  utilidad: MoneyFormat.compact(d.utilidadMes),
                  utilidadPositiva: d.utilidadMes >= Decimal.zero,
                ),
                if (d.globalBudget > Decimal.zero) _GlobalBudgetCard(data: d),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('GASTOS POR CATEGORÍA',
                          style: TextStyle(
                              color: context.app.colors.textSecondary,
                              fontSize: 12,
                              letterSpacing: 1.5)),
                      Text('Toca una categoría para ver el detalle',
                          style: TextStyle(
                              color: context.app.colors.textSecondary, fontSize: 10)),
                    ],
                  ),
                ),
                if (spends.isEmpty)
                  const Padding(
                    padding: EdgeInsets.all(24),
                    child: Card(
                      child: Padding(
                        padding: EdgeInsets.all(24),
                        child: Center(
                          child: Text(
                              'Aún no hay gastos esta quincena.'),
                        ),
                      ),
                    ),
                  )
                else
                  for (final s in spends)
                    CategoryDashboardCard(spend: s, maxTotal: maxTotal),
              ],
            ),
          );
        },
      ),
      ),
      bottomNavigationBar: const MainNavBar(location: '/dashboard'),
    );
  }
}

class _GlobalBudgetCard extends StatelessWidget {
  final DashboardData data;
  const _GlobalBudgetCard({required this.data});

  @override
  Widget build(BuildContext context) {
    final pct = data.globalBudget == Decimal.zero
        ? 0
        : (data.globalSpent.shift(4).toBigInt().toInt() * 100) ~/
            data.globalBudget.shift(4).toBigInt().toInt();
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Presupuesto global',
                    style: TextStyle(fontWeight: FontWeight.w600)),
                Text(
                  '${MoneyFormat.format(data.globalSpent)} / ${MoneyFormat.format(data.globalBudget)}',
                  style: const TextStyle(fontSize: 13),
                ),
              ],
            ),
            const SizedBox(height: 8),
            AnimatedProgressBar(
              value: (pct / 100).clamp(0.0, 1.0),
              minHeight: 8,
              borderRadius: AppRadii.standard.brXs,
              backgroundColor:
                  Theme.of(context).colorScheme.surfaceContainerHighest,
              color: pct >= 100
                  ? context.app.colors.expense
                  : pct >= 80
                      ? context.app.colors.warning
                      : context.app.colors.primary,
            ),
            const SizedBox(height: 4),
            Text('$pct% del presupuesto usado',
                style: TextStyle(
                    fontSize: 11, color: context.app.colors.textSecondary)),
          ],
        ),
      ),
    );
  }
}
