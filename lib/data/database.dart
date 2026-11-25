import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';

import 'models/app_settings.dart';
import 'models/budget.dart';
import 'models/category.dart';
import 'models/import_record.dart';
import 'models/recurring_rule.dart';
import 'models/transaction.dart';

/// Isar database setup. Offline-first: all data lives on device.
class AppDatabase {
  static Isar? _instance;

  static Future<Isar> get instance async {
    if (_instance != null) return _instance!;
    final dir = await getApplicationDocumentsDirectory();
    _instance = await Isar.open(
      [
        TransactionSchema,
        CategorySchema,
        RecurringRuleSchema,
        BudgetSchema,
        AppSettingsSchema,
        ImportRecordSchema,
      ],
      directory: dir.path,
      name: 'noova_finance',
    );
    return _instance!;
  }

  /// For tests: inject a mock/test instance.
  static void setInstanceForTesting(Isar isar) {
    _instance = isar;
  }

  static Future<void> close() async {
    await _instance?.close();
    _instance = null;
  }
}
