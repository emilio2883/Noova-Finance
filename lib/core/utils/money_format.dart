import 'package:decimal/decimal.dart';
import 'package:intl/intl.dart';

/// Money formatting for USD/PAB (1:1 peg).
/// Per constitution Article VI: all amounts displayed with 2 decimal places.
class MoneyFormat {
  static final NumberFormat _format = NumberFormat('#,##0.00', 'en_US');

  /// Format a Decimal as "$1,234.56".
  static String format(Decimal value) {
    final rounded = value.round(scale: 2);
    final isNegative = rounded < Decimal.zero;
    final abs = isNegative ? -rounded : rounded;
    final formatted = _format.format(abs.toDouble());
    return isNegative ? '-\$$formatted' : '\$$formatted';
  }

  /// Format for compact display, e.g. "$1.2k" for charts.
  static String compact(Decimal value) {
    final abs = value < Decimal.zero ? -value : value;
    final d = abs.toDouble();
    if (d >= 1000000) {
      return '\$${(d / 1000000).toStringAsFixed(1)}M';
    }
    if (d >= 1000) {
      return '\$${(d / 1000).toStringAsFixed(1)}k';
    }
    return format(value);
  }

  /// Format a percentage with 0 decimals, e.g. "42%".
  static String percent(Decimal value) {
    return '${value.round(scale: 0).toDouble().toInt()}%';
  }
}
