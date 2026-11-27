import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:noova_finance/theme/app_theme.dart';
import '../../shared/ui/error_state.dart';
import '../../shared/ui/loading_state.dart';
import '../../shared/widgets/noova_logo.dart';
import '../../shared/widgets/profile_greeting.dart';
import '../../core/utils/decimal_utils.dart';
import '../goals/goals_providers.dart';
import 'insights.dart';
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
        automaticallyImplyLeading: false,
        centerTitle: false,
        titleSpacing: 14,
        title: const NoovaLogoImage(),
        actions: [
          IconButton(
            tooltip: 'Ver análisis',
            icon: const Icon(Icons.insights_outlined),
            onPressed: () => context.push('/charts'),
          ),
          const ProfileGreeting(),
          const SizedBox(width: 12),
        ],
      ),
      body: AnimatedSwitcher(
        duration: AppMotion.medium,
        switchInCurve: AppMotion.standardDecelerate,
        switchOutCurve: AppMotion.standardAccelerate,
        child: dashboardAsync.when(
        loading: () => const LoadingState(),
        error: (e, _) => ErrorState(message: 'No pudimos cargar tu dashboard.', onRetry: () => ref.invalidate(dashboardProvider)),
        data: (d) {
          final spends = d.categorySpending; // all defined categories
          final maxTotal = spends.isEmpty || spends.first.total == Decimal.zero
              ? 0.0
              : spends.first.total.toDouble();

          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(dashboardProvider),
            child: ListView(
              padding: const EdgeInsets.only(bottom: 24),
              children: [
                SaldoCard(saldoFormatted: MoneyFormat.format(d.saldo)),
                UtilidadCard(
                  ingresos: MoneyFormat.compact(d.ingresosAnio),
                  gastos: MoneyFormat.compact(d.gastosAnio),
                  utilidad: MoneyFormat.compact(d.utilidadTotalAnio),
                  utilidadPositiva: d.utilidadTotalAnio >= Decimal.zero,
                ),
                _InsightsSection(insights: buildInsights(d)),
                if (d.globalBudget > Decimal.zero) _GlobalBudgetCard(data: d),
                const _GoalsSummary(),
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
            if (data.budgetAlerts.isNotEmpty) ...[
              const SizedBox(height: 6),
              for (final a in data.budgetAlerts)
                Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: Row(children: [
                    Icon(Icons.warning_amber_rounded,
                        size: 15,
                        color: a.exceeded
                            ? context.app.colors.expense
                            : context.app.colors.warning),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                          '${a.name}: ${a.percent}% (límite ${a.threshold}%)',
                          style: TextStyle(
                              fontSize: 11,
                              color: a.exceeded
                                  ? context.app.colors.expense
                                  : context.app.colors.warning)),
                    ),
                  ]),
                ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Horizontal-free list of insight cards shown under the budget card.
class _InsightsSection extends StatelessWidget {
  final List<Insight> insights;
  const _InsightsSection({required this.insights});

  @override
  Widget build(BuildContext context) {
    if (insights.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 8),
            child: Text('INSIGHTS',
                style: TextStyle(
                    color: context.app.colors.textSecondary,
                    fontSize: 12,
                    letterSpacing: 1.5)),
          ),
          for (final i in insights) _InsightCard(insight: i),
        ],
      ),
    );
  }
}

class _InsightCard extends StatelessWidget {
  final Insight insight;
  const _InsightCard({required this.insight});

  @override
  Widget build(BuildContext context) {
    final c = context.app.colors;
    final color = switch (insight.tone) {
      InsightTone.positive => c.income,
      InsightTone.negative => c.expense,
      InsightTone.warning => c.warning,
      InsightTone.neutral => c.primary,
    };
    final icon = switch (insight.tone) {
      InsightTone.positive => Icons.trending_up,
      InsightTone.negative => Icons.trending_down,
      InsightTone.warning => Icons.warning_amber_rounded,
      InsightTone.neutral => Icons.insights,
    };
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Icon(icon, color: color),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(insight.title,
                      style: const TextStyle(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 2),
                  Text(insight.subtitle,
                      style: TextStyle(fontSize: 12, color: c.textSecondary)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Compact savings-goals summary shown on the dashboard when goals exist.
class _GoalsSummary extends ConsumerWidget {
  const _GoalsSummary();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(savingsGoalsProvider);
    return async.maybeWhen(
      data: (goals) {
        if (goals.isEmpty) return const SizedBox.shrink();
        final c = context.app.colors;
        final totalTarget = goals.fold<int>(0, (a, g) => a + g.targetBps);
        final totalSaved = goals.fold<int>(0, (a, g) => a + g.savedBps);
        final pct = totalTarget <= 0
            ? 0.0
            : (totalSaved / totalTarget).clamp(0.0, 1.0).toDouble();
        final msgs = <String>[];
        for (final g in goals) {
          final gp = g.targetBps <= 0 ? 0.0 : (g.savedBps / g.targetBps * 100);
          if (gp >= 100) {
            msgs.add(g.savedBps > g.targetBps
                ? '${g.name}: meta superada (${gp.round()}%)'
                : '${g.name}: meta alcanzada (100%)');
          } else if (gp >= 75) {
            msgs.add('${g.name}: ${gp.round()}% (¡casi!)');
          } else if (gp >= 50) {
            msgs.add('${g.name}: ${gp.round()}%');
          }
        }
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(children: [
                      Icon(Icons.savings_outlined, size: 18, color: c.income),
                      const SizedBox(width: 6),
                      const Text('Metas de ahorro',
                          style: TextStyle(fontWeight: FontWeight.w600)),
                    ]),
                    Text('${(pct * 100).round()}%',
                        style: TextStyle(
                            color: c.textSecondary, fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                        '${MoneyFormat.format(DecimalUtils.fromBps(totalSaved))} de ${MoneyFormat.format(DecimalUtils.fromBps(totalTarget))}',
                        style: const TextStyle(fontSize: 13)),
                    Text('${goals.length} metas',
                        style:
                            TextStyle(fontSize: 11, color: c.textSecondary)),
                  ],
                ),
                const SizedBox(height: 8),
                AnimatedProgressBar(
                  value: pct,
                  minHeight: 8,
                  borderRadius: AppRadii.standard.brXs,
                  backgroundColor:
                      Theme.of(context).colorScheme.surfaceContainerHighest,
                  color: c.income,
                ),
                if (msgs.isNotEmpty) const SizedBox(height: 8),
                for (final m in msgs)
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Row(children: [
                      Icon(Icons.emoji_events_outlined, size: 15, color: c.primary),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(m,
                            style:
                                TextStyle(fontSize: 11, color: c.textSecondary)),
                      ),
                    ]),
                  ),
              ],
            ),
          ),
        );
      },
      orElse: () => const SizedBox.shrink(),
    );
  }
}
