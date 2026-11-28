import 'dart:io';
import 'dart:typed_data';

import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart';

import '../models/transaction.dart';
import '../repositories/category_repo.dart';
import '../repositories/transaction_repo.dart';
import 'saldo_calculator.dart';

/// Generates a summarized PDF report for a period.
class PdfExporter {
  final TransactionRepository _txnRepo;
  final CategoryRepository _catRepo;
  PdfExporter(this._txnRepo, this._catRepo);

  static String _money(int bps) => 'USD ${(bps / 10000).toStringAsFixed(2)}';
  static String _date(DateTime d) => '${d.day}/${d.month}/${d.year}';

  Future<Uint8List> buildReport({
    required DateTime start,
    required DateTime end,
    String title = 'Reporte Noova Finance',
  }) async {
    final txns = await _txnRepo.getByDateRange(start, end);
    final cats = await _catRepo.getAll();
    final byId = {for (final c in cats) c.id: c};
    final ing = SaldoCalculator.ingresos(txns, start, end).toDouble();
    final gas = SaldoCalculator.gastos(txns, start, end).toDouble();

    final doc = pw.Document();
    doc.addPage(pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      build: (ctx) => [
        pw.Header(level: 0, text: title),
        pw.Text('Periodo: ${_date(start)} - ${_date(end)}'),
        pw.SizedBox(height: 8),
        pw.Text('Ingresos: USD ${ing.toStringAsFixed(2)}'),
        pw.Text('Gastos: USD ${gas.toStringAsFixed(2)}'),
        pw.Text('Utilidad: USD ${(ing - gas).toStringAsFixed(2)}'),
        pw.SizedBox(height: 16),
        pw.Text('Movimientos (${txns.length})',
            style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
        pw.SizedBox(height: 6),
        pw.TableHelper.fromTextArray(
          headers: ['Fecha', 'Tipo', 'Categoria', 'Monto'],
          data: [
            for (final t in txns)
              [
                _date(t.date),
                t.type == TransactionType.income ? 'Ingreso' : 'Gasto',
                byId[t.categoryId]?.name ?? '',
                _money(t.amountBps),
              ],
          ],
        ),
      ],
    ));
    return doc.save();
  }

  Future<File> exportAndShare({
    required DateTime start,
    required DateTime end,
  }) async {
    final bytes = await buildReport(start: start, end: end);
    final dir = await getApplicationDocumentsDirectory();
    final now = DateTime.now();
    final name =
        'noova_reporte_${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}.pdf';
    final f = File('${dir.path}/$name');
    await f.writeAsBytes(bytes);
    await Share.shareXFiles([XFile(f.path)], text: 'Reporte Noova Finance');
    return f;
  }
}
