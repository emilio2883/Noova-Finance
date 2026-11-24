import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme.dart';
import '../../shared/widgets/main_nav_bar.dart';

/// Settings hub: import, export, categories, budgets, reminders.
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ajustes')),
      body: ListView(
        children: [
          _section('DATOS'),
          _item(
            context,
            icon: Icons.upload_file,
            title: 'Importar Excel',
            subtitle: 'Cargar historico de Y24/Y25/Y26',
            onTap: () => context.go('/import'),
          ),
          _item(
            context,
            icon: Icons.download,
            title: 'Exportar a Excel',
            subtitle: 'Respaldo .xlsx de todas las transacciones',
            onTap: () => _export(context),
          ),
          _section('GESTION'),
          _item(
            context,
            icon: Icons.category_outlined,
            title: 'Categorias',
            subtitle: 'Crear, renombrar, ocultar, reordenar',
            onTap: () => context.go('/categories'),
          ),
          _item(
            context,
            icon: Icons.savings_outlined,
            title: 'Presupuestos',
            subtitle: 'Limites por categoria variable',
            onTap: () => context.go('/budgets'),
          ),
          _section('APP'),
          _item(
            context,
            icon: Icons.lock_outline,
            title: 'Seguridad',
            subtitle: 'PIN y biometria',
            onTap: () {}, // TODO Phase 10 wiring
          ),
          _item(
            context,
            icon: Icons.notifications_outlined,
            title: 'Recordatorio diario',
            subtitle: 'Aviso para registrar transacciones',
            onTap: () {}, // TODO Phase 13 wiring
          ),
        ],
      ),
      bottomNavigationBar: const MainNavBar(location: '/settings'),
    );
  }

  Widget _section(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
      child: Text(
        title,
        style: const TextStyle(
          color: NoovaTheme.textSecondary,
          fontSize: 12,
          letterSpacing: 1.5,
        ),
      ),
    );
  }

  Widget _item(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: ListTile(
        leading: Icon(icon, color: NoovaTheme.accent),
        title: Text(title),
        subtitle: Text(subtitle, style: const TextStyle(fontSize: 12)),
        trailing: const Icon(Icons.chevron_right, size: 18),
        onTap: onTap,
      ),
    );
  }

  Future<void> _export(BuildContext context) async {
    // TODO Phase 11: wire ExcelExporter + file save/share
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Exportacion disponible proximamente')),
    );
  }
}
