import 'dart:math' as math;

import 'package:decimal/decimal.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:noova_finance/theme/app_theme.dart';
import '../../theme/app_colors.dart';
import '../../core/utils/date_utils.dart';
import '../../core/utils/decimal_utils.dart';
import '../../core/utils/money_format.dart';
import '../../data/models/category.dart';
import '../../data/models/transaction.dart';
import '../../data/providers.dart';
import '../../data/services/saldo_calculator.dart';
import '../../shared/ui/empty_state.dart';
import '../../shared/ui/error_state.dart';
import '../../shared/ui/loading_state.dart';
import '../../shared/widgets/period_selector.dart';
import 'comparatives.dart';

class _Data {
  final List<Transaction> txns;
  final Map<int, Category> categories;
  _Data(this.txns, this.categories);
}

class _Slice {
  final String name;
  final Decimal amount;
  final Color color;
  const _Slice(this.name, this.amount, this.color);
}

const _monthAbbr = [
  'Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun',
  'Jul', 'Ago', 'Sep', 'Oct', 'Nov', 'Dic'
];

class ChartsScreen extends ConsumerStatefulWidget {
  const ChartsScreen({super.key});

  @override
  ConsumerState<ChartsScreen> createState() => _ChartsScreenState();
}

class _ChartsScreenState extends ConsumerState<ChartsScreen> {
  PeriodView _view = PeriodView.mes;
  DateTime _anchor = DateTime.now();

  Future<_Data> _load() async {
    final txnRepo = await ref.read(transactionRepoProvider.future);
    final catRepo = await ref.read(categoryRepoProvider.future);
    final txns = await txnRepo.getAll();
    final cats = await catRepo.getAll();
    return _Data(txns, {for (final c in cats) c.id: c});
  }

  void _shift(int d) {
    setState(() {
      if (_view == PeriodView.quincena) {
        if (d > 0) {
          _anchor = _anchor.day <= 15
              ? DateTime(_anchor.year, _anchor.month, 16)
              : DateTime(_anchor.year, _anchor.month + 1, 1);
        } else {
          _anchor = _anchor.day <= 15
              ? DateTime(_anchor.year, _anchor.month - 1, 16)
              : DateTime(_anchor.year, _anchor.month, 1);
        }
      } else if (_view == PeriodView.mes) {
        _anchor = DateTime(_anchor.year, _anchor.month + d, 1);
      } else {
        _anchor = DateTime(_anchor.year + d, 1, 1);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Análisis')),
      body: FutureBuilder<_Data>(
        future: _load(),
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const LoadingState();
          }
          if (snap.hasError) {
            return ErrorState(
              message: 'No pudimos cargar el análisis.',
              onRetry: () => setState(() {}),
            );
          }
          final data = snap.data!;
          final range = _view.range(_anchor);
          return ListView(
            padding: EdgeInsets.symmetric(
              horizontal: context.app.spacing.md,
              vertical: context.app.spacing.sm,
            ),
            children: [
              PeriodSelector(
                view: _view,
                anchor: _anchor,
                onViewChanged: (v) => setState(() => _view = v),
                onShift: _shift,
              ),
              SizedBox(height: context.app.spacing.md),
              _DonutCard(data: data, start: range.$1, end: range.$2),
              SizedBox(height: context.app.spacing.md),
              _SaldoLineCard(data: data, anchor: _anchor),
              SizedBox(height: context.app.spacing.md),
              _BarsCard(data: data, anchor: _anchor),
              SizedBox(height: context.app.spacing.md),
              _ComparativesCard(data: data, view: _view, anchor: _anchor),
              SizedBox(height: context.app.spacing.lg),
            ],
          );
        },
      ),
    );
  }
}

class _ChartCard extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget body;
  final Widget? legend;

  const _ChartCard({
    required this.title,
    required this.body,
    this.subtitle,
    this.legend,
  });

  @override
  Widget build(BuildContext context) {
    final app = context.app;
    return Card(
      child: Padding(
        padding: EdgeInsets.all(app.spacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
            if (subtitle != null) ...[
              SizedBox(height: app.spacing.xxs),
              Text(subtitle!,
                  style: TextStyle(
                      fontSize: 12, color: app.colors.textSecondary)),
            ],
            SizedBox(height: app.spacing.md),
            body,
            if (legend != null) ...[
              SizedBox(height: app.spacing.md),
              legend!,
            ],
          ],
        ),
      ),
    );
  }
}

// ── Donut: gastos por categoría principal ───────────────────────────────────
class _DonutCard extends StatelessWidget {
  final _Data data;
  final DateTime start;
  final DateTime end;

  const _DonutCard({required this.data, required this.start, required this.end});

