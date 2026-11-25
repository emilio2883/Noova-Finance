import 'package:isar/isar.dart';

part 'import_record.g.dart';

/// Log of files imported (so multiple sources can be tracked).
@collection
class ImportRecord {
  Id id = Isar.autoIncrement;

  String fileName;
  DateTime importedAt;
  int imported;
  int skipped;

  ImportRecord({
    required this.fileName,
    required this.imported,
    required this.skipped,
    required this.importedAt,
  });
}
