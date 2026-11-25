import 'package:decimal/decimal.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:noova_finance/core/utils/decimal_utils.dart';

void main() {
  group('DecimalUtils', () {
    test('tryParse parses plain numbers', () {
      expect(DecimalUtils.tryParse('123.45'), Decimal.parse('123.45'));
    });

    test('tryParse tolerates commas and spaces', () {
      expect(DecimalUtils.tryParse(' 1,234.56 '), Decimal.parse('1234.56'));
    });

    test('tryParse returns null on invalid input', () {
      expect(DecimalUtils.tryParse('abc'), isNull);
      expect(DecimalUtils.tryParse(''), isNull);
      expect(DecimalUtils.tryParse(null), isNull);
    });

    test('round2 rounds half-up to 2 decimals', () {
      expect(DecimalUtils.round2(Decimal.parse('1.005')), Decimal.parse('1.01'));
      expect(DecimalUtils.round2(Decimal.parse('1.004')), Decimal.parse('1.00'));
    });

    test('sum adds a list of Decimals', () {
      final values = [
        Decimal.parse('10.10'),
        Decimal.parse('20.20'),
        Decimal.parse('-0.30'),
      ];
      expect(DecimalUtils.sum(values), Decimal.parse('30.00'));
    });

    test('abs returns absolute value', () {
      expect(DecimalUtils.abs(Decimal.parse('-5.50')), Decimal.parse('5.50'));
      expect(DecimalUtils.abs(Decimal.parse('5.50')), Decimal.parse('5.50'));
    });

    test('percent computes ratio times 100', () {
      final result = DecimalUtils.percent(
        Decimal.parse('42.00'),
        Decimal.parse('100.00'),
      );
      expect(result, Decimal.parse('42'));
    });

    test('percent returns zero when total is zero', () {
      expect(
        DecimalUtils.percent(Decimal.parse('1'), Decimal.zero),
        Decimal.zero,
      );
    });

    test('fromDouble converts without floating noise', () {
      // 0.1 + 0.2 in double is 0.30000000000000004; Decimal must not inherit it
      final d = DecimalUtils.fromDouble(0.1 + 0.2);
      expect(d, Decimal.parse('0.3000'));
    });

    test('equalsRounded compares at 2 decimals', () {
      expect(
        DecimalUtils.equalsRounded(
          Decimal.parse('1.004'),
          Decimal.parse('1.00'),
        ),
        isTrue,
      );
    });
  });
}
