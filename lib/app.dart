import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/router.dart';
import 'core/theme.dart';
import 'core/theme_provider.dart';

/// Root widget: reactive theme (light/dark) + GoRouter navigation.
class NoovaApp extends ConsumerWidget {
  const NoovaApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mode = ref.watch(themeModeProvider);
    return MaterialApp.router(
      title: 'Noova Finance',
      debugShowCheckedModeBanner: false,
      theme: NoovaTheme.lightTheme,
      darkTheme: NoovaTheme.darkTheme,
      themeMode: mode,
      routerConfig: buildRouter(),
    );
  }
}
