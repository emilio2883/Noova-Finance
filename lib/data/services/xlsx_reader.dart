import 'dart:convert';
import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:xml/xml.dart';

/// Reads raw cell values from an .xlsx file WITHOUT evaluating formulas and
/// WITHOUT date misinterpretation: it pulls the cached numeric `<v>` value of
/// every cell. This is robust for formula-heavy / date-formatted workbooks
/// (which the `excel` package misreads).
///
/// Returns: sheetName -> {rowIndex(0-based) -> {colIndex(0-based) -> value}}
/// where value is `double` for numbers or `String` for text.
class XlsxReader {
  static Map<String, Map<int, Map<int, dynamic>>> parse(List<int> bytes) {
    final archive = ZipDecoder().decodeBytes(Uint8List.fromList(bytes));

    String? readText(String name) {
      ArchiveFile? file;
      for (final f in archive.files) {
        if (f.name == name) {
          file = f;
          break;
        }
      }
      if (file == null) return null;
      final content = file.content;
      if (content is Uint8List) return utf8.decode(content, allowMalformed: true);
      if (content is List<int>) return utf8.decode(content, allowMalformed: true);
      return content.toString();
    }

    // Shared strings
    final sharedStrings = <String>[];
    final ssXml = readText('xl/sharedStrings.xml');
    if (ssXml != null) {
      final doc = XmlDocument.parse(ssXml);
      for (final si in doc.findAllElements('si', namespace: '*')) {
        final texts = si
            .findAllElements('t', namespace: '*')
            .map((e) => e.innerText)
            .join();
        sharedStrings.add(texts);
      }
    }

    // Workbook sheet names + rels
    final wbXml = readText('xl/workbook.xml');
    final relsXml = readText('xl/_rels/workbook.xml.rels');
    if (wbXml == null || relsXml == null) {
      throw const FormatException('Not a valid .xlsx (missing workbook parts)');
    }
    final wbDoc = XmlDocument.parse(wbXml);
    final relsDoc = XmlDocument.parse(relsXml);
    final relMap = <String, String>{};
    for (final rel in relsDoc.findAllElements('Relationship', namespace: '*')) {
      final id = rel.getAttribute('Id');
      final target = rel.getAttribute('Target');
      if (id != null && target != null) relMap[id] = target;
    }

    final result = <String, Map<int, Map<int, dynamic>>>{};
    for (final s in wbDoc.findAllElements('sheet', namespace: '*')) {
      final name = s.getAttribute('name');
      if (name == null) continue;
      String? rid;
      for (final a in s.attributes) {
        if (a.name.local == 'id') rid = a.value;
      }
      final target = rid != null ? relMap[rid] : null;
      if (target == null) continue;
      // Normalize path
      var path = target.startsWith('/') ? target.substring(1) : 'xl/$target';
      var sheetXml = readText(path);
      if (sheetXml == null) {
        // try resolving ../ 
        final clean = target.replaceFirst('../', '');
        sheetXml = readText('xl/$clean');
      }
      if (sheetXml == null) continue;
      result[name] = _parseSheet(sheetXml, sharedStrings);
    }
    return result;
  }

  static Map<int, Map<int, dynamic>> _parseSheet(
      String xml, List<String> sharedStrings) {
    final doc = XmlDocument.parse(xml);
    final rows = <int, Map<int, dynamic>>{};
    var autoRow = 0;
    for (final row in doc.findAllElements('row', namespace: '*')) {
      final rAttr = row.getAttribute('r');
      final rowIdx = rAttr != null ? int.parse(rAttr) - 1 : autoRow;
      autoRow = rowIdx + 1;

      final cells = <int, dynamic>{};
      for (final c in row.findAllElements('c', namespace: '*')) {
        final ref = c.getAttribute('r') ?? '';
        final t = c.getAttribute('t');
        final colIdx = _colFromRef(ref);

        final vEls = c.findElements('v', namespace: '*');
        final v = vEls.isEmpty ? null : vEls.first.innerText;

        dynamic val;
        if (t == 's') {
          final idx = v != null ? int.tryParse(v) : null;
          if (idx != null && idx < sharedStrings.length) {
            val = sharedStrings[idx];
          }
        } else if (t == 'inlineStr') {
          final isEls = c.findElements('is', namespace: '*');
          if (isEls.isNotEmpty) {
            val = isEls.first
                .findAllElements('t', namespace: '*')
                .map((e) => e.innerText)
                .join();
          }
        } else if (t == 'str' || t == 'd' || t == 'b' || t == 'e') {
          val = v;
        } else {
          // numeric (or cached formula result)
          final parsed = v != null ? double.tryParse(v) : null;
          if (parsed != null) val = parsed;
        }
        if (val != null) cells[colIdx] = val;
      }
      if (cells.isNotEmpty) rows[rowIdx] = cells;
    }
    return rows;
  }

  /// "B10" -> 1 (0-based column index).
  static int _colFromRef(String ref) {
    var col = 0;
    for (var i = 0; i < ref.length; i++) {
      final code = ref.codeUnitAt(i);
      if (code >= 65 && code <= 90) {
        col = col * 26 + (code - 64);
      } else {
        break;
      }
    }
    return col - 1;
  }
}
