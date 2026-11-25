import 'package:flutter_test/flutter_test.dart';

import 'package:noova_finance/core/utils/date_utils.dart';

void main() {
  group('QuincenaUtils', () {
    test('quincenaNumber: days 1-15 are quincena 1', () {
      expect(QuincenaUtils.quincenaNumber(DateTime(2026, 3, 1)), 1);
      expect(QuincenaUtils.quincenaNumber(DateTime(2026, 3, 15)), 1);
    });

    test('quincenaNumber: days 16+ are quincena 2', () {
      expect(QuincenaUtils.quincenaNumber(DateTime(2026, 3, 16)), 2);
      expect(QuincenaUtils.quincenaNumber(DateTime(2026, 3, 31)), 2);
    });

    test('quincenaStart for first quincena', () {
      final d = DateTime(2026, 3, 10);
      expect(QuincenaUtils.quincenaStart(d), DateTime(2026, 3, 1));
    });

    test('quincenaStart for second quincena', () {
      final d = DateTime(2026, 3, 20);
      expect(QuincenaUtils.quincenaStart(d), DateTime(2026, 3, 16));
    });

    test('quincenaEnd for first quincena is day 15', () {
      final d = DateTime(2026, 3, 10);
      expect(QuincenaUtils.quincenaEnd(d), DateTime(2026, 3, 15, 23, 59, 59, 999));
    });

    test('quincenaEnd for second quincena is last day of month', () {
      // February 2026 has 28 days
      final d = DateTime(2026, 2, 20);
      expect(QuincenaUtils.quincenaEnd(d), DateTime(2026, 2, 28, 23, 59, 59, 999));
    });

    test('quincenaLabel formats correctly', () {
      expect(QuincenaUtils.quincenaLabel(DateTime(2026, 11, 5)), 'Nov 1-15');
      expect(QuincenaUtils.quincenaLabel(DateTime(2026, 11, 20)), 'Nov 16-30');
    });

    test('monthStart and monthEnd', () {
      final d = DateTime(2026, 11, 17);
      expect(QuincenaUtils.monthStart(d), DateTime(2026, 11, 1));
      expect(QuincenaUtils.monthEnd(d), DateTime(2026, 11, 30, 23, 59, 59, 999));
    });

    test('lastMonthEnds returns month-end dates oldest first', () {
      final from = DateTime(2026, 3, 15);
      final ends = QuincenaUtils.lastMonthEnds(from, 3);
      expect(ends.length, 3);
      expect(ends[0], DateTime(2026, 1, 31));
      expect(ends[1], DateTime(2026, 2, 28));
      expect(ends[2], DateTime(2026, 3, 31));
    });
  });
}
