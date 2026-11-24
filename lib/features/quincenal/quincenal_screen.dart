import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme.dart';
import '../../shared/widgets/main_nav_bar.dart';
import '../../core/utils/date_utils.dart';
import '../../core/utils/money_format.dart';
import '../../data/models/transaction.dart';
import '../../data/providers.dart';
import '../../data/services/saldo_calculator.dart';

/// Quincenal view: all categories + totals for the selected quincena (US5).
class QuincenalScreen extends ConsumerStatefulWidget {
  const QuincenalScreen({super.key});

  @override
  ConsumerState<QuincenalScreen> createState() => _QuincenalScreenState();
}

class _QuincenalScreenState extends State<QuincenalScreen> {
  DateTime _selected = DateTime.now();

  void _shiftQuincena(int direction) {
    setState(() {
      if (direction > 0) {
        _selected = _selected.day <= 15
            ? DateTime(_selected.year, _selected.month, 16)
            : DateTime(_selected.year, _selected.month + 1, 1);
      } else {
        _selected = _selected.day <= 15
            ? DateTime(_selected.year, _selected.month - 1, 16)
            : DateTime(_selected.year, _selected.month, 1);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final txnsAsync = ref.watch(transactionRepoProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(QuincenaUtils.quincenaLabel(_selected)),
        actions: [
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: () => _shiftQuincena(-1),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: () => _shiftQuincena(1),
          ),
        ],
      ),
      body: txnsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (repo) => FutureBuilder<List<Transaction>>(
          future: repo.getByDateRange(
            QuincenaUtils.quincenaStart(_selected),
            QuincenaUtils.quincenaEnd(_selected),
          ),
          builder: (context, snapshot) {
            final txns = snapshot.data ?? [];
            final start = QuincenaUtils.quincenaStart(_selected);
            final end = QuincenaUtils.quincenaEnd(_selected);
            final ingresos = SaldoCalculator.ingresos(txns, start, end);
            final gastos = SaldoCalculator.gastos(txns, start, end);
            final utilidad = ingresos - gastos;

            // Group by category
            final byCategory = <int, Decimal>{};
            for (final t in txns) {
              byCategory[t.categoryId] =
                  (byCategory[t.categoryId] ?? Decimal.zero) + t.amount;
            }

            return ListView(
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _total('Ingresos', ingresos, NoovaTheme.income),
                        _total('Gastos', gastos, NoovaTheme.expense),
                        _total(
                          'Utilidad',
                          utilidad,
                          utilidad >= Decimal.zero
                              ? NoovaTheme.income
                              : NoovaTheme.expense,
                        ),
                      ],
                    ),
                  ),
                ),
                Card(
                  child: Column(
                    children: [
                      for (final entry in byCategory.entries)
                        ListTile(
                          dense: true,
                          title: FutureBuilder<String>(
                            future: _categoryName(entry.key),
                            builder: (c, s) =>
                                Text(s.data ?? '...'),
                          ),
                          trailing: Text(
                            MoneyFormat.format(entry.value),
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      if (txns.isEmpty)
                        const Padding(
                          padding: EdgeInsets.all(24),
                          child: Text('Sin transacciones en esta quincena'),
                        ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
      bottomNavigationBar: const MainNavBar(location: '/quincenal'),
    );
  }

  Future<String> _categoryName(int id) async {
    final repo = await ref.read(categoryRepoProvider.future);
    final cat = await repo.getById(id);
    return cat?.name ?? 'Sin categoria';
  }

  Widget _total(String label, Decimal value, Color color) {
    return Column(
      children: [
        Text(label.toUpperCase(),
            style: const TextStyle(
                color: NoovaTheme.textSecondary, fontSize: 10)),
        Text(MoneyFormat.format(value),
            style: TextStyle(
                color: color, fontWeight: FontWeight.bold, fontSize: 15)),
      ],
    );
  }
}
