import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:noova_finance/theme/app_theme.dart';
import '../../core/utils/date_utils.dart';
import '../../core/utils/money_format.dart';
import '../../data/models/category.dart';
import '../../data/models/transaction.dart';
import '../../data/providers.dart';
import '../../data/services/saldo_calculator.dart';
import '../../shared/ui/error_state.dart';
import '../../shared/ui/loading_state.dart';
import '../../shared/widgets/animated_progress_bar.dart';
import '../../shared/widgets/main_nav_bar.dart';
import '../../theme/app_radii.dart';
import '../transaction/quick_add_modal.dart';
import '../transaction/transaction_detail_screen.dart';

class _P {
  final String key;
  final String label;
  final DateTime start;
  final DateTime end;
  const _P(this.key, this.label, this.start, this.end);
}

class _Data {
  final List<Transaction> txns;
  final Map<int, Category> categories;
  final List<Category> leaves;
  _Data(this.txns, this.categories, this.leaves);
}

const _monthNames = ['Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun', 'Jul', 'Ago', 'Sep', 'Oct', 'Nov', 'Dic'];

/// "Consumo": period-filtered spending hub with values + percentages (US3/US5).
class QuincenalScreen extends ConsumerStatefulWidget {
  const QuincenalScreen({super.key});

  @override
  ConsumerState<QuincenalScreen> createState() => _QuincenalScreenState();
}

class _QuincenalScreenState extends ConsumerState<QuincenalScreen> {
  String? _periodKey;
  int? _filterCategoryId;

  Future<_Data> _load() async {
    final txnRepo = await ref.read(transactionRepoProvider.future);
    final catRepo = await ref.read(categoryRepoProvider.future);
    final txns = await txnRepo.getAll();
    final cats = await catRepo.getAll();
    final leaves = [
      ...await catRepo.getLeaves(TransactionType.expense),
      ...await catRepo.getLeaves(TransactionType.income),
    ];
    return _Data(txns, {for (final c in cats) c.id: c}, leaves);
  }

  List<_P> _periods(List<Transaction> txns) {
    final years = <int>{};
    final months = <String, DateTime>{};
    for (final t in txns) {
      years.add(t.date.year);
      months['${t.date.year}-${t.date.month}'] =
          DateTime(t.date.year, t.date.month, 1);
    }
    final sortedYears = years.toList()..sort((a, b) => b.compareTo(a));
    final sortedMonths = months.values.toList()..sort((a, b) => b.compareTo(a));

    // Quincenas: current and up to 23 previous.
    final quincenas = <_P>[];
    var d = DateTime.now();
    for (var i = 0; i < 24; i++) {
      final qs = QuincenaUtils.quincenaStart(d);
      final qe = QuincenaUtils.quincenaEnd(d);
      quincenas.add(_P('Q${qs.year}-${qs.month}-${qs.day}',
          'Quincena ${QuincenaUtils.quincenaLabel(d)}', qs, qe));
      d = qs.subtract(const Duration(days: 1));
    }

    return [
      ...quincenas,
      for (final m in sortedMonths)
        _P('M${m.year}-${m.month}', '${_monthNames[m.month - 1]} ${m.year}',
            DateTime(m.year, m.month, 1),
            DateTime(m.year, m.month + 1, 1).subtract(const Duration(microseconds: 1))),
      for (final y in sortedYears)
        _P('Y$y', 'Año $y', DateTime(y, 1, 1),
            DateTime(y + 1, 1, 1).subtract(const Duration(microseconds: 1))),
    ];
  }

