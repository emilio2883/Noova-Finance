import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:isar/isar.dart';


import '../../data/models/import_record.dart';
import '../../data/providers.dart';
import '../../data/services/excel_importer.dart';
import '../dashboard/providers/dashboard_provider.dart';
import 'package:noova_finance/theme/app_theme.dart';

/// Excel import: pick file -> import -> log + history (US2).
/// Keep a record of every imported file so multiple sources can be tracked.
class ImportScreen extends ConsumerStatefulWidget {
  const ImportScreen({super.key});

  @override
  ConsumerState<ImportScreen> createState() => _ImportScreenState();
}

class _ImportScreenState extends ConsumerState<ImportScreen> {
  bool _importing = false;
  ImportResult? _result;
  String? _lastFile;
  List<ImportRecord> _records = [];

  @override
  void initState() {
    super.initState();
    _loadRecords();
  }

  Future<void> _loadRecords() async {
    final isar = await ref.read(isarProvider.future);
    final recs = await isar.importRecords.where().findAll();
    recs.sort((a, b) => b.importedAt.compareTo(a.importedAt));
    if (mounted) setState(() => _records = recs);
  }

  Future<void> _pickAndImport() async {
    final picked = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['xlsx'],
      withData: true,
    );
    if (picked == null || picked.files.single.bytes == null) return;
    final fileName = picked.files.single.name;

    setState(() {
      _importing = true;
      _result = null;
      _lastFile = fileName;
    });

    final importer = await ref.read(excelImporterProvider.future);
    final result = await importer.importBytes(
      picked.files.single.bytes!,
      sourceName: fileName,
    );

    // Persist an import record + mark settings imported
    final isar = await ref.read(isarProvider.future);
    if (result.success) {
      await isar.writeTxn(() async {
        await isar.importRecords.put(ImportRecord(
          fileName: fileName,
          imported: result.imported,
          skipped: result.skippedDuplicates,
          importedAt: DateTime.now(),
        ));
      });
      final settingsRepo = await ref.read(settingsRepoProvider.future);
      final settings = await settingsRepo.get();
      settings.isImported = true;
      await settingsRepo.update(settings);
    }

    if (mounted) {
      setState(() {
        _importing = false;
        _result = result;
      });
      // Refresh every data view so new rows (e.g. Impuestos) show immediately.
      ref.invalidate(dashboardProvider);
      await _loadRecords();
    }
  }

  @override
  Widget build(BuildContext context) {
    final result = _result;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Importar Excel'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.canPop() ? context.pop() : context.go('/settings'),
        ),
        actions: [
          TextButton(
            onPressed: () => context.canPop() ? context.pop() : context.go('/settings'),
            child: const Text('Ajustes'),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text(
            'Selecciona tu archivo Excel de finanzas. Puedes importar varios '
            'archivos; cada importación queda registrada y no duplica datos '
            'del mismo archivo.',
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          FilledButton.icon(
            onPressed: _importing ? null : _pickAndImport,
            icon: _importing
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.upload_file),
            label: Text(_importing ? 'Importando…' : 'Seleccionar archivo'),
          ),
          if (result != null) ...[
            const SizedBox(height: 20),
            if (result.success)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.check_circle, color: context.app.colors.income),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text('Importación completada',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(fontWeight: FontWeight.bold)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text('Archivo: ${_lastFile ?? ''}'),
                      Text('Transacciones importadas: ${result.imported}'),
                      Text('Duplicados omitidos: ${result.skippedDuplicates}'),
                      if (result.unknownRows.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Text('Filas no reconocidas: ${result.unknownRows.join(", ")}',
                            style: TextStyle(color: context.app.colors.textSecondary)),
                      ],
                      const SizedBox(height: 12),
                      Align(
                        alignment: Alignment.centerRight,
                        child: FilledButton.icon(
                          onPressed: () =>
                              context.canPop() ? context.pop() : context.go('/settings'),
                          icon: const Icon(Icons.check),
                          label: const Text('Volver a Ajustes'),
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text('Error al importar: ${result.error}',
                      style: TextStyle(color: context.app.colors.expense)),
                ),
              ),
          ],
          const SizedBox(height: 24),
          Text('HISTORIAL DE IMPORTACIONES',
              style: TextStyle(
                  color: context.app.colors.textSecondary,
                  fontSize: 12,
                  letterSpacing: 1.5)),
          const SizedBox(height: 8),
          if (_records.isEmpty)
            Padding(
              padding: const EdgeInsets.all(12),
              child: Text('Aún no has importado archivos.',
                  style: TextStyle(fontSize: 12, color: context.app.colors.textSecondary)),
            )
          else
            for (final r in _records)
              Card(
                child: ListTile(
                  leading: Icon(Icons.description_outlined, color: context.app.colors.primary),
                  title: Text(r.fileName, style: const TextStyle(fontSize: 14)),
                  subtitle: Text(
                    '${r.importedAt.day}/${r.importedAt.month}/${r.importedAt.year} · '
                    '${r.imported} importadas · ${r.skipped} duplicadas',
                    style: const TextStyle(fontSize: 11),
                  ),
                  trailing: IconButton(
                    tooltip: 'Borrar del historial',
                    icon: Icon(Icons.delete_outline, color: context.app.colors.expense),
                    onPressed: () async {
                      final isar = await ref.read(isarProvider.future);
                      await isar.writeTxn(() => isar.importRecords.delete(r.id));
                      await _loadRecords();
                    },
                  ),
                ),
              ),
        ],
      ),
    );
  }
}
