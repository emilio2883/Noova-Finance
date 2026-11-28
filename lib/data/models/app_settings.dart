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

  /// 'dark' | 'light'
  String themeMode;

  /// True once the user explicitly picks a theme via the switch. When false
  /// the app follows the brand default (light), ignoring a stale stored value.
  bool themeChoiceMade;

  /// Optional display name for the profile greeting.
  String? userName;

  /// Has historical Excel data been imported
  bool isImported;

  /// True once the first-run onboarding has been completed/skipped.
  bool onboardingDone;

  DateTime? lastExportDate;

  AppSettings({
    this.pinHash,
    this.biometricEnabled = false,
    this.reminderEnabled = false,
    this.reminderHour = 20,
    this.reminderMinute = 0,
    this.defaultCurrency = 'USD',
    this.themeMode = 'light',
    this.themeChoiceMade = false,
    this.userName,
    this.isImported = false,
    this.onboardingDone = false,
    this.lastExportDate,
  });
}
