import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme.dart';

/// Bottom navigation for the main tabs: Dashboard, Quincenal, Graficos, Ajustes.
class MainNavBar extends StatelessWidget {
  final String location;

  const MainNavBar({super.key, required this.location});

  int get _index {
    if (location.startsWith('/quincenal')) return 1;
    if (location.startsWith('/charts')) return 2;
    if (location.startsWith('/settings')) return 3;
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    return NavigationBar(
      backgroundColor: Theme.of(context).colorScheme.surface,
      selectedIndex: _index,
      indicatorColor: NoovaTheme.accent.withValues(alpha: 0.15),
      onDestinationSelected: (i) {
        switch (i) {
          case 0:
            context.go('/dashboard');
          case 1:
            context.go('/quincenal');
          case 2:
            context.go('/charts');
          case 3:
            context.go('/settings');
        }
      },
      destinations: const [
        NavigationDestination(
          icon: Icon(Icons.home_outlined),
          selectedIcon: Icon(Icons.home, color: NoovaTheme.accent),
          label: 'Inicio',
        ),
        NavigationDestination(
          icon: Icon(Icons.grid_view_outlined),
          selectedIcon: Icon(Icons.grid_view, color: NoovaTheme.accent),
          label: 'Quincena',
        ),
        NavigationDestination(
          icon: Icon(Icons.bar_chart_outlined),
          selectedIcon: Icon(Icons.bar_chart, color: NoovaTheme.accent),
          label: 'Graficos',
        ),
        NavigationDestination(
          icon: Icon(Icons.settings_outlined),
          selectedIcon: Icon(Icons.settings, color: NoovaTheme.accent),
          label: 'Ajustes',
        ),
      ],
    );
  }
}
