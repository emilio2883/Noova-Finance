import 'package:flutter_test/flutter_test.dart';

import 'package:noova_finance/data/models/category.dart';
import 'package:noova_finance/data/models/transaction.dart';
import 'package:noova_finance/data/services/csv_exporter.dart';

void main() {
  test('CSV header and a row are correct', () {
    final casa = Category(name: 'Casa', type: TransactionType.expense)
      ..id = 1
      ..isGroup = true;
    final gas = Category(name: 'Gas', type: TransactionType.expense)
      ..id = 2
      ..parentId = 1;
    final cats = <Category>[casa, gas];
    final txns = <Transaction>[
      Transaction(
        date: DateTime(2026, 1, 5),
        amountBps: 15050,
        type: TransactionType.expense,
        categoryId: 2,
        description: 'Recibo, enero',
      ),
    ];
    final csv = CsvExporter.buildCsv(txns, cats);
    final lines = csv.trim().split('\n');
    expect(lines.first,
        'fecha,tipo,categoria,subcategoria,monto,descripcion,recurrente');
    expect(lines[1], '2026-01-05,Gasto,Casa,Gas,1.50,"Recibo, enero",No');
  });
}
