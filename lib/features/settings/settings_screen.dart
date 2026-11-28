import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';


import '../../core/theme_provider.dart';
import '../../data/models/budget.dart';
import '../../data/models/category.dart';
import '../../data/models/recurring_rule.dart';
import '../../data/models/transaction.dart';
import '../../data/providers.dart';
import '../dashboard/providers/dashboard_provider.dart';
import '../../shared/widgets/main_nav_bar.dart';
import 'widgets/pin_setup.dart';
import 'package:noova_finance/theme/app_theme.dart';

/// Settings hub: data, management, appearance, security.
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mode = ref.watch(themeModeProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Ajustes')),
      body: ListView(
        children: [
          _section(context, 'DATOS'),
          _item(
            context,
            icon: Icons.upload_file,
            title: 'Importar Excel',
            subtitle: 'Cargar archivo Excel de tu Estado Financiero',
            onTap: () => context.push('/import'),
          ),
          _item(
            context,
            icon: Icons.download,
            title: 'Exportar a Excel',
            subtitle: 'Guardar .xlsx en el dispositivo y abrir con Excel',
            onTap: () => _export(context, ref),
          ),
          _item(
            context,
            icon: Icons.search,
            title: 'Buscar movimientos',
            subtitle: 'Filtros por texto, categoría, fecha e importe',
            onTap: () => context.push('/search'),
          ),
          _section(context, 'GESTIÓN'),
          _item(
            context,
            icon: Icons.category_outlined,
            title: 'Categorías',
            subtitle: 'Principales y subcategorías',
            onTap: () => context.push('/categories'),
          ),
          _item(
            context,
            icon: Icons.savings_outlined,
            title: 'Presupuestos',
            subtitle: 'Límites por subcategoría',
            onTap: () => context.push('/budgets'),
          ),
          _section(context, 'APARIENCIA'),
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            child: SwitchListTile(
              secondary: Icon(Icons.dark_mode_outlined, color: context.app.colors.primary),
              title: const Text('Modo oscuro'),
              subtitle: const Text('Desactiva para modo claro',
                  style: TextStyle(fontSize: 12)),
              value: mode == ThemeMode.dark,
              onChanged: (v) => ref.read(themeModeProvider.notifier).setDark(v),
            ),
          ),
          _section(context, 'SEGURIDAD'),
          _item(
            context,
            icon: Icons.lock_outline,
            title: 'Seguridad',
            subtitle: 'PIN de acceso',
            onTap: () => showDialog(
              context: context,
              builder: (_) => const PinSetupDialog(),
            ),
          ),
          _section(context, 'PELIGRO'),
          _item(
            context,
            icon: Icons.delete_forever,
            title: 'Borrar todos los datos',
            subtitle: 'Elimina transacciones y reinicia categorías',
            color: context.app.colors.expense,
            onTap: () => _resetData(context, ref),
          ),
        ],
      ),
      bottomNavigationBar: const MainNavBar(location: '/settings'),
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

      final settingsRepo = await ref.read(settingsRepoProvider.future);
      final settings = await settingsRepo.get();
      settings.lastExportDate = DateTime.now();
      await settingsRepo.update(settings);

      if (!context.mounted) return;
      await showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Exportación lista'),
          content: Text('Archivo guardado en:\n${file.path}'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(ctx);
                OpenFilex.open(file.path);
              },
              child: const Text('Abrir'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.pop(ctx);
                Share.shareXFiles([XFile(file.path)],
                    text: 'Respaldo Noova Finance');
              },
              child: const Text('Compartir'),
            ),
          ],
        ),
      );
    } catch (e) {
      messenger.showSnackBar(SnackBar(content: Text('Error al exportar: $e')));
    }
  }

  Future<void> _resetData(BuildContext context, WidgetRef ref) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Borrar todos los datos'),
        content: const Text(
            'Se eliminarán TODAS las transacciones, presupuestos y el historial importado. Las categorías se reinician. Esta acción no se puede deshacer.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancelar')),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(backgroundColor: context.app.colors.expense),
            child: const Text('Borrar todo'),
          ),
        ],
      ),
    );
    if (ok != true) return;
    final isar = await ref.read(isarProvider.future);
    await isar.writeTxn(() async {
      await isar.transactions.clear();
      await isar.budgets.clear();
      await isar.recurringRules.clear();
      await isar.categorys.clear();
    });
    final catRepo = await ref.read(categoryRepoProvider.future);
    await catRepo.seedDefaults();
    ref.invalidate(categoryRepoProvider);
    ref.invalidate(dashboardProvider);
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Datos borrados y categorías reiniciadas')),
      );
    }
  }

  Widget _section(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
      child: Text(title,
          style: TextStyle(
              color: context.app.colors.textSecondary, fontSize: 12, letterSpacing: 1.5)),
    );
  }

  Widget _item(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    Color? color,
  }) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: ListTile(
        leading: Icon(icon, color: color ?? context.app.colors.primary),
        title: Text(title, style: TextStyle(color: color)),
        subtitle: Text(subtitle, style: const TextStyle(fontSize: 12)),
        trailing: const Icon(Icons.chevron_right, size: 18),
        onTap: onTap,
      ),
    );
  }
}
