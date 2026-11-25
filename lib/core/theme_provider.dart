import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/providers.dart';

/// App-wide theme mode, persisted in AppSettings ('dark' | 'light').
class ThemeModeNotifier extends StateNotifier<ThemeMode> {
  final Ref _ref;
  ThemeModeNotifier(this._ref) : super(ThemeMode.dark) {
    _load();
  }

  Future<void> _load() async {
    try {
      final repo = await _ref.read(settingsRepoProvider.future);
      final s = await repo.get();
      state = s.themeMode == 'light' ? ThemeMode.light : ThemeMode.dark;
    } catch (_) {}
  }

  Future<void> setDark(bool dark) async {
    state = dark ? ThemeMode.dark : ThemeMode.light;
    try {
      final repo = await _ref.read(settingsRepoProvider.future);
      final s = await repo.get();
      s.themeMode = dark ? 'dark' : 'light';
      await repo.update(s);
    } catch (_) {}
  }
}

final themeModeProvider =
    StateNotifierProvider<ThemeModeNotifier, ThemeMode>((ref) {
  return ThemeModeNotifier(ref);
});
