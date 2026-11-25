import 'package:decimal/decimal.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme.dart';
import '../../shared/widgets/main_nav_bar.dart';
import '../../core/utils/date_utils.dart';
import '../../core/utils/money_format.dart';
import '../../data/models/transaction.dart';
import '../../data/providers.dart';
import '../../data/services/saldo_calculator.dart';

/// Charts: expense bar chart + saldo line chart (US6).
class ChartsScreen extends ConsumerWidget {
  const ChartsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final txnsAsync = ref.watch(transactionRepoProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Graficos')),
      body: txnsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (repo) => FutureBuilder<List<Transaction>>(
          future: repo.getAll(),
          builder: (context, snapshot) {
            final txns = snapshot.data ?? [];
            final now = DateTime.now();
            final monthStart = QuincenaUtils.monthStart(now);
            final monthEnd = QuincenaUtils.monthEnd(now);
            final byCat = SaldoCalculator.gastosPorCategoria(txns, monthStart, monthEnd);
            final saldos = SaldoCalculator.saldoMensual(txns, now, 12);

            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                const Text('GASTOS POR CATEGORIA (MES)',
                    style: TextStyle(
                        color: NoovaTheme.textSecondary,
                        fontSize: 12,
                        letterSpacing: 1.5)),
                const SizedBox(height: 12),
                _ExpenseBarChart(byCategory: byCat),
                const SizedBox(height: 32),
                const Text('SALDO MENSUAL (12 MESES)',
                    style: TextStyle(
                        color: NoovaTheme.textSecondary,
                        fontSize: 12,
                        letterSpacing: 1.5)),
                const SizedBox(height: 12),
                _SaldoLineChart(saldos: saldos),
              ],
            );
          },
        ),
      ),
      bottomNavigationBar: const MainNavBar(location: '/charts'),
    );
  }
}

class _ExpenseBarChart extends ConsumerWidget {
  final Map<int, Decimal> byCategory;
  const _ExpenseBarChart({required this.byCategory});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (byCategory.isEmpty) {
      return const Card(child: Padding(padding: EdgeInsets.all(24), child: Center(child: Text('Sin gastos este mes'))));
    }
    final entries = byCategory.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final max = entries.first.value;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            for (final e in entries)
              FutureBuilder<String>(
                future: _name(ref, e.key),
                builder: (c, s) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(s.data ?? '...',
                              style: const TextStyle(fontSize: 13)),
                          Text(MoneyFormat.format(e.value),
                              style: const TextStyle(
                                  fontSize: 13, fontWeight: FontWeight.bold)),
                        ],
                      ),
                      const SizedBox(height: 4),
                      LinearProgressIndicator(
                        value: max == Decimal.zero
                            ? 0
                            : (e.value / max).toDouble(),
                        backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                        color: NoovaTheme.expense,
                        minHeight: 6,
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Future<String> _name(WidgetRef ref, int id) async {
    final repo = await ref.read(categoryRepoProvider.future);
    return (await repo.getById(id))?.name ?? '...';
  }
}

class _SaldoLineChart extends StatelessWidget {
  final List<Decimal> saldos;
  const _SaldoLineChart({required this.saldos});

  @override
  Widget build(BuildContext context) {
    if (saldos.isEmpty) {
      return const Card(child: Padding(padding: EdgeInsets.all(24), child: Center(child: Text('Sin datos'))));
    }
    final spots = <FlSpot>[
      for (var i = 0; i < saldos.length; i++)
        FlSpot(i.toDouble(), saldos[i].toDouble()),
    ];
    final values = saldos.map((d) => d.toDouble()).toList();
    final minY = values.reduce((a, b) => a < b ? a : b);
    final maxY = values.reduce((a, b) => a > b ? a : b);
    final range = maxY - minY;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: SizedBox(
          height: 220,
          child: LineChart(
            LineChartData(
              minY: minY - range * 0.1,
              maxY: maxY + range * 0.1,
              gridData: FlGridData(
                show: true,
                drawVerticalLine: false,
                horizontalInterval: range / 5,
                getDrawingHorizontalLine: (v) =>
                    FlLine(color: Theme.of(context).dividerColor, strokeWidth: 1),
              ),
              titlesData: FlTitlesData(
                leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 28,
                    interval: 3,
                    getTitlesWidget: (v, _) => Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Text('M${v.toInt() + 1}',
                          style: const TextStyle(fontSize: 10)),
                    ),
                  ),
                ),
              ),
              lineBarsData: [
                LineChartBarData(
                  spots: spots,
                  isCurved: true,
                  color: NoovaTheme.accent,
                  barWidth: 2.5,
                  dotData: const FlDotData(show: false),
                  belowBarData: BarAreaData(
                    show: true,
                    color: NoovaTheme.accent.withValues(alpha: 0.1),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
