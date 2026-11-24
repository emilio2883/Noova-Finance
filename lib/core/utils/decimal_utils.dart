import 'package:decimal/decimal.dart';

/// Decimal arithmetic helpers for financial calculations.
/// Per constitution Article V: never use floating-point for money.
class DecimalUtils {
  static final Decimal _hundred = Decimal.fromInt(100);

  /// Parse a string to Decimal, tolerating commas and extra spaces.
  /// Returns null if invalid.
  static Decimal? tryParse(String? input) {
    if (input == null) return null;
    final cleaned = input.trim().replaceAll(',', '');
    if (cleaned.isEmpty) return null;
    try {
      return Decimal.parse(cleaned);
    } catch (_) {
      return null;
    }
  }

  /// Round a Decimal to 2 decimal places (half-up).
  static Decimal round2(Decimal value) {
    return value.round(scale: 2);
  }

  /// Round a Decimal to 4 decimal places (storage precision).
  static Decimal round4(Decimal value) {
    return value.round(scale: 4);
  }

  /// Sum a list of Decimals.
  static Decimal sum(Iterable<Decimal> values) {
    var total = Decimal.zero;
    for (final v in values) {
      total += v;
    }
    return total;
  }

  /// Absolute value.
  static Decimal abs(Decimal value) => value < Decimal.zero ? -value : value;

  /// Percentage of [part] relative to [total]. Returns 0 if total is zero.
  static Decimal percent(Decimal part, Decimal total) {
    if (total == Decimal.zero) return Decimal.zero;
    final ratio = (part / total) * _hundred.toRational();
    return ratio.toDecimal(scale: 2);
  }

  /// Convert double (e.g. from Excel parser) to Decimal safely.
  static Decimal fromDouble(double value) {
    return Decimal.parse(value.toStringAsFixed(4));
  }

  /// Compare with tolerance at 2 decimal places.
  static bool equalsRounded(Decimal a, Decimal b) {
    return round2(a) == round2(b);
  }
}
