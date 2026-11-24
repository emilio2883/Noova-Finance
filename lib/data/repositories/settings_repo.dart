import 'package:isar/isar.dart';

import '../models/app_settings.dart';

/// Singleton AppSettings (id = 0).
class SettingsRepository {
  final Isar _isar;
  SettingsRepository(this._isar);

  Future<AppSettings> get() async =>
      await _isar.appSettings.get(0) ?? AppSettings();

  Future<void> update(AppSettings s) =>
      _isar.writeTxn(() => _isar.appSettings.put(s));
}
