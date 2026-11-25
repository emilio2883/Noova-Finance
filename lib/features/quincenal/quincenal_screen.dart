import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme.dart';
import '../../core/utils/date_utils.dart';
import '../../core/utils/money_format.dart';
import '../../data/models/category.dart';
import '../../data/models/transaction.dart';
import '../../data/providers.dart';
import '../../data/services/saldo_calculator.dart';
import '../../shared/widgets/main_nav_bar.dart';
import '../transaction/quick_add_modal.dart';
import '../transaction/transaction_detail_screen.dart';

class _QuincenaData {
  final List<Transaction> txns;
  final Map<int, Category> categories;
  final List<Category> leaves;
  final DateTime start;
  final DateTime end;
  _QuincenaData(this.txns, this.categories, this.leaves, this.start, this.end);
}

/// Quincena hub: transactions list + category filter + add button (US3/US5).
class QuincenalScreen extends ConsumerStatefulWidget {
  const QuincenalScreen({super.key});

  @override
  ConsumerState<QuincenalScreen> createState() => _QuincenalScreenState();
}

class _QuincenalScreenState extends ConsumerState<QuincenalScreen> {
  DateTime _selected = DateTime.now();
  int? _filterCategoryId;

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

  Future<_QuincenaData> _load() async {
    final txnRepo = await ref.read(transactionRepoProvider.future);
    final catRepo = await ref.read(categoryRepoProvider.future);
    final start = QuincenaUtils.quincenaStart(_selected);
    final end = QuincenaUtils.quincenaEnd(_selected);
    final txns = await txnRepo.getByDateRange(start, end);
    final cats = await catRepo.getAll();
    final leaves = [
      ...await catRepo.getLeaves(TransactionType.expense),
      ...await catRepo.getLeaves(TransactionType.income),
    ];
    return _QuincenaData(
      txns,
      {for (final c in cats) c.id: c},
      leaves,
      start,
      end,
    );
  }

  Future<void> _openAdd() async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => const QuickAddModal(),
    );
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
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
      floatingActionButton: FloatingActionButton(
        onPressed: _openAdd,
        backgroundColor: NoovaTheme.accent,
        foregroundColor: Colors.black,
        child: const Icon(Icons.add),
      ),
      body: FutureBuilder<_QuincenaData>(
        future: _load(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final data = snapshot.data!;
          var txns = data.txns;
          if (_filterCategoryId != null) {
            txns = txns.where((t) => t.categoryId == _filterCategoryId).toList();
          }

          final ingresos = SaldoCalculator.ingresos(data.txns, data.start, data.end);
          final gastos = SaldoCalculator.gastos(data.txns, data.start, data.end);
          final utilidad = ingresos - gastos;

          return Column(
            children: [
              // Totals
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _total('Ingresos', ingresos, NoovaTheme.income),
                      _total('Gastos', gastos, NoovaTheme.expense),
                      _total('Utilidad', utilidad,
                          utilidad >= Decimal.zero ? NoovaTheme.income : NoovaTheme.expense),
                    ],
                  ),
                ),
              ),
              // Category filter
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    const Icon(Icons.filter_list, size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: DropdownButton<int?>(
                        isExpanded: true,
                        value: _filterCategoryId,
                        hint: const Text('Todas las categorías'),
                        dropdownColor: Theme.of(context).colorScheme.surface,
                        items: [
                          const DropdownMenuItem<int?>(
                            value: null,
                            child: Text('Todas las categorías'),
                          ),
                          for (final c in data.leaves)
                            DropdownMenuItem<int?>(
                              value: c.id,
                              child: Text(c.name),
                            ),
                        ],
                        onChanged: (v) => setState(() => _filterCategoryId = v),
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              // Transactions
              Expanded(
                child: txns.isEmpty
                    ? const Center(child: Text('Sin transacciones en esta quincena'))
                    : ListView.builder(
                        padding: const EdgeInsets.only(bottom: 88),
                        itemCount: txns.length,
                        itemBuilder: (context, i) {
                          final t = txns[i];
                          final cat = data.categories[t.categoryId];
                          return ListTile(
                            leading: Icon(
                              t.type == TransactionType.income
                                  ? Icons.arrow_downward
                                  : Icons.arrow_upward,
                              color: t.type == TransactionType.income
                                  ? NoovaTheme.income
                                  : NoovaTheme.expense,
                              size: 20,
                            ),
                            title: Text(cat?.name ?? 'Sin categoría'),
                            subtitle: Text(
                              '${t.date.day}/${t.date.month}/${t.date.year}'
                              '${t.isRecurring ? ' · recurrente' : ''}',
                              style: const TextStyle(fontSize: 12),
                            ),
                            trailing: Text(
                              (t.type == TransactionType.income ? '+' : '-') +
                                  MoneyFormat.format(t.amount),
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: t.type == TransactionType.income
                                    ? NoovaTheme.income
                                    : NoovaTheme.expense,
                              ),
                            ),
                            onTap: () async {
                              await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => TransactionDetailScreen(transaction: t),
                                ),
                              );
                              setState(() {});
                            },
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
      bottomNavigationBar: const MainNavBar(location: '/quincenal'),
    );
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
