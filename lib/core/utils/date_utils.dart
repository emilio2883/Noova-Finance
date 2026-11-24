/// Quincena and date utilities.
/// Quincenas are DERIVED from dates, never stored (per data-model.md):
/// Quincena 1 = days 1-15, Quincena 2 = days 16-end of month.
class QuincenaUtils {
  /// Returns the quincena number (1 or 2) for a given date.
  static int quincenaNumber(DateTime date) => date.day <= 15 ? 1 : 2;

  /// Returns the start date of the quincena containing [date].
  static DateTime quincenaStart(DateTime date) {
    if (date.day <= 15) {
      return DateTime(date.year, date.month, 1);
    }
    return DateTime(date.year, date.month, 16);
  }

  /// Returns the end date (inclusive) of the quincena containing [date].
  static DateTime quincenaEnd(DateTime date) {
    if (date.day <= 15) {
      return DateTime(date.year, date.month, 15, 23, 59, 59, 999);
    }
    final lastDay = DateTime(date.year, date.month + 1, 0).day;
    return DateTime(date.year, date.month, lastDay, 23, 59, 59, 999);
  }

  /// Human-readable quincena label, e.g. "Nov 1-15" or "Nov 16-30".
  static String quincenaLabel(DateTime date) {
    const monthNames = [
      'Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun',
      'Jul', 'Ago', 'Sep', 'Oct', 'Nov', 'Dic'
    ];
    final month = monthNames[date.month - 1];
    if (date.day <= 15) return '$month 1-15';
    final lastDay = DateTime(date.year, date.month + 1, 0).day;
    return '$month 16-$lastDay';
  }

  /// Start of the current month.
  static DateTime monthStart(DateTime date) => DateTime(date.year, date.month, 1);

  /// End (inclusive) of the current month.
  static DateTime monthEnd(DateTime date) {
    final lastDay = DateTime(date.year, date.month + 1, 0).day;
    return DateTime(date.year, date.month, lastDay, 23, 59, 59, 999);
  }

  /// Start of the current year.
  static DateTime yearStart(DateTime date) => DateTime(date.year, 1, 1);

  /// End (inclusive) of the current year.
  static DateTime yearEnd(DateTime date) =>
      DateTime(date.year, 12, 31, 23, 59, 59, 999);

  /// List of the last [count] month-end dates, oldest first.
  /// Used for the saldo line chart.
  static List<DateTime> lastMonthEnds(DateTime from, int count) {
    final result = <DateTime>[];
    for (var i = count - 1; i >= 0; i--) {
      var d = DateTime(from.year, from.month - i + 1, 0); // last day of month
      result.add(d);
    }
    return result;
  }
}
