import 'package:decimal/decimal.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:noova_finance/data/models/category.dart';
import 'package:noova_finance/data/models/transaction.dart';
import 'package:noova_finance/data/services/saldo_calculator.dart';
import 'package:noova_finance/features/charts/comparatives.dart';
import 'package:noova_finance/shared/widgets/period_selector.dart';

Transaction _t(DateTime d, TransactionType type, int catId, double v) =>
    Transaction(
      date: d,
      amountBps: (v * 10000).round(),
      type: type,
      categoryId: catId,
    );

Category _cat(int id, String name, TransactionType type,
        {bool isGroup = false, int? parentId}) =>
    Category(name: name, type: type)
      ..id = id
      ..isGroup = isGroup
      ..isActive = true
      ..parentId = parentId;

void main() {
  final cats = <int, Category>{
    1: _cat(1, 'Casa', TransactionType.expense, isGroup: true),
    2: _cat(2, 'Restaurante', TransactionType.expense, parentId: 1),
    10: _cat(10, 'Ingresos', TransactionType.income, isGroup: true),
    11: _cat(11, 'Salario', TransactionType.income, parentId: 10),
  };

  test('deltaPeriodo y pctCambio', () {
    expect(SaldoCalculator.deltaPeriodo(Decimal.parse('300'), Decimal.parse('200')),
        Decimal.parse('100'));
    expect(
        SaldoCalculator.pctCambio(Decimal.parse('300'), Decimal.parse('200')),
        closeTo(50, 0.0001));
    expect(SaldoCalculator.pctCambio(Decimal.parse('0'), Decimal.parse('0')), 0);
    expect(
        SaldoCalculator.pctCambio(Decimal.parse('5'), Decimal.parse('0')), 100);
  });

  test('promedioDiario reparte el total por días inclusivos', () {
    final r = SaldoCalculator.promedioDiario(
      Decimal.parse('300'),
      DateTime(2026, 5, 1),
      DateTime(2026, 5, 31),
    );
    expect(r, Decimal.parse('9.68')); // 300 / 31
  });

  test('buildComparatives: deltas y pct mes vs mes anterior', () {
    final txns = [
      _t(DateTime(2026, 5, 10), TransactionType.expense, 2, 300),
      _t(DateTime(2026, 5, 5), TransactionType.income, 11, 1000),
      _t(DateTime(2026, 4, 10), TransactionType.expense, 2, 200),
      _t(DateTime(2026, 4, 5), TransactionType.income, 11, 800),
    ];
    final r = buildComparatives(txns, cats, PeriodView.mes, DateTime(2026, 5, 15));

    expect(r.gasto.current, Decimal.parse('300'));
    expect(r.gasto.previous, Decimal.parse('200'));
    expect(r.gasto.delta, Decimal.parse('100'));
    expect(r.gasto.pct, closeTo(50, 0.0001));

    expect(r.ingreso.current, Decimal.parse('1000'));
    expect(r.ingreso.previous, Decimal.parse('800'));
    expect(r.ingreso.pct, closeTo(25, 0.0001));

    expect(r.utilidad.current, Decimal.parse('700'));
    expect(r.utilidad.previous, Decimal.parse('600'));

    // Top mover: gasto en Restaurante subió +100
    expect(r.topSubidaNombre, 'Casa');
    expect(r.topSubidaMonto, Decimal.parse('100'));
  });
}
