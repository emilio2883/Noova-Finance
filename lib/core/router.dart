import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../data/providers.dart';
import 'app_flags.dart';
import '../features/auth/lock_screen.dart';
import '../features/budgets/budgets_screen.dart';
import '../features/categories/categories_screen.dart';
import '../features/dashboard/dashboard_screen.dart';
import '../features/goals/goals_screen.dart';
import '../features/charts/charts_screen.dart';
import '../features/import/import_screen.dart';
import '../features/onboarding/onboarding_screen.dart';
import '../features/search/search_screen.dart';
import '../features/recurring/recurring_screen.dart';
import '../features/subscriptions/subscriptions_screen.dart';
import '../features/quincenal/quincenal_screen.dart';
import '../features/settings/settings_screen.dart';

/// Session-level auth state. [pinRequired] is cached once at startup
/// (main.dart reads settings after opening the DB); [unlocked] resets
/// on every app restart.
class UnlockState {
  UnlockState._();
  static final UnlockState instance = UnlockState._();
  bool pinRequired = false;
  bool unlocked = false;
}

/// App navigation with PIN lock redirect (US8).
GoRouter buildRouter() {
  return GoRouter(
    initialLocation: '/dashboard',
    redirect: (context, state) {
      final loc = state.matchedLocation;
      if (loc == '/lock') return null;
      if (UnlockState.instance.pinRequired && !UnlockState.instance.unlocked) {
        return '/lock';
      }
      if (!AppFlags.onboardingDone && loc != '/onboarding') {
        return '/onboarding';
      }
      if (AppFlags.onboardingDone && loc == '/onboarding') {
        return '/dashboard';
      }
      return null;
    },
    routes: [
      GoRoute(
        path: '/lock',
        builder: (context, state) => const LockGate(),
      ),
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingScreen(),
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
        path: '/search',
        builder: (context, state) => const SearchScreen(),
      ),
      GoRoute(
        path: '/recurring',
        builder: (context, state) => const RecurringScreen(),
      ),
      GoRoute(
        path: '/subscriptions',
        builder: (context, state) => const SubscriptionsScreen(),
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
        path: '/goals',
        builder: (context, state) => const GoalsScreen(),
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
            onUnlocked: () {
              UnlockState.instance.unlocked = true;
              context.go('/dashboard');
            },
          );
        },
      ),
    );
  }
}
