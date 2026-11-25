import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:path_provider/path_provider.dart';

import '../../core/theme.dart';
import '../../data/providers.dart';
import '../../shared/widgets/main_nav_bar.dart';
import 'widgets/pin_setup.dart';
import 'widgets/reminder_config.dart';

/// Settings hub: import, export, categories, budgets, security, reminders.
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
            onTap: () => _export(context, ref),
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
            subtitle: 'Configurar PIN de acceso',
            onTap: () => _openPinSetup(context),
          ),
          const ReminderConfig(),
        ],
      ),
      bottomNavigationBar: const MainNavBar(location: '/settings'),
    );
  }

  Future<void> _openPinSetup(BuildContext context) async {
    await showDialog(
      context: context,
      builder: (_) => const PinSetupDialog(),
    );
  }

  Future<void> _export(BuildContext context, WidgetRef ref) async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      final exporter = await ref.read(excelExporterProvider.future);
      final bytes = await exporter.export();

      final dir = await getApplicationDocumentsDirectory();
      final now = DateTime.now();
      final name =
          'noova_finance_${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}.xlsx';
      final file = File('${dir.path}/$name');
      await file.writeAsBytes(bytes);

      // Record last export
      final settingsRepo = await ref.read(settingsRepoProvider.future);
      final settings = await settingsRepo.get();
      settings.lastExportDate = DateTime.now();
      await settingsRepo.update(settings);

      messenger.showSnackBar(
        SnackBar(
          content: Text('Exportado: ${file.path}'),
          duration: const Duration(seconds: 5),
        ),
      );
    } catch (e) {
      messenger.showSnackBar(
        SnackBar(content: Text('Error al exportar: $e')),
      );
    }
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
}
