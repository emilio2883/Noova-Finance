import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../data/providers.dart';
import '../features/auth/lock_screen.dart';
import '../features/budgets/budgets_screen.dart';
import '../features/categories/categories_screen.dart';
import '../features/charts/charts_screen.dart';
import '../features/dashboard/dashboard_screen.dart';
import '../features/import/import_screen.dart';
import '../features/quincenal/quincenal_screen.dart';
import '../features/settings/settings_screen.dart';

/// App navigation with optional PIN lock redirect.
/// Routes: /lock, /dashboard, /quincenal, /charts, /budgets,
/// /categories, /import, /settings
GoRouter buildRouter() {
  return GoRouter(
    initialLocation: '/dashboard',
    redirect: (context, state) {
      // Auth redirect is wired in Phase 10 (US8); default open for now.
      return null;
    },
    routes: [
      GoRoute(
        path: '/lock',
        builder: (context, state) => const LockGate(),
      ),
      GoRoute(
        path: '/dashboard',
        builder: (context, state) => const DashboardScreen(),
      ),
      GoRoute(
        path: '/quincenal',
        builder: (context, state) => const QuincenalScreen(),
      ),
      GoRoute(
        path: '/charts',
        builder: (context, state) => const ChartsScreen(),
      ),
      GoRoute(
        path: '/budgets',
        builder: (context, state) => const BudgetsScreen(),
      ),
      GoRoute(
        path: '/categories',
        builder: (context, state) => const CategoriesScreen(),
      ),
      GoRoute(
        path: '/import',
        builder: (context, state) => const ImportScreen(),
      ),
      GoRoute(
        path: '/settings',
        builder: (context, state) => const SettingsScreen(),
      ),
    ],
  );
}

/// Wraps LockScreen with settings lookup.
class LockGate extends ConsumerWidget {
  const LockGate({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settingsAsync = ref.watch(settingsRepoProvider);
    return settingsAsync.when(
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => Scaffold(body: Center(child: Text('Error: $e'))),
      data: (repo) => FutureBuilder(
        future: repo.get(),
        builder: (context, snap) {
          final pin = snap.data?.pinHash;
          if (pin == null || pin.isEmpty) {
            // No PIN configured: go straight to dashboard
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (context.mounted) context.go('/dashboard');
            });
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }
          return LockScreen(
            pinHash: pin,
            onUnlocked: () => context.go('/dashboard'),
          );
        },
      ),
    );
  }
}
