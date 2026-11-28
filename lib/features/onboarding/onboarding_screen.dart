import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:noova_finance/theme/app_theme.dart';
import '../../theme/app_motion.dart';
import '../../core/app_flags.dart';
import '../../data/providers.dart';

/// First-run guided onboarding (3 steps). Sets AppSettings.onboardingDone=true.
class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  int _step = 0;
  bool _wantsImport = false;

  Future<void> _finish() async {
    final repo = await ref.read(settingsRepoProvider.future);
    final settings = await repo.get();
    settings.onboardingDone = true;
    await repo.update(settings);
    AppFlags.onboardingDone = true;
    if (!mounted) return;
    context.go(_wantsImport ? '/import' : '/dashboard');
  }

  @override
  Widget build(BuildContext context) {
    final app = context.app;
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(app.spacing.lg),
          child: AnimatedSwitcher(
            duration: AppMotion.medium,
            child: _buildStep(app),
          ),
        ),
      ),
    );
  }

  Widget _buildStep(AppTheme app) {
    switch (_step) {
      case 0:
        return _stepColumn(
          key: 's0',
          app: app,
          icon: Icons.account_balance_wallet_outlined,
          title: 'Bienvenido a Noova Finance',
          body: 'Controla tus finanzas personales, 100% offline. '
              'Registra gastos en segundos y entiende tu dinero por quincena, mes y año.',
          action: FilledButton(
            onPressed: () => setState(() => _step = 1),
            child: const Text('Comenzar'),
          ),
        );
      case 1:
        return _stepColumn(
          key: 's1',
          app: app,
          icon: Icons.rocket_launch_outlined,
          title: '¿Cómo quieres empezar?',
          body: 'Puedes importar tu Excel de finanzas o comenzar desde cero y crear tus categorías.',
          action: Column(
            children: [
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: () => setState(() {
                    _wantsImport = true;
                    _step = 2;
                  }),
                  icon: const Icon(Icons.upload_file),
                  label: const Text('Importar mi Excel'),
                ),
              ),
              SizedBox(height: app.spacing.sm),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => setState(() {
                    _wantsImport = false;
                    _step = 2;
                  }),
                  icon: const Icon(Icons.edit_note),
                  label: const Text('Empezar de cero'),
                ),
              ),
            ],
          ),
        );
      default:
        return _stepColumn(
          key: 's2',
          app: app,
          icon: Icons.lock_outline,
          title: 'Protege tu app (opcional)',
          body: 'Puedes activar un PIN o biometría más tarde en Ajustes → Seguridad. '
              'Tus datos se guardan solo en tu dispositivo.',
          action: FilledButton(
            onPressed: _finish,
            child: const Text('Listo'),
          ),
        );
    }
  }

  Widget _stepColumn({
    required String key,
    required AppTheme app,
    required IconData icon,
    required String title,
    required String body,
    required Widget action,
  }) {
    return Column(
      key: ValueKey(key),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Spacer(),
        Icon(icon, size: 72, color: app.colors.primary),
        SizedBox(height: app.spacing.lg),
        Text(title,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
        SizedBox(height: app.spacing.md),
        Text(body,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: app.colors.textSecondary)),
        const Spacer(),
        action,
        SizedBox(height: app.spacing.md),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            for (var i = 0; i < 3; i++)
              Container(
                width: 8,
                height: 8,
                margin: EdgeInsets.symmetric(horizontal: app.spacing.xs),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: i == _step
                      ? app.colors.primary
                      : app.colors.divider,
                ),
              ),
          ],
        ),
      ],
    );
  }
}
