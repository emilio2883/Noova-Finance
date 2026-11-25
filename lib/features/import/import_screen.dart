import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme.dart';
import '../../data/providers.dart';
import '../../data/services/excel_importer.dart';

/// Excel import screen: pick file -> import -> report (spec US2).
class ImportScreen extends ConsumerStatefulWidget {
  const ImportScreen({super.key});

  @override
  ConsumerState<ImportScreen> createState() => _ImportScreenState();
}

class _ImportScreenState extends ConsumerState<ImportScreen> {
  bool _importing = false;
  ImportResult? _result;

  Future<void> _pickAndImport() async {
    final picked = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['xlsx'],
      withData: true,
    );
    if (picked == null || picked.files.single.bytes == null) return;

    setState(() {
      _importing = true;
      _result = null;
    });

    final importer = await ref.read(excelImporterProvider.future);

    final result = await importer.importBytes(
      picked.files.single.bytes!,
    );

    // Mark settings as imported
    final settingsRepo = await ref.read(settingsRepoProvider.future);
    final settings = await settingsRepo.get();
    settings.isImported = true;
    await settingsRepo.update(settings);

    if (mounted) {
      setState(() {
        _importing = false;
        _result = result;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final result = _result;
    return Scaffold(
      appBar: AppBar(title: const Text('Importar Excel')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Importa tu archivo Estado Financiero-2.xlsx con las hojas '
              'Y24, Y25 y Y26. La importacion es segura: re-importar no '
              'duplica transacciones.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: _importing ? null : _pickAndImport,
              icon: _importing
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.upload_file),
              label: Text(_importing ? 'Importando...' : 'Seleccionar archivo'),
            ),
            const SizedBox(height: 24),
            if (result != null) ...[
              if (result.success) ...[
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.check_circle,
                                color: NoovaTheme.income),
                            const SizedBox(width: 8),
                            Text(
                              'Importacion completada',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text('Transacciones importadas: \${result.imported}'),
                        Text('Duplicados omitidos: \${result.skippedDuplicates}'),
                        if (result.unknownRows.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Text(
                            'Filas no reconocidas (omitidas): '
                            '\${result.unknownRows.join(", ")}',
                            style:
                                const TextStyle(color: NoovaTheme.textSecondary),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ] else
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      'Error al importar: \${result.error}',
                      style: const TextStyle(color: NoovaTheme.expense),
                    ),
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }
}
