import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme.dart';
import '../../../data/providers.dart';

/// PIN setup / change / disable dialog (US8).
/// Stores the PIN in AppSettings.pinHash (local-only MVP).
class PinSetupDialog extends ConsumerStatefulWidget {
  const PinSetupDialog({super.key});

  @override
  ConsumerState<PinSetupDialog> createState() => _PinSetupDialogState();
}

class _PinSetupDialogState extends ConsumerState<PinSetupDialog> {
  bool _hasPin = false;

  @override
  void initState() {
    super.initState();
    _loadCurrent();
  }

  Future<void> _loadCurrent() async {
    final repo = await ref.read(settingsRepoProvider.future);
    final settings = await repo.get();
    if (mounted) {
      setState(() => _hasPin = settings.pinHash?.isNotEmpty ?? false);
    }
  }

  Future<void> _disablePin() async {
    final repo = await ref.read(settingsRepoProvider.future);
    final settings = await repo.get();
    settings.pinHash = null;
    settings.biometricEnabled = false;
    await repo.update(settings);
    if (mounted) Navigator.pop(context, 'disabled');
  }

  Future<void> _promptPin({required bool isChange}) async {
    final first = await _askPin(
      title: isChange ? 'PIN actual' : 'Nuevo PIN',
      confirmLabel: 'Continuar',
    );
    if (first == null || first.length < 4) return;

    if (isChange) {
      // Verify current PIN first
      final repo = await ref.read(settingsRepoProvider.future);
      final settings = await repo.get();
      if (first != settings.pinHash) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('PIN incorrecto')),
          );
        }
        return;
      }
      final newPin = await _askPin(
        title: 'Nuevo PIN',
        confirmLabel: 'Guardar',
      );
      if (newPin != null && newPin.length >= 4) {
        await _savePin(newPin);
      }
      return;
    }

    final confirm = await _askPin(
      title: 'Confirmar PIN',
      confirmLabel: 'Guardar',
    );
    if (confirm == first) {
      await _savePin(first);
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Los PIN no coinciden')),
      );
    }
  }

  Future<void> _savePin(String pin) async {
    final repo = await ref.read(settingsRepoProvider.future);
    final settings = await repo.get();
    settings.pinHash = pin;
    await repo.update(settings);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('PIN guardado')),
      );
      Navigator.pop(context, 'saved');
    }
  }

  Future<String?> _askPin({
    required String title,
    required String confirmLabel,
  }) {
    final controller = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: NoovaTheme.surface,
        title: Text(title),
        content: TextField(
          controller: controller,
          autofocus: true,
          keyboardType: TextInputType.number,
          obscureText: true,
          maxLength: 6,
          decoration: const InputDecoration(
            labelText: 'PIN (4-6 dígitos)',
            counterText: '',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, controller.text),
            child: Text(confirmLabel),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: NoovaTheme.surface,
      title: const Text('Seguridad'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(_hasPin
              ? 'Tienes un PIN configurado.'
              : 'Configura un PIN para bloquear la app.'),
          const SizedBox(height: 16),
          if (_hasPin) ...[
            FilledButton.icon(
              onPressed: () => _promptPin(isChange: true),
              icon: const Icon(Icons.edit_outlined),
              label: const Text('Cambiar PIN'),
            ),
            const SizedBox(height: 8),
            TextButton.icon(
              onPressed: _disablePin,
              icon: const Icon(Icons.lock_open, color: NoovaTheme.expense),
              label: const Text('Quitar PIN',
                  style: TextStyle(color: NoovaTheme.expense)),
            ),
          ] else
            FilledButton.icon(
              onPressed: () => _promptPin(isChange: false),
              icon: const Icon(Icons.lock_outline),
              label: const Text('Configurar PIN'),
            ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cerrar'),
        ),
      ],
    );
  }
}
