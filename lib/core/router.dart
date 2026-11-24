import 'package:go_router/go_router.dart';

import '../features/auth/lock_screen.dart';
import '../features/dashboard/dashboard_screen.dart';
import '../features/quincenal/quincenal_screen.dart';
import '../features/charts/charts_screen.dart';
import '../features/budgets/budgets_screen.dart';
import '../features/categories/categories_screen.dart';
import '../features/import/import_screen.dart';
import '../features/settings/settings_screen.dart';

/// App navigation. Routes per plan.md:
/// /lock, /dashboard, /quincenal, /charts, /budgets, /categories, /import, /settings
final GoRouter appRouter = GoRouter(
  initialLocation: '/dashboard',
  routes: [
    GoRoute(
      path: '/lock',
      builder: (context, state) => const LockScreen(),
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
