import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/router.dart';
import 'core/theme.dart';
import 'core/theme_provider.dart';

/// Root widget: reactive theme (light/dark) + a STABLE GoRouter instance
/// (built once) so switching the theme never resets navigation.
class NoovaApp extends ConsumerStatefulWidget {
  const NoovaApp({super.key});

  @override
  ConsumerState<NoovaApp> createState() => _NoovaAppState();
}

class _NoovaAppState extends ConsumerState<NoovaApp> {
  final _router = buildRouter();

  @override
  Widget build(BuildContext context) {
    final mode = ref.watch(themeModeProvider);
    return MaterialApp.router(
      title: 'Noova Finance',
      debugShowCheckedModeBanner: false,
      theme: NoovaTheme.lightTheme,
      darkTheme: NoovaTheme.darkTheme,
      themeMode: mode,
      routerConfig: _router,
    );
  }
}
