import 'package:decimal/decimal.dart';

import '../../core/utils/money_format.dart';
import 'providers/dashboard_provider.dart';

enum InsightTone { positive, negative, warning, neutral }

/// One actionable/at-a-glance insight for the dashboard.
class Insight {
  final String title;
  final String subtitle;
  final InsightTone tone;
  const Insight(this.title, this.subtitle, this.tone);
}

/// Derives a short list of insights from the aggregated dashboard data.
List<Insight> buildInsights(DashboardData d) {
  final out = <Insight>[];

  if (d.utilidadMes > Decimal.zero) {
    out.add(Insight('Vas en positivo',
        'Utilidad de ${MoneyFormat.format(d.utilidadMes)} este mes', InsightTone.positive));
  } else if (d.utilidadMes < Decimal.zero) {
    out.add(Insight('Gastos por encima de ingresos',
        'Déficit de ${MoneyFormat.format(d.utilidadMes.abs())} este mes', InsightTone.negative));
  }

  final withSpend =
      d.categorySpending.where((s) => s.total > Decimal.zero).toList();
  if (withSpend.isNotEmpty) {
    final top = withSpend.first;
    out.add(Insight('Mayor gasto: ${top.parent.name}',
        '${MoneyFormat.format(top.total)} esta quincena', InsightTone.neutral));
  }

  for (final s in d.categorySpending.where((s) => s.hasBudget)) {
    if (s.percentUsed >= 100) {
      out.add(Insight('${s.parent.name} excedió el presupuesto',
          '${s.percentUsed}% del presupuesto', InsightTone.negative));
    } else if (s.percentUsed >= 80) {
      out.add(Insight('${s.parent.name} cerca del límite',
          '${s.percentUsed}% del presupuesto', InsightTone.warning));
    }
    if (out.length >= 4) break;
  }

  return out.take(4).toList();
}