  List<_Slice> _slices(AppColors colors) {
    final palette = [colors.primary, colors.income, colors.expense, colors.warning,
        colors.secondary, colors.hero];
    final byLeaf = SaldoCalculator.gastosPorCategoria(data.txns, start, end);
    final principals = data.categories.values
        .where((c) =>
            c.isGroup &&
            c.parentId == null &&
            c.isActive &&
            c.type == TransactionType.expense)
        .toList();
    final totals = <Category, Decimal>{};
    for (final p in principals) {
      var total = byLeaf[p.id] ?? Decimal.zero;
      for (final ch in data.categories.values.where((c) => c.parentId == p.id)) {
        total += byLeaf[ch.id] ?? Decimal.zero;
      }
      if (total > Decimal.zero) totals[p] = total;
    }
    final entries = totals.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final top = entries.take(6).toList();
    final rest = entries.skip(6).map((e) => e.value).fold<Decimal>(
        Decimal.zero, (a, b) => a + b);
    final slices = <_Slice>[];
    for (var i = 0; i < top.length; i++) {
      slices.add(_Slice(top[i].key.name, top[i].value, palette[i % palette.length]));
    }
    if (rest > Decimal.zero) {
      slices.add(_Slice('Otros', rest, colors.textSecondary));
    }
    return slices;
  }

