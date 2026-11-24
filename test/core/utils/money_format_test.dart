import 'package:decimal/decimal.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:noova_finance/core/utils/money_format.dart';

void main() {
  group('MoneyFormat', () {
    test('formats positive amounts with 2 decimals', () {
      expect(MoneyFormat.format(Decimal.parse('1234.5')), r'$1,234.50');
      expect(MoneyFormat.format(Decimal.parse('1234.567')), r'$1,234.57');
    });

    test('formats negative amounts with leading minus', () {
      expect(MoneyFormat.format(Decimal.parse('-99.99')), r'-$99.99');
    });

    test('compact formats thousands', () {
      expect(MoneyFormat.compact(Decimal.parse('1500')), r'$1.5k');
      expect(MoneyFormat.compact(Decimal.parse('2300000')), r'$2.3M');
    });

    test('percent formats without decimals', () {
      expect(MoneyFormat.percent(Decimal.parse('42.4')), '42%');
    });
  });
}
