import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:noova_finance/theme/app_theme.dart';
import '../../data/providers.dart';

/// Right-side header: "Hola, {name}!" + avatar. Tap avatar to set the name.
class ProfileGreeting extends ConsumerWidget {
  const ProfileGreeting({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.app.colors;
    final settingsAsync = ref.watch(settingsRepoProvider);
    return settingsAsync.maybeWhen(
      data: (repo) => FutureBuilder(
        future: repo.get(),
        builder: (context, snap) {
          final user = snap.data?.userName;
          final trimmed = (user ?? '').trim();
          final hasName = trimmed.isNotEmpty;
          final display = hasName ? trimmed : 'tú';
          final initial = hasName ? trimmed.substring(0, 1).toUpperCase() : 'U';
          return Row(mainAxisSize: MainAxisSize.min, children: [
            Text('Hola, $display!',
                style: TextStyle(
                    color: c.onHero,
                    fontWeight: FontWeight.w600,
                    fontSize: 14)),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: () => _editName(context, ref),
              child: CircleAvatar(
                radius: 16,
                backgroundColor: c.primary,
                child: Text(initial,
                    style: TextStyle(
                        color: c.textOnPrimary, fontWeight: FontWeight.bold)),
              ),
            ),
          ]);
        },
      ),
      orElse: () => const SizedBox.shrink(),
    );
  }

  Future<void> _editName(BuildContext context, WidgetRef ref) async {
    final repo = await ref.read(settingsRepoProvider.future);
    final s = await repo.get();
    if (!context.mounted) return;
    final ctrl = TextEditingController(text: s.userName ?? '');
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Tu nombre'),
        content: TextField(
            controller: ctrl,
            decoration: const InputDecoration(labelText: '¿Cómo te llamas?')),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancelar')),
          FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Guardar')),
        ],
      ),
    );
    if (ok == true) {
      final v = ctrl.text.trim();
      s.userName = v.isEmpty ? null : v;
      await repo.update(s);
      ref.invalidate(settingsRepoProvider);
    }
  }
}
