import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../models/category.dart';
import '../models/transaction.dart';
import '../repositories/category_repo.dart';
import '../repositories/transaction_repo.dart';

/// Builds and shares a CSV of transactions (opens in Excel).
class CsvExporter {
  final TransactionRepository _txnRepo;
  final CategoryRepository _catRepo;
  CsvExporter(this._txnRepo, this._catRepo);

  static String _esc(String s) {
    if (s.contains(',') || s.contains('"') || s.contains('\n')) {
      return '"${s.replaceAll('"', '""')}"';
    }
    return s;
  }

  static String _date(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  /// Pure CSV builder (tested). Columns:
  /// fecha,tipo,categoria,subcategoria,monto,descripcion,recurrente
  static String buildCsv(List<Transaction> txns, List<Category> cats) {
    final byId = {for (final c in cats) c.id: c};
    final sb = StringBuffer();
    sb.writeln('fecha,tipo,categoria,subcategoria,monto,descripcion,recurrente');
    final sorted = [...txns]..sort((a, b) => a.date.compareTo(b.date));
    for (final t in sorted) {
      final cat = byId[t.categoryId];
      var categoria = '';
      var subcategoria = '';
      if (cat != null) {
        if (cat.parentId != null) {
          subcategoria = cat.name;
          categoria = byId[cat.parentId]?.name ?? '';
        } else {
          categoria = cat.name;
        }
      }
      sb.writeln([
        _date(t.date),
        _esc(t.type == TransactionType.income ? 'Ingreso' : 'Gasto'),
        _esc(categoria),
        _esc(subcategoria),
        (t.amountBps / 10000).toStringAsFixed(2),
        _esc(t.description ?? ''),
        t.isRecurring ? 'Sí' : 'No',
      ].join(','));
    }
    return sb.toString();
  }

  Future<String> exportCsvString() async =>
      buildCsv(await _txnRepo.getAll(), await _catRepo.getAll());

  Future<File> saveAndShare() async {
    final csv = await exportCsvString();
    final dir = await getApplicationDocumentsDirectory();
    final now = DateTime.now();
    final name =
        'noova_transacciones_${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}.csv';
    final f = File('${dir.path}/$name');
    await f.writeAsString(csv);
    await Share.shareXFiles([XFile(f.path)], text: 'Transacciones Noova Finance');
    return f;
  }
}
