import 'package:decimal/decimal.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/utils/date_utils.dart';
import '../../../data/providers.dart';
import '../../../data/services/saldo_calculator.dart';
import '../../../data/models/transaction.dart';

/// Aggregated dashboard state.
class DashboardData {
  final Decimal saldo;
  final Decimal ingresosMes;
  final Decimal gastosMes;
  final Decimal utilidadMes;
  final List<Transaction> recent;

  DashboardData({
    required this.saldo,
    required this.ingresosMes,
    required this.gastosMes,
    required this.utilidadMes,
    required this.recent,
  });
}

/// Recomputes on every change (after insert/update/delete).
final dashboardProvider = FutureProvider.autoDispose<DashboardData>((ref) async {
  final repo = await ref.watch(transactionRepoProvider.future);

  final now = DateTime.now();
  final all = await repo.getAll();
  final monthStart = QuincenaUtils.monthStart(now);
  final monthEnd = QuincenaUtils.monthEnd(now);

  final recent = await repo.getRecent(limit: 15);

  return DashboardData(
    saldo: SaldoCalculator.saldo(all, now),
    ingresosMes: SaldoCalculator.ingresos(all, monthStart, monthEnd),
    gastosMes: SaldoCalculator.gastos(all, monthStart, monthEnd),
    utilidadMes: SaldoCalculator.utilidad(all, monthStart, monthEnd),
    recent: recent,
  );
});

/// Invalidate the dashboard after any mutation.
void refreshDashboard(Ref ref) {
  ref.invalidate(dashboardProvider);
}
