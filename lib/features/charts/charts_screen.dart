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

String _monthLabel(DateTime d) => '${_monthNames[d.month - 1]} ${d.year}';

/// A selectable period: a single month or a whole year.
class _Period {
  final String key;
  final String label;
  final DateTime start;
  final DateTime end;
  const _Period(this.key, this.label, this.start, this.end);
}

class ChartsScreen extends ConsumerStatefulWidget {
  const ChartsScreen({super.key});

  @override
  ConsumerState<ChartsScreen> createState() => _ChartsScreenState();
}

class _ChartsScreenState extends ConsumerState<ChartsScreen> {
  String? _selectedKey;

  List<_Period> _periods(List<Transaction> txns) {
    final years = <int>{};
    final months = <String, DateTime>{};
    for (final t in txns) {
      years.add(t.date.year);
      final m = DateTime(t.date.year, t.date.month, 1);
      months['${m.year}-${m.month}'] = m;
    }
    final sortedYears = years.toList()..sort((a, b) => b.compareTo(a));
    final sortedMonths = months.values.toList()..sort((a, b) => b.compareTo(a));
    return [
      for (final y in sortedYears)
        _Period(
          'Y$y',
          'Año $y (completo)',
          DateTime(y, 1, 1),
          DateTime(y + 1, 1, 1).subtract(const Duration(microseconds: 1)),
        ),
      for (final m in sortedMonths)
        _Period(
          'M${m.year}-${m.month}',
          _monthLabel(m),
          DateTime(m.year, m.month, 1),
          DateTime(m.year, m.month + 1, 1)
              .subtract(const Duration(microseconds: 1)),
        ),
    ];
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
            final periods = _periods(txns);
            if (periods.isEmpty) {
              return const EmptyState(
                icon: Icons.bar_chart,
                title: 'Sin datos para graficar',
                message: 'Registra o importa transacciones para ver tus gráficos.',
              );
            }
            final selected = periods.firstWhere(
              (p) => p.key == _selectedKey,
              orElse: () => periods.first,
            );

            final byCat =
                SaldoCalculator.gastosPorCategoria(txns, selected.start, selected.end);
            final total =
                byCat.values.fold<Decimal>(Decimal.zero, (a, b) => a + b);
            final saldos = SaldoCalculator.saldoMensual(txns, DateTime.now(), 12);

            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _PeriodSelector(
                  periods: periods,
                  selectedKey: selected.key,
                  onChanged: (k) => setState(() => _selectedKey = k),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text('GASTOS POR CATEGORÍA · ${selected.label}',
                          style: TextStyle(
                              color: context.app.colors.textSecondary,
                              fontSize: 12,
                              letterSpacing: 1.2)),
                    ),
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

class _PeriodSelector extends StatelessWidget {
  final List<_Period> periods;
  final String selectedKey;
  final ValueChanged<String> onChanged;

  const _PeriodSelector(
      {required this.periods, required this.selectedKey, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        child: Row(
          children: [
            Icon(Icons.calendar_month, color: context.app.colors.primary),
            const SizedBox(width: 12),
            const Text('Periodo:', style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(width: 12),
            Expanded(
              child: DropdownButton<String>(
                isExpanded: true,
                value: selectedKey,
                underline: const SizedBox.shrink(),
                items: [
                  for (final p in periods)
                    DropdownMenuItem(value: p.key, child: Text(p.label)),
                ],
                onChanged: (k) {
                  if (k != null) onChanged(k);
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
              child: Center(child: Text('Sin gastos en el periodo'))));
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
                        value:
                            max == Decimal.zero ? 0 : (e.value / max).toDouble(),
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
