import 'package:flutter/material.dart';

import 'core/router.dart';
import 'core/theme.dart';

/// Root widget: dark theme + GoRouter navigation.
class NoovaApp extends StatelessWidget {
  const NoovaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Noova Finance',
      debugShowCheckedModeBanner: false,
      theme: NoovaTheme.darkTheme,
      routerConfig: appRouter,
    );
  }
}