  String _pct(Decimal part, Decimal total) {
    if (total == Decimal.zero) return '—';
    return '${(part.toDouble() / total.toDouble() * 100).toStringAsFixed(0)}%';
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
      appBar: AppBar(title: const Text('Consumo')),
      floatingActionButton: FloatingActionButton(
        onPressed: _openAdd,
        backgroundColor: context.app.colors.primary,
        foregroundColor: context.app.colors.textOnPrimary,
        child: const Icon(Icons.add),
      ),
      body: FutureBuilder<_Data>(
        future: _load(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const LoadingState();
          }
          if (snapshot.hasError) {
            return ErrorState(
                message: 'No pudimos cargar el consumo.',
                onRetry: () => setState(() {}));
          }
          final data = snapshot.data!;
          final periods = _periods(data.txns);
          final selected = periods.firstWhere(
            (p) => p.key == _periodKey,
            orElse: () => periods.first,
          );

          final ingresos =
              SaldoCalculator.ingresos(data.txns, selected.start, selected.end);
          final gastos =
              SaldoCalculator.gastos(data.txns, selected.start, selected.end);
          final utilidad = ingresos - gastos;
          final byCat =
              SaldoCalculator.gastosPorCategoria(data.txns, selected.start, selected.end);

          var movs = data.txns
              .where((t) =>
                  !t.date.isBefore(selected.start) && !t.date.isAfter(selected.end))
              .toList();
          if (_filterCategoryId != null) {
            movs = movs.where((t) => t.categoryId == _filterCategoryId).toList();
          }
          movs.sort((a, b) => b.date.compareTo(a.date));

          final c = context.app.colors;

          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 96),
            children: [
              // Period selector
              Card(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
                  child: Row(
                    children: [
                      Icon(Icons.calendar_month, color: c.primary),
                      const SizedBox(width: 10),
                      const Text('Periodo:', style: TextStyle(fontWeight: FontWeight.w600)),
                      const SizedBox(width: 10),
                      Expanded(
                        child: DropdownButton<String>(
                          isExpanded: true,
                          value: selected.key,
                          underline: const SizedBox.shrink(),
                          items: [
                            for (final p in periods)
                              DropdownMenuItem(value: p.key, child: Text(p.label)),
                          ],
                          onChanged: (k) => setState(() => _periodKey = k),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              // Totals with percentages
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _stat('Ingresos', ingresos, 'base', c.income),
                      _stat('Gastos', gastos, _pct(gastos, ingresos), c.expense),
                      _stat('Utilidad', utilidad, _pct(utilidad, ingresos),
                          utilidad >= Decimal.zero ? c.income : c.expense),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text('GASTOS POR CATEGORÍA',
                  style: TextStyle(color: c.textSecondary, fontSize: 12, letterSpacing: 1.5)),
              const SizedBox(height: 8),
              _CategoryBreakdown(byCategory: byCat, categories: data.categories, pct: _pct, gastos: gastos),
              const SizedBox(height: 16),
              Row(
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
                            value: null, child: Text('Todas las categorías')),
                        for (final cat in data.leaves)
                          DropdownMenuItem<int?>(value: cat.id, child: Text(cat.name)),
                      ],
                      onChanged: (v) => setState(() => _filterCategoryId = v),
                    ),
                  ),
                ],
              ),
              Text('MOVIMIENTOS (${movs.length})',
                  style: TextStyle(color: c.textSecondary, fontSize: 12, letterSpacing: 1.5)),
              const SizedBox(height: 4),
              if (movs.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(24),
                  child: Center(child: Text('Sin movimientos en este periodo')),
                )
              else
                for (final t in movs)
                  Builder(builder: (context) {
                    final cat = data.categories[t.categoryId];
                    final isIncome = t.type == TransactionType.income;
                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Icon(
                          isIncome ? Icons.arrow_downward : Icons.arrow_upward,
                          color: isIncome ? c.income : c.expense,
                          size: 20),
                      title: Text(cat?.name ?? 'Sin categoría'),
                      subtitle: Text('${t.date.day}/${t.date.month}/${t.date.year}'
                          '${t.isRecurring ? ' · recurrente' : ''}'),
                      trailing: Text(
                        (isIncome ? '+' : '-') + MoneyFormat.format(t.amount),
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: isIncome ? c.income : c.expense),
                      ),
                      onTap: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) =>
                                  TransactionDetailScreen(transaction: t)),
                        );
                        setState(() {});
                      },
                    );
                  }),
            ],
          );
        },
      ),
      bottomNavigationBar: const MainNavBar(location: '/quincenal'),
    );
  }

  Widget _stat(String label, Decimal value, String pctText, Color color) {
    return Column(
      children: [
        Text(label.toUpperCase(),
            style: TextStyle(color: context.app.colors.textSecondary, fontSize: 10)),
        Text(MoneyFormat.format(value),
            style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 15)),
        Text(pctText,
            style: TextStyle(color: context.app.colors.textSecondary, fontSize: 10)),
      ],
    );
  }
}

class _CategoryBreakdown extends ConsumerWidget {
  final Map<int, Decimal> byCategory;
  final Map<int, Category> categories;
  final String Function(Decimal, Decimal) pct;
  final Decimal gastos;

  const _CategoryBreakdown({
    required this.byCategory,
    required this.categories,
    required this.pct,
    required this.gastos,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (byCategory.isEmpty) {
      return const Card(
          child: Padding(
              padding: EdgeInsets.all(20),
              child: Center(child: Text('Sin gastos en el periodo'))));
    }
    final entries = byCategory.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final max = entries.first.value;
    final c = context.app.colors;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          children: [
            for (final e in entries)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(categories[e.key]?.name ?? '...',
                              style: const TextStyle(fontSize: 13)),
                        ),
                        Text(
                            '${MoneyFormat.format(e.value)}  ·  ${pct(e.value, gastos)}',
                            style: const TextStyle(
                                fontSize: 12, fontWeight: FontWeight.w600)),
                      ],
                    ),
                    const SizedBox(height: 4),
                    AnimatedProgressBar(
                      value: max == Decimal.zero ? 0 : (e.value / max).toDouble(),
                      minHeight: 6,
                      borderRadius: AppRadii.standard.brXs,
                      backgroundColor:
                          Theme.of(context).colorScheme.surfaceContainerHighest,
                      color: c.expense,
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
