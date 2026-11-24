import 'package:isar/isar.dart';

part 'app_settings.g.dart';

/// App configuration singleton (id = 0).
@collection
class AppSettings {
  Id id = 0;

  /// Hash of the PIN (stored here; secure storage holds the raw hash)
  String? pinHash;

  bool biometricEnabled;

  bool reminderEnabled;

  /// 0-23
  int reminderHour;

  /// 0-59
  int reminderMinute;

  String defaultCurrency;

  /// Has historical Excel data been imported
  bool isImported;

  DateTime? lastExportDate;

  AppSettings({
    this.pinHash,
    this.biometricEnabled = false,
    this.reminderEnabled = false,
    this.reminderHour = 20,
    this.reminderMinute = 0,
    this.defaultCurrency = 'USD',
    this.isImported = false,
    this.lastExportDate,
  });
}
