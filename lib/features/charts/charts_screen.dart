import 'package:decimal/decimal.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:noova_finance/theme/app_theme.dart';
import '../../core/utils/money_format.dart';
import '../../data/models/transaction.dart';
import '../../data/providers.dart';
import '../../data/services/saldo_calculator.dart';
import '../../shared/ui/empty_state.dart';
import '../../shared/ui/error_state.dart';
import '../../shared/ui/loading_state.dart';
import '../../shared/widgets/animated_progress_bar.dart';
import '../../shared/widgets/main_nav_bar.dart';
import '../../theme/app_radii.dart';

const _monthNames = ['Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun', 'Jul', 'Ago', 'Sep', 'Oct', 'Nov', 'Dic'];

String _label(DateTime d) => '${_monthNames[d.month - 1]} ${d.year}';

/// Charts: expenses-by-category for a selected month + saldo line chart (US6).
class ChartsScreen extends ConsumerStatefulWidget {
  const ChartsScreen({super.key});

  @override
  ConsumerState<ChartsScreen> createState() => _ChartsScreenState();
}

class _ChartsScreenState extends ConsumerState<ChartsScreen> {
  DateTime? _selected;

  List<DateTime> _monthsWithData(List<Transaction> txns) {
    final set = <String, DateTime>{};
    for (final t in txns) {
      final d = DateTime(t.date.year, t.date.month, 1);
      set['${d.year}-${d.month}'] = d;
    }
    final list = set.values.toList()..sort((a, b) => b.compareTo(a));
    return list;
  }

  @override
  Widget build(BuildContext context) {
    final txnsAsync = ref.watch(transactionRepoProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Gráficos')),
      body: txnsAsync.when(
        loading: () => const LoadingState(),
        error: (e, _) => ErrorState(
            message: 'No pudimos cargar los gráficos.',
            onRetry: () => ref.invalidate(transactionRepoProvider)),
        data: (repo) => FutureBuilder<List<Transaction>>(
          future: repo.getAll(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const LoadingState();
            }
            final txns = snapshot.data ?? [];
            final months = _monthsWithData(txns);
            if (months.isEmpty) {
              return const EmptyState(
                icon: Icons.bar_chart,
                title: 'Sin datos para graficar',
                message: 'Registra o importa transacciones para ver tus gráficos.',
              );
            }
            final selected = (_selected != null &&
                    months.any((m) =>
                        m.year == _selected!.year && m.month == _selected!.month))
                ? _selected!
                : months.first;

            final start = DateTime(selected.year, selected.month, 1);
            final end = DateTime(selected.year, selected.month + 1, 1)
                .subtract(const Duration(microseconds: 1));
            final byCat = SaldoCalculator.gastosPorCategoria(txns, start, end);
            final total = byCat.values.fold<Decimal>(Decimal.zero, (a, b) => a + b);
            final saldos = SaldoCalculator.saldoMensual(txns, DateTime.now(), 12);

            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _MonthSelector(
                  months: months,
                  selected: selected,
                  onChanged: (m) => setState(() => _selected = m),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('GASTOS POR CATEGORÍA',
                        style: TextStyle(
                            color: context.app.colors.textSecondary,
                            fontSize: 12,
                            letterSpacing: 1.5)),
                    Text('Total: ${MoneyFormat.format(total)}',
                        style: const TextStyle(
                            fontSize: 13, fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(height: 12),
                _ExpenseBarChart(byCategory: byCat),
                const SizedBox(height: 32),
                Text('SALDO MENSUAL (12 MESES)',
                    style: TextStyle(
                        color: context.app.colors.textSecondary,
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

class _MonthSelector extends StatelessWidget {
  final List<DateTime> months;
  final DateTime selected;
  final ValueChanged<DateTime> onChanged;

  const _MonthSelector(
      {required this.months, required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        child: Row(
          children: [
            Icon(Icons.calendar_month, color: context.app.colors.primary),
            const SizedBox(width: 12),
            const Text('Mes:', style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(width: 12),
            Expanded(
              child: DropdownButton<DateTime>(
                isExpanded: true,
                value: selected,
                underline: const SizedBox.shrink(),
                items: [
                  for (final m in months)
                    DropdownMenuItem(value: m, child: Text(_label(m))),
                ],
                onChanged: (m) {
                  if (m != null) onChanged(m);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ExpenseBarChart extends ConsumerWidget {
  final Map<int, Decimal> byCategory;
  const _ExpenseBarChart({required this.byCategory});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (byCategory.isEmpty) {
      return const Card(
          child: Padding(
              padding: EdgeInsets.all(24),
              child: Center(child: Text('Sin gastos este mes'))));
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
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(s.data ?? '...',
                                style: const TextStyle(fontSize: 13)),
                          ),
                          Text(MoneyFormat.format(e.value),
                              style: const TextStyle(
                                  fontSize: 13, fontWeight: FontWeight.bold)),
                        ],
                      ),
                      const SizedBox(height: 4),
                      AnimatedProgressBar(
                        value: max == Decimal.zero
                            ? 0
                            : (e.value / max).toDouble(),
                        minHeight: 6,
                        borderRadius: AppRadii.standard.brXs,
                        backgroundColor:
                            Theme.of(context).colorScheme.surfaceContainerHighest,
                        color: context.app.colors.expense,
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
      return const Card(
          child: Padding(
              padding: EdgeInsets.all(24), child: Center(child: Text('Sin datos'))));
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
                leftTitles:
                    const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                topTitles:
                    const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                rightTitles:
                    const AxisTitles(sideTitles: SideTitles(showTitles: false)),
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
                  color: context.app.colors.primary,
                  barWidth: 2.5,
                  dotData: const FlDotData(show: false),
                  belowBarData: BarAreaData(
                    show: true,
                    color: context.app.colors.primary.withValues(alpha: 0.1),
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