  @override
  Widget build(BuildContext context) {
    final app = context.app;
    final slices = _slices(app.colors);
    final total = slices.fold<Decimal>(Decimal.zero, (a, s) => a + s.amount);
    if (slices.isEmpty || total == Decimal.zero) {
      return _ChartCard(
        title: 'Gastos por categoría',
        body: const EmptyState(
          icon: Icons.donut_large_outlined,
          title: 'Sin gastos',
          message: 'No hay gastos registrados en este periodo.',
        ),
      );
    }
    return _ChartCard(
      title: 'Gastos por categoría',
      subtitle: _viewLabel(),
      body: SizedBox(
        height: 220,
        child: Semantics(
          label: 'Gráfico de dona de gastos por categoría',
          child: PieChart(
            PieChartData(
              sectionsSpace: 2,
              centerSpaceRadius: 46,
              sections: [
                for (final s in slices)
                  PieChartSectionData(
                    value: s.amount.toDouble(),
                    color: s.color,
                    radius: 58,
                    showTitle: (s.amount.toDouble() / total.toDouble()) > 0.07,
                    title: '${(s.amount.toDouble() / total.toDouble() * 100).toStringAsFixed(0)}%',
                    titleStyle: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: app.colors.onHero,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
      legend: Column(
        children: [
          for (final s in slices)
            Padding(
              padding: EdgeInsets.symmetric(vertical: app.spacing.xxs),
              child: Row(
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                        color: s.color, borderRadius: app.radii.brXs),
                  ),
                  SizedBox(width: app.spacing.sm),
                  Expanded(child: Text(s.name, style: const TextStyle(fontSize: 13))),
                  Text('${MoneyFormat.format(s.amount)}  ·  '
                      '${(s.amount.toDouble() / total.toDouble() * 100).toStringAsFixed(0)}%',
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                ],
              ),
            ),
        ],
      ),
    );
  }

  String _viewLabel() {
    return '${start.day}/${start.month} – ${end.day}/${end.month}/${end.year}';
  }
}

// ── Line: saldo acumulado últimos 12 meses ─────────────────────────────────
class _SaldoLineCard extends StatelessWidget {
  final _Data data;
  final DateTime anchor;

  const _SaldoLineCard({required this.data, required this.anchor});

  @override
  Widget build(BuildContext context) {
    final app = context.app;
    final ends = QuincenaUtils.lastMonthEnds(anchor, 12);
    final series = SaldoCalculator.saldoMensual(data.txns, anchor, 12);
    final values = series.map((d) => d.toDouble()).toList();
    final spots = [
      for (var i = 0; i < values.length; i++) FlSpot(i.toDouble(), values[i])
    ];
    final minV = values.reduce(math.min);
    final maxV = values.reduce(math.max);
    final span = (maxV - minV).abs() < 1 ? 1.0 : (maxV - minV);
    final minY = minV - span * 0.1;
    final maxY = maxV + span * 0.1;

    return _ChartCard(
      title: 'Saldo acumulado',
      subtitle: 'Últimos 12 meses',
      body: SizedBox(
        height: 210,
        child: Semantics(
          label: 'Gráfico de línea del saldo acumulado',
          child: LineChart(
            LineChartData(
              minX: 0,
              maxX: 11,
              minY: minY,
              maxY: maxY,
              borderData: FlBorderData(show: false),
              gridData: FlGridData(
                show: true,
                drawVerticalLine: false,
                horizontalInterval: span / 4 == 0 ? 1 : span / 4,
                getDrawingHorizontalLine: (v) =>
                    FlLine(color: app.colors.divider, strokeWidth: 1),
              ),
              titlesData: FlTitlesData(
                topTitles:
                    AxisTitles(sideTitles: SideTitles(showTitles: false)),
                rightTitles:
                    AxisTitles(sideTitles: SideTitles(showTitles: false)),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 48,
                    getTitlesWidget: (v, meta) => Text(
                      MoneyFormat.compact(DecimalUtils.fromDouble(v)),
                      style: TextStyle(
                          fontSize: 10, color: app.colors.textSecondary),
                    ),
                  ),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 24,
                    interval: 1,
                    getTitlesWidget: (v, meta) {
                      final i = v.round();
                      if (i >= 0 && i < ends.length) {
                        return Text(_monthAbbr[ends[i].month - 1],
                            style: TextStyle(
                                fontSize: 10, color: app.colors.textSecondary));
                      }
                      return const SizedBox.shrink();
                    },
                  ),
                ),
              ),
              lineBarsData: [
                LineChartBarData(
                  spots: spots,
                  isCurved: true,
                  color: app.colors.primary,
                  barWidth: 3,
                  isStrokeCapRound: true,
                  dotData: const FlDotData(show: false),
                  belowBarData: BarAreaData(
                    show: true,
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        app.colors.primary.withValues(alpha: 0.35),
                        app.colors.primary.withValues(alpha: 0.02),
                      ],
                    ),
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

// ── Bars: ingresos vs gastos por mes ───────────────────────────────────────
class _BarsCard extends StatelessWidget {
  final _Data data;
  final DateTime anchor;

  const _BarsCard({required this.data, required this.anchor});

  @override
  Widget build(BuildContext context) {
    final app = context.app;
    final ends = QuincenaUtils.lastMonthEnds(anchor, 12);
    final ing = <double>[];
    final gas = <double>[];
    for (final end in ends) {
      final ms = DateTime(end.year, end.month, 1);
      ing.add(SaldoCalculator.ingresos(data.txns, ms, end).toDouble());
      gas.add(SaldoCalculator.gastos(data.txns, ms, end).toDouble());
    }
    final maxV = [...ing, ...gas].fold<double>(0, math.max);
    if (maxV <= 0) {
      return _ChartCard(
        title: 'Ingresos vs Gastos',
        body: const EmptyState(
          icon: Icons.bar_chart_outlined,
          title: 'Sin movimientos',
          message: 'No hay ingresos ni gastos en los últimos meses.',
        ),
      );
    }
    return _ChartCard(
      title: 'Ingresos vs Gastos',
      subtitle: 'Últimos 12 meses',
      body: SizedBox(
        height: 220,
        child: Semantics(
          label: 'Gráfico de barras de ingresos contra gastos por mes',
          child: BarChart(
            BarChartData(
              alignment: BarChartAlignment.spaceAround,
              maxY: maxV * 1.15,
              borderData: FlBorderData(show: false),
              gridData: FlGridData(
                show: true,
                drawVerticalLine: false,
                horizontalInterval: maxV / 4 == 0 ? 1 : maxV / 4,
                getDrawingHorizontalLine: (v) =>
                    FlLine(color: app.colors.divider, strokeWidth: 1),
              ),
              titlesData: FlTitlesData(
                topTitles:
                    AxisTitles(sideTitles: SideTitles(showTitles: false)),
                rightTitles:
                    AxisTitles(sideTitles: SideTitles(showTitles: false)),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 48,
                    getTitlesWidget: (v, meta) => Text(
                      MoneyFormat.compact(DecimalUtils.fromDouble(v)),
                      style: TextStyle(
                          fontSize: 10, color: app.colors.textSecondary),
                    ),
                  ),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 24,
                    interval: 1,
                    getTitlesWidget: (v, meta) {
                      final i = v.round();
                      if (i >= 0 && i < ends.length) {
                        return Text(_monthAbbr[ends[i].month - 1],
                            style: TextStyle(
                                fontSize: 10, color: app.colors.textSecondary));
                      }
                      return const SizedBox.shrink();
                    },
                  ),
                ),
              ),
              barGroups: [
                for (var i = 0; i < ends.length; i++)
                  BarChartGroupData(
                    x: i,
                    barsSpace: 2,
                    barRods: [
                      BarChartRodData(
                        toY: ing[i],
                        color: app.colors.income,
                        width: 5,
                        borderRadius: app.radii.brXs,
                      ),
                      BarChartRodData(
                        toY: gas[i],
                        color: app.colors.expense,
                        width: 5,
                        borderRadius: app.radii.brXs,
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ),
      ),
      legend: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _dot(context, app.colors.income, 'Ingresos'),
          SizedBox(width: app.spacing.md),
          _dot(context, app.colors.expense, 'Gastos'),
        ],
      ),
    );
  }

  Widget _dot(BuildContext context, Color color, String label) => Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration:
                BoxDecoration(color: color, borderRadius: context.app.radii.brXs),
          ),
          SizedBox(width: context.app.spacing.xs),
          Text(label, style: const TextStyle(fontSize: 12)),
        ],
      );
}


// ── Comparativos y promedios ───────────────────────────────────────────────
class _ComparativesCard extends StatelessWidget {
  final _Data data;
  final PeriodView view;
  final DateTime anchor;

  const _ComparativesCard({
    required this.data,
    required this.view,
    required this.anchor,
  });

  @override
  Widget build(BuildContext context) {
    final app = context.app;
    final r = buildComparatives(data.txns, data.categories, view, anchor);

    Widget deltaRow(StatDelta s, {required bool inverse}) {
      final up = s.up;
      final good = inverse ? !up : up;
      final color = s.delta == Decimal.zero
          ? app.colors.textSecondary
          : (good ? app.colors.income : app.colors.expense);
      final icon = s.delta == Decimal.zero
          ? Icons.remove
          : (up ? Icons.arrow_upward : Icons.arrow_downward);
      return Padding(
        padding: EdgeInsets.symmetric(vertical: app.spacing.xs),
        child: Row(
          children: [
            Expanded(child: Text(s.label, style: const TextStyle(fontSize: 13))),
            Text(MoneyFormat.format(s.current),
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
            SizedBox(width: app.spacing.sm),
            Icon(icon, size: 16, color: color),
            Text('${s.pct.abs().toStringAsFixed(0)}%',
                style: TextStyle(
                    fontSize: 12, color: color, fontWeight: FontWeight.w700)),
          ],
        ),
      );
    }

    Widget promedio(String label, Decimal v) => Padding(
          padding: EdgeInsets.symmetric(vertical: app.spacing.xxs),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: const TextStyle(fontSize: 12)),
              Text(MoneyFormat.format(v),
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
            ],
          ),
        );

    final body = Column(
      children: [
        deltaRow(r.gasto, inverse: true),
        deltaRow(r.ingreso, inverse: false),
        deltaRow(r.utilidad, inverse: false),
        Divider(height: app.spacing.lg, color: app.colors.divider),
        promedio('Gasto promedio diario', r.gastoDiarioPromedio),
        promedio('Gasto promedio por mes (3m)', r.gastoMesPromedio),
        promedio('Gasto promedio por quincena (3m)', r.gastoQuincenaPromedio),
        promedio('Ingreso promedio por mes (3m)', r.ingresoMesPromedio),
        Padding(
          padding: EdgeInsets.only(top: app.spacing.sm),
          child: Row(
            children: [
              Icon(
                r.tendenciaGastoPct >= 0
                    ? Icons.trending_up
                    : Icons.trending_down,
                size: 16,
                color: r.tendenciaGastoPct >= 0
                    ? app.colors.expense
                    : app.colors.income,
              ),
              SizedBox(width: app.spacing.xs),
              Expanded(
                child: Text(
                  'Tendencia del gasto vs promedio 3 meses: '
                  '${r.tendenciaGastoPct.abs().toStringAsFixed(0)}%',
                  style: const TextStyle(fontSize: 12),
                ),
              ),
            ],
          ),
        ),
        if (r.topSubidaNombre != null)
          Padding(
            padding: EdgeInsets.only(top: app.spacing.xs),
            child: Row(
              children: [
                Icon(Icons.arrow_upward, size: 14, color: app.colors.expense),
                SizedBox(width: app.spacing.xs),
                Expanded(
                  child: Text(
                    'Subió más: ${r.topSubidaNombre} '
                    '(+${MoneyFormat.format(r.topSubidaMonto)})',
                    style: TextStyle(fontSize: 12, color: app.colors.expense),
                  ),
                ),
              ],
            ),
          ),
        if (r.topBajadaNombre != null)
          Padding(
            padding: EdgeInsets.only(top: app.spacing.xxs),
            child: Row(
              children: [
                Icon(Icons.arrow_downward, size: 14, color: app.colors.income),
                SizedBox(width: app.spacing.xs),
                Expanded(
                  child: Text(
                    'Bajó más: ${r.topBajadaNombre} '
                    '(-${MoneyFormat.format(r.topBajadaMonto)})',
                    style: TextStyle(fontSize: 12, color: app.colors.income),
                  ),
                ),
              ],
            ),
          ),
      ],
    );

    return _ChartCard(
      title: 'Comparativos',
      subtitle: '${view.label(anchor)} vs periodo anterior',
      body: body,
    );
  }
}
