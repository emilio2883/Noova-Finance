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

class _Data {
  final List<Transaction> txns;
  final Map<int, Category> categories;
  _Data(this.txns, this.categories);
}

const _monthNames = ['Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun', 'Jul', 'Ago', 'Sep', 'Oct', 'Nov', 'Dic'];

class QuincenalScreen extends ConsumerStatefulWidget {
  const QuincenalScreen({super.key});

  @override
  ConsumerState<QuincenalScreen> createState() => _QuincenalScreenState();
}

class _QuincenalScreenState extends ConsumerState<QuincenalScreen> {
  int _view = 0; // 0=quincena, 1=mes, 2=año
  DateTime _anchor = DateTime.now();

  Future<_Data> _load() async {
    final txnRepo = await ref.read(transactionRepoProvider.future);
    final catRepo = await ref.read(categoryRepoProvider.future);
    final txns = await txnRepo.getAll();
    final cats = await catRepo.getAll();
    return _Data(txns, {for (final c in cats) c.id: c});
  }

  (DateTime, DateTime) get _range {
    if (_view == 0) {
      return (QuincenaUtils.quincenaStart(_anchor), QuincenaUtils.quincenaEnd(_anchor));
    } else if (_view == 1) {
      return (QuincenaUtils.monthStart(_anchor), QuincenaUtils.monthEnd(_anchor));
    }
    return (QuincenaUtils.yearStart(_anchor), QuincenaUtils.yearEnd(_anchor));
  }

  String get _label {
    if (_view == 0) return QuincenaUtils.quincenaLabel(_anchor);
    if (_view == 1) return '${_monthNames[_anchor.month - 1]} ${_anchor.year}';
    return 'Año ${_anchor.year}';
  }

  void _shift(int d) {
    setState(() {
      if (_view == 0) {
        if (d > 0) {
          _anchor = _anchor.day <= 15
              ? DateTime(_anchor.year, _anchor.month, 16)
              : DateTime(_anchor.year, _anchor.month + 1, 1);
        } else {
          _anchor = _anchor.day <= 15
              ? DateTime(_anchor.year, _anchor.month - 1, 16)
              : DateTime(_anchor.year, _anchor.month, 1);
        }
      } else if (_view == 1) {
        _anchor = DateTime(_anchor.year, _anchor.month + d, 1);
      } else {
        _anchor = DateTime(_anchor.year + d, 1, 1);
      }
    });
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
    final c = context.app.colors;
    return Scaffold(
      appBar: AppBar(title: const Text('Consumo')),
      floatingActionButton: FloatingActionButton(
        onPressed: _openAdd,
        backgroundColor: c.primary,
        foregroundColor: c.textOnPrimary,
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
          final range = _range;
          final start = range.$1;
          final end = range.$2;

          final ingresos = SaldoCalculator.ingresos(data.txns, start, end);
          final gastos = SaldoCalculator.gastos(data.txns, start, end);
          final utilidad = ingresos - gastos;
          final byCat = SaldoCalculator.gastosPorCategoria(data.txns, start, end);
          final ingByCat =
              SaldoCalculator.ingresosPorCategoria(data.txns, start, end);

          final movs = data.txns
              .where((t) => !t.date.isBefore(start) && !t.date.isAfter(end))
              .toList()
            ..sort((a, b) => b.date.compareTo(a.date));

          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 96),
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    children: [
                      SegmentedButton<int>(
                        showSelectedIcon: false,
                        segments: const [
                          ButtonSegment(value: 0, label: Text('Quincena')),
                          ButtonSegment(value: 1, label: Text('Mes')),
                          ButtonSegment(value: 2, label: Text('Año')),
                        ],
                        selected: {_view},
                        onSelectionChanged: (s) => setState(() => _view = s.first),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          IconButton(
                              onPressed: () => _shift(-1),
                              icon: const Icon(Icons.chevron_left)),
                          Expanded(
                            child: Text(_label,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                    fontWeight: FontWeight.w600, fontSize: 15)),
                          ),
                          IconButton(
                              onPressed: () => _shift(1),
                              icon: const Icon(Icons.chevron_right)),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
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
              _sectionTitle('INGRESOS POR CATEGORÍA', c),
              const SizedBox(height: 8),
              _CategoryBreakdown(
                  byCategory: ingByCat,
                  categories: data.categories,
                  pct: _pct,
                  total: ingresos,
                  color: c.income),
              const SizedBox(height: 16),
              _sectionTitle('GASTOS POR CATEGORÍA', c),
              const SizedBox(height: 8),
              _CategoryBreakdown(
                  byCategory: byCat,
                  categories: data.categories,
                  pct: _pct,
                  total: gastos,
                  color: c.expense),
              const SizedBox(height: 16),
              _sectionTitle('MOVIMIENTOS (${movs.length})', c),
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

  Widget _sectionTitle(String text, dynamic c) => Text(text,
      style: TextStyle(
          color: c.textSecondary, fontSize: 12, letterSpacing: 1.5));

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

class _CategoryBreakdown extends StatelessWidget {
  final Map<int, Decimal> byCategory;
  final Map<int, Category> categories;
  final String Function(Decimal, Decimal) pct;
  final Decimal total;
  final Color color;

  const _CategoryBreakdown({
    required this.byCategory,
    required this.categories,
    required this.pct,
    required this.total,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    if (byCategory.isEmpty) {
      return const Card(
          child: Padding(
              padding: EdgeInsets.all(20),
              child: Center(child: Text('Sin datos en el periodo'))));
    }
    final entries = byCategory.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final max = entries.first.value;
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
                            '${MoneyFormat.format(e.value)}  ·  ${pct(e.value, total)}',
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
                      color: color,
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
