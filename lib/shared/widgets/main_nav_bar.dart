import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:noova_finance/theme/app_theme.dart';
import 'noova_logo.dart';

/// Bottom navigation: Quincena · Gráficos · [N Inicio] · Ajustes.
/// The centre button is the Noova "N" and navigates home.
class MainNavBar extends StatelessWidget {
  final String location;

  const MainNavBar({super.key, required this.location});

  @override
  Widget build(BuildContext context) {
    final c = context.app.colors;
    return Container(
      decoration: BoxDecoration(
        color: c.surface,
        border: Border(top: BorderSide(color: c.divider)),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 66,
          child: Row(
            children: [
              Expanded(
                child: _NavItem(
                  icon: Icons.grid_view_outlined,
                  activeIcon: Icons.grid_view,
                  label: 'Quincena',
                  selected: location.startsWith('/quincenal'),
                  onTap: () => context.go('/quincenal'),
                ),
              ),
              Expanded(
                child: _NavItem(
                  icon: Icons.bar_chart_outlined,
                  activeIcon: Icons.bar_chart,
                  label: 'Gráficos',
                  selected: location.startsWith('/charts'),
                  onTap: () => context.go('/charts'),
                ),
              ),
              _CenterHome(
                selected: location.startsWith('/dashboard'),
                onTap: () => context.go('/dashboard'),
              ),
              Expanded(
                child: _NavItem(
                  icon: Icons.settings_outlined,
                  activeIcon: Icons.settings,
                  label: 'Ajustes',
                  selected: location.startsWith('/settings'),
                  onTap: () => context.go('/settings'),
                ),
              ),
              const Expanded(child: SizedBox()),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.app.colors;
    final color = selected ? c.primary : c.textSecondary;
    return Semantics(
      button: true,
      selected: selected,
      label: label,
      child: InkWell(
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(selected ? activeIcon : icon, color: color, size: 24),
            const SizedBox(height: 2),
            Text(label,
                style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }
}

class _CenterHome extends StatelessWidget {
  final bool selected;
  final VoidCallback onTap;

  const _CenterHome({required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final c = context.app.colors;
    return Semantics(
      button: true,
      selected: selected,
      label: 'Inicio',
      child: InkResponse(
        onTap: onTap,
        radius: 38,
        child: SizedBox(
          width: 64,
          child: Center(
            child: Transform.translate(
              offset: const Offset(0, -8),
              child: NoovaMark(
                size: 52,
                circle: true,
                background: c.primary,
                foreground: c.textOnPrimary,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
