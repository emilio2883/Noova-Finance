import 'package:decimal/decimal.dart';

import '../../core/utils/date_utils.dart';
import '../../core/utils/decimal_utils.dart';
import '../models/transaction.dart';

/// Financial calculations: saldo, utilidad, period aggregation.
/// All arithmetic is Decimal — never floating-point (constitution Art. V).
class SaldoCalculator {
  /// Current saldo: sum of all income minus all expenses up to [date].
  static Decimal saldo(List<Transaction> transactions, DateTime date) {
    final upto = transactions
        .where((t) => !t.date.isAfter(date))
        .map((t) => t.type == TransactionType.income ? t.amount : -t.amount);
    return DecimalUtils.sum(upto);
  }

  /// Total income in a period.
  static Decimal ingresos(List<Transaction> transactions, DateTime start, DateTime end) {
    final income = transactions
        .where((t) =>
            t.type == TransactionType.income &&
            !t.date.isBefore(start) &&
            !t.date.isAfter(end))
        .map((t) => t.amount);
    return DecimalUtils.sum(income);
  }

  /// Total expenses in a period (positive result).
  static Decimal gastos(List<Transaction> transactions, DateTime start, DateTime end) {
    final expenses = transactions
        .where((t) =>
            t.type == TransactionType.expense &&
            !t.date.isBefore(start) &&
            !t.date.isAfter(end))
        .map((t) => t.amount);
    return DecimalUtils.sum(expenses);
  }

  /// Utilidad neta for a period: ingresos - gastos.
  static Decimal utilidad(List<Transaction> transactions, DateTime start, DateTime end) {
    final ing = ingresos(transactions, start, end);
    final gas = gastos(transactions, start, end);
    return ing - gas;
  }

  /// Utilidad for the quincena containing [date].
  static Decimal utilidadQuincena(List<Transaction> transactions, DateTime date) {
    return utilidad(
      transactions,
      QuincenaUtils.quincenaStart(date),
      QuincenaUtils.quincenaEnd(date),
    );
  }

  /// Utilidad for the month containing [date].
  static Decimal utilidadMes(List<Transaction> transactions, DateTime date) {
    return utilidad(
      transactions,
      QuincenaUtils.monthStart(date),
      QuincenaUtils.monthEnd(date),
    );
  }

  /// Saldo at the end of each of the last [months] months (oldest first).
  /// Used by the saldo line chart.
  static List<Decimal> saldoMensual(
    List<Transaction> transactions,
    DateTime from,
    int months,
  ) {
    final monthEnds = QuincenaUtils.lastMonthEnds(from, months);
    return monthEnds.map((end) => saldo(transactions, end)).toList();
  }

  /// Total income per categoryId in a period.
  static Map<int, Decimal> ingresosPorCategoria(
    List<Transaction> transactions,
    DateTime start,
    DateTime end,
  ) {
    final result = <int, Decimal>{};
    for (final t in transactions) {
      if (t.type != TransactionType.income) continue;
      if (t.date.isBefore(start) || t.date.isAfter(end)) continue;
      result[t.categoryId] = (result[t.categoryId] ?? Decimal.zero) + t.amount;
    }
    return result;
  }

  /// Total spent per categoryId in a period.
  /// Key = categoryId, value = total expense amount (positive).
  static Map<int, Decimal> gastosPorCategoria(
    List<Transaction> transactions,
    DateTime start,
    DateTime end,
  ) {
    final result = <int, Decimal>{};
    for (final t in transactions) {
      if (t.type != TransactionType.expense) continue;
      if (t.date.isBefore(start) || t.date.isAfter(end)) continue;
      result[t.categoryId] = (result[t.categoryId] ?? Decimal.zero) + t.amount;
    }
    return result;
  }

  /// Difference between a current and a previous total (current - previous).
  static Decimal deltaPeriodo(Decimal actual, Decimal anterior) =>
      actual - anterior;

  /// Percentage change of [actual] vs [anterior]. 0 when anteriores el cero.
  static double pctCambio(Decimal actual, Decimal anterior) {
    if (anterior == Decimal.zero) {
      return actual == Decimal.zero ? 0 : 100;
    }
    return (actual.toDouble() - anterior.toDouble()) /
        anterior.toDouble() *
        100;
  }

  /// Average amount per day across the inclusive range [start, end].
  static Decimal promedioDiario(Decimal total, DateTime start, DateTime end) {
    final days = end.difference(start).inDays + 1;
    if (days <= 0) return Decimal.zero;
    return Decimal.parse((total.toDouble() / days).toStringAsFixed(2));
  }
}
