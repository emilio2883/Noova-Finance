import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:noova_finance/theme/app_theme.dart';
import 'noova_logo.dart';

/// Bottom navigation: Consumo · Presupuestos · [N Inicio] · Metas · Ajustes.
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
                  icon: Icons.receipt_long_outlined,
                  activeIcon: Icons.receipt_long,
                  label: 'Consumo',
                  selected: location.startsWith('/quincenal'),
                  onTap: () => context.go('/quincenal'),
                ),
              ),
              Expanded(
                child: _NavItem(
                  icon: Icons.pie_chart_outline,
                  activeIcon: Icons.pie_chart,
                  label: 'Presupuestos',
                  selected: location.startsWith('/budgets'),
                  onTap: () => context.go('/budgets'),
                ),
              ),
              _CenterHome(
                selected: location.startsWith('/dashboard'),
                onTap: () => context.go('/dashboard'),
              ),
              Expanded(
                child: _NavItem(
                  icon: Icons.savings_outlined,
                  activeIcon: Icons.savings,
                  label: 'Metas',
                  selected: location.startsWith('/goals'),
                  onTap: () => context.go('/goals'),
                ),
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
            Icon(selected ? activeIcon : icon, color: color, size: 22),
            const SizedBox(height: 2),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(label,
                  style: TextStyle(
                      fontSize: 10, color: color, fontWeight: FontWeight.w500)),
            ),
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
              child: const NoovaMarkImage(size: 52),
            ),
          ),
        ),
      ),
    );
  }
}
