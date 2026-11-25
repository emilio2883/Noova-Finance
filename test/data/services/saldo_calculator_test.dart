import 'package:decimal/decimal.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:noova_finance/data/models/transaction.dart';
import 'package:noova_finance/data/services/saldo_calculator.dart';

void main() {
  Transaction txn(DateTime date, String amount, TransactionType type,
      {int categoryId = 1}) {
    return Transaction(
      date: date,
      amountBps: Decimal.parse(amount).shift(4).toBigInt().toInt(),
      type: type,
      categoryId: categoryId,
    );
  }

  final transactions = [
    // January
    txn(DateTime(2026, 1, 5), '2800.00', TransactionType.income),
    txn(DateTime(2026, 1, 10), '150.00', TransactionType.expense),
    txn(DateTime(2026, 1, 20), '200.00', TransactionType.expense),
    // February
    txn(DateTime(2026, 2, 5), '2800.00', TransactionType.income),
    txn(DateTime(2026, 2, 14), '300.00', TransactionType.expense),
    txn(DateTime(2026, 2, 25), '500.00', TransactionType.expense),
    // March
    txn(DateTime(2026, 3, 5), '2800.00', TransactionType.income),
    txn(DateTime(2026, 3, 12), '120.00', TransactionType.expense),
  ];

  group('SaldoCalculator', () {
    test('saldo sums income minus expenses up to date', () {
      final s = SaldoCalculator.saldo(transactions, DateTime(2026, 3, 12));
      // 2800*3 - (150+200+300+500+120) = 8400 - 1270 = 7130
      expect(s, Decimal.parse('7130.00'));
    });

    test('saldo respects the cutoff date', () {
      final s = SaldoCalculator.saldo(transactions, DateTime(2026, 1, 31));
      // 2800 - 350 = 2450
      expect(s, Decimal.parse('2450.00'));
    });

    test('ingresos totals income in period', () {
      final ing = SaldoCalculator.ingresos(
        transactions,
        DateTime(2026, 2, 1),
        DateTime(2026, 2, 28, 23, 59, 59),
      );
      expect(ing, Decimal.parse('2800.00'));
    });

    test('gastos totals expenses in period (positive)', () {
      final gas = SaldoCalculator.gastos(
        transactions,
        DateTime(2026, 2, 1),
        DateTime(2026, 2, 28, 23, 59, 59),
      );
      expect(gas, Decimal.parse('800.00'));
    });

    test('utilidad = ingresos - gastos for period', () {
      final u = SaldoCalculator.utilidad(
        transactions,
        DateTime(2026, 2, 1),
        DateTime(2026, 2, 28, 23, 59, 59),
      );
      expect(u, Decimal.parse('2000.00'));
    });

    test('utilidadQuincena uses quincena 1 (days 1-15)', () {
      // Feb quincena 1: income 2800, expense 300 => 2500
      final u = SaldoCalculator.utilidadQuincena(transactions, DateTime(2026, 2, 10));
      expect(u, Decimal.parse('2500.00'));
    });

    test('utilidadMes uses whole month', () {
      final u = SaldoCalculator.utilidadMes(transactions, DateTime(2026, 2, 15));
      expect(u, Decimal.parse('2000.00'));
    });

    test('saldoMensual returns saldo at end of each month', () {
      final saldos = SaldoCalculator.saldoMensual(transactions, DateTime(2026, 3, 15), 3);
      expect(saldos.length, 3);
      expect(saldos[0], Decimal.parse('2450.00')); // end of Jan
      expect(saldos[1], Decimal.parse('4450.00')); // end of Feb
      expect(saldos[2], Decimal.parse('7130.00')); // end of Mar (projected to Mar 31)
    });

    test('gastosPorCategoria groups by categoryId', () {
      final txns = [
        txn(DateTime(2026, 3, 5), '100', TransactionType.expense, categoryId: 1),
        txn(DateTime(2026, 3, 6), '50', TransactionType.expense, categoryId: 2),
        txn(DateTime(2026, 3, 7), '25', TransactionType.expense, categoryId: 1),
        txn(DateTime(2026, 3, 8), '999', TransactionType.income, categoryId: 1),
      ];
      final map = SaldoCalculator.gastosPorCategoria(
        txns,
        DateTime(2026, 3, 1),
        DateTime(2026, 3, 31),
      );
      expect(map[1], Decimal.parse('125'));
      expect(map[2], Decimal.parse('50'));
      expect(map.containsKey(3), isFalse);
    });
  });
}
