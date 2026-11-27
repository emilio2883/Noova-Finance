import 'package:decimal/decimal.dart';

import '../../core/utils/date_utils.dart';
import '../../data/models/category.dart';
import '../../data/models/transaction.dart';
import '../../data/services/saldo_calculator.dart';
import '../../shared/widgets/period_selector.dart';

Decimal _div2(Decimal a, Decimal b) {
  if (b == Decimal.zero) return Decimal.zero;
  return Decimal.parse((a.toDouble() / b.toDouble()).toStringAsFixed(2));
}

/// One current-vs-previous metric with derived delta and % change.
class StatDelta {
  final String label;
  final Decimal current;
  final Decimal previous;
  const StatDelta(this.label, this.current, this.previous);

  Decimal get delta => SaldoCalculator.deltaPeriodo(current, previous);
  double get pct => SaldoCalculator.pctCambio(current, previous);
  bool get up => delta > Decimal.zero;
}

/// Aggregated comparatives for a period vs the previous one, plus averages
/// and top category movers. Pure/deterministic — unit tested.
class ComparativesResult {
  final StatDelta gasto;
  final StatDelta ingreso;
  final StatDelta utilidad;
  final Decimal gastoDiarioPromedio;
  final Decimal gastoMesPromedio;
  final Decimal gastoQuincenaPromedio;
  final Decimal ingresoMesPromedio;
  final double tendenciaGastoPct;
  final String? topSubidaNombre;
  final Decimal topSubidaMonto;
  final String? topBajadaNombre;
  final Decimal topBajadaMonto;

  const ComparativesResult({
    required this.gasto,
    required this.ingreso,
    required this.utilidad,
    required this.gastoDiarioPromedio,
    required this.gastoMesPromedio,
    required this.gastoQuincenaPromedio,
    required this.ingresoMesPromedio,
    required this.tendenciaGastoPct,
    required this.topSubidaNombre,
    required this.topSubidaMonto,
    required this.topBajadaNombre,
    required this.topBajadaMonto,
  });
}

DateTime prevAnchorFor(PeriodView view, DateTime anchor) {
  switch (view) {
    case PeriodView.quincena:
      return anchor.day <= 15
          ? DateTime(anchor.year, anchor.month - 1, 16)
          : DateTime(anchor.year, anchor.month, 1);
    case PeriodView.mes:
      return DateTime(anchor.year, anchor.month - 1, 1);
    case PeriodView.anio:
      return DateTime(anchor.year - 1, 1, 1);
  }
}

Map<String, Decimal> _principalTotals(
  List<Transaction> txns,
  Map<int, Category> cats,
  DateTime start,
  DateTime end,
) {
  final byLeaf = SaldoCalculator.gastosPorCategoria(txns, start, end);
  final result = <String, Decimal>{};
  for (final p in cats.values) {
    if (!(p.isGroup && p.parentId == null && p.type == TransactionType.expense)) {
      continue;
    }
    var total = byLeaf[p.id] ?? Decimal.zero;
    for (final ch in cats.values.where((c) => c.parentId == p.id)) {
      total += byLeaf[ch.id] ?? Decimal.zero;
    }
    result[p.name] = total;
  }
  return result;
}

ComparativesResult buildComparatives(
  List<Transaction> txns,
  Map<int, Category> cats,
  PeriodView view,
  DateTime anchor,
) {
  final cur = view.range(anchor);
  final prev = view.range(prevAnchorFor(view, anchor));

  final gCur = SaldoCalculator.gastos(txns, cur.$1, cur.$2);
  final gPrev = SaldoCalculator.gastos(txns, prev.$1, prev.$2);
  final iCur = SaldoCalculator.ingresos(txns, cur.$1, cur.$2);
  final iPrev = SaldoCalculator.ingresos(txns, prev.$1, prev.$2);
  final uCur = SaldoCalculator.utilidad(txns, cur.$1, cur.$2);
  final uPrev = SaldoCalculator.utilidad(txns, prev.$1, prev.$2);

  // Averages over the last 3 months ending at [anchor].
  final ends = QuincenaUtils.lastMonthEnds(anchor, 3);
  var gSum = Decimal.zero;
  var iSum = Decimal.zero;
  for (final end in ends) {
    final ms = DateTime(end.year, end.month, 1);
    gSum += SaldoCalculator.gastos(txns, ms, end);
    iSum += SaldoCalculator.ingresos(txns, ms, end);
  }
  final months = Decimal.fromInt(ends.length);
  final gastoMesPromedio = _div2(gSum, months);
  final ingresoMesPromedio = _div2(iSum, months);
  final gastoQuincenaPromedio = _div2(gSum, months * Decimal.fromInt(2));

  final gastoDiarioPromedio =
      SaldoCalculator.promedioDiario(gCur, cur.$1, cur.$2);
  final tendencia = SaldoCalculator.pctCambio(gCur, gastoMesPromedio);

  // Top category movers vs previous period.
  final curP = _principalTotals(txns, cats, cur.$1, cur.$2);
  final prevP = _principalTotals(txns, cats, prev.$1, prev.$2);
  String? upName;
  String? downName;
  var upMonto = Decimal.zero;
  var downMonto = Decimal.zero;
  for (final name in {...curP.keys, ...prevP.keys}) {
    final d = (curP[name] ?? Decimal.zero) - (prevP[name] ?? Decimal.zero);
    if (d > upMonto) {
      upMonto = d;
      upName = name;
    }
    if (d < downMonto) {
      downMonto = d;
      downName = name;
    }
  }

  return ComparativesResult(
    gasto: StatDelta('Gasto', gCur, gPrev),
    ingreso: StatDelta('Ingreso', iCur, iPrev),
    utilidad: StatDelta('Utilidad', uCur, uPrev),
    gastoDiarioPromedio: gastoDiarioPromedio,
    gastoMesPromedio: gastoMesPromedio,
    gastoQuincenaPromedio: gastoQuincenaPromedio,
    ingresoMesPromedio: ingresoMesPromedio,
    tendenciaGastoPct: tendencia,
    topSubidaNombre: upName,
    topSubidaMonto: upMonto,
    topBajadaNombre: downName,
    topBajadaMonto: downMonto.abs(),
  );
}
