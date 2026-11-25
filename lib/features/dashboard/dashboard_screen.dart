import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme.dart';
import '../../core/utils/money_format.dart';
import 'providers/dashboard_provider.dart';
import 'widgets/quick_add_button.dart';
import 'widgets/recent_transactions.dart';
import 'widgets/saldo_card.dart';
import '../../shared/widgets/main_nav_bar.dart';
import 'widgets/utilidad_card.dart';

/// Home dashboard: saldo, monthly utilidad, recent transactions, quick-add FAB.
class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashboardAsync = ref.watch(dashboardProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Noova Finance'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => context.go('/settings'),
          ),
        ],
      ),
      body: dashboardAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (d) => RefreshIndicator(
          onRefresh: () async => ref.invalidate(dashboardProvider),
          child: ListView(
            padding: const EdgeInsets.only(bottom: 96),
            children: [
              SaldoCard(saldoFormatted: MoneyFormat.format(d.saldo)),
              UtilidadCard(
                ingresos: MoneyFormat.compact(d.ingresosMes),
                gastos: MoneyFormat.compact(d.gastosMes),
                utilidad: MoneyFormat.compact(d.utilidadMes),
                utilidadPositiva: d.utilidadMes >= Decimal.zero,
              ),
              const Padding(
                padding: EdgeInsets.fromLTRB(20, 12, 20, 4),
                child: Text(
                  'TRANSACCIONES RECIENTES',
                  style: TextStyle(
                    color: NoovaTheme.textSecondary,
                    fontSize: 12,
                    letterSpacing: 1.5,
                  ),
                ),
              ),
              RecentTransactions(
                transactions: d.recent,
                onTap: (t) => _showTransactionDetail(context, t),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: const QuickAddButton(),
      bottomNavigationBar: const MainNavBar(location: '/dashboard'),
    );
  }

  void _showTransactionDetail(BuildContext context, dynamic t) {
    // TODO Phase 5+: full edit/delete detail sheet
    showModalBottomSheet(
      context: context,
      backgroundColor: NoovaTheme.surface,
      builder: (_) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Transacción #${t.id}'),
            const SizedBox(height: 8),
            Text('Monto: ${t.amount}'),
            Text('Fecha: ${t.date.day}/${t.date.month}/${t.date.year}'),
          ],
        ),
      ),
    );
  }
}
