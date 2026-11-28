import 'dart:async';

import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:noova_finance/theme/app_theme.dart';
import '../../core/utils/money_format.dart';
import '../../data/models/category.dart';
import '../../data/models/search_filters.dart';
import '../../data/models/transaction.dart';
import '../../data/providers.dart';
import '../../shared/ui/empty_state.dart';
import '../transaction/transaction_detail_screen.dart';
import 'search_providers.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  late final TextEditingController _textCtrl;
  Timer? _debounce;
  late final Future<List<Category>> _catsFuture;

  @override
  void initState() {
    super.initState();
    _textCtrl =
        TextEditingController(text: ref.read(searchFiltersProvider).text);
    _catsFuture = _loadCats();
  }

  Future<List<Category>> _loadCats() async {
    final repo = await ref.read(categoryRepoProvider.future);
    final all = await repo.getAll();
    return all.where((c) => !c.isGroup && c.isActive).toList();
  }

  Future<List<Transaction>> _search(SearchFilters f) async {
    final repo = await ref.read(transactionRepoProvider.future);
    return repo.search(f);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _textCtrl.dispose();
    super.dispose();
  }

  void _onTextChanged(String v) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 350), () {
      ref.read(searchFiltersProvider.notifier).setText(v);
    });
  }

  @override
  Widget build(BuildContext context) {
    final app = context.app;
    final filters = ref.watch(searchFiltersProvider);
    final notifier = ref.read(searchFiltersProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: const Text('Buscar')),
      body: FutureBuilder<List<Category>>(
        future: _catsFuture,
        builder: (context, catsSnap) {
          final cats = catsSnap.data ?? const <Category>[];
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.fromLTRB(
                    app.spacing.md, app.spacing.sm, app.spacing.md, 0),
                child: TextField(
                  controller: _textCtrl,
                  onChanged: _onTextChanged,
                  textInputAction: TextInputAction.search,
                  decoration: InputDecoration(
                    hintText: 'Buscar en descripciones…',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: filters.text.isEmpty
                        ? null
                        : IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _textCtrl.clear();
                              notifier.setText('');
                            },
                          ),
                  ),
                ),
              ),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.symmetric(
                    horizontal: app.spacing.md, vertical: app.spacing.sm),
                child: Row(
                  children: [
                    _typeChip('Todos', null, filters, notifier),
                    SizedBox(width: app.spacing.xs),
                    _typeChip('Ingresos', TransactionType.income, filters, notifier),
                    SizedBox(width: app.spacing.xs),
                    _typeChip('Gastos', TransactionType.expense, filters, notifier),
                    SizedBox(width: app.spacing.sm),
                    ActionChip(
                      avatar: const Icon(Icons.category_outlined, size: 16),
                      label: Text(filters.categoryIds.isEmpty
                          ? 'Categorías'
                          : 'Categorías (${filters.categoryIds.length})'),
                      onPressed: () => _pickCategories(cats),
                    ),
                    SizedBox(width: app.spacing.xs),
                    ActionChip(
                      avatar: const Icon(Icons.date_range, size: 16),
                      label: Text(_dateLabel(filters)),
                      onPressed: _pickDates,
                    ),
                    SizedBox(width: app.spacing.xs),
                    FilterChip(
                      label: const Text('Solo recurrentes'),
                      selected: filters.onlyRecurring,
                      onSelected: notifier.setOnlyRecurring,
                    ),
                    SizedBox(width: app.spacing.xs),
                    ActionChip(
                      avatar: const Icon(Icons.tune, size: 16),
                      label: Text(_amountLabel(filters)),
                      onPressed: _pickAmount,
                    ),
                    if (!filters.isEmpty) ...[
                      SizedBox(width: app.spacing.xs),
                      TextButton.icon(
                        onPressed: () {
                          _textCtrl.clear();
                          notifier.reset();
                        },
                        icon: const Icon(Icons.restart_alt, size: 16),
                        label: const Text('Limpiar'),
                      ),
                    ],
                  ],
                ),
              ),
              Expanded(
                child: FutureBuilder<List<Transaction>>(
                  future: _search(filters),
                  builder: (context, snap) {
                    if (snap.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    final txns = snap.data ?? const <Transaction>[];
                    if (txns.isEmpty) {
                      return const EmptyState(
                        icon: Icons.search_off,
                        title: 'Sin resultados',
                        message: 'Ajusta los filtros o busca otro término.',
                      );
                    }
                    final catName = {for (final c in cats) c.id: c.name};
                    var ing = Decimal.zero;
                    var gas = Decimal.zero;
                    for (final t in txns) {
                      if (t.type == TransactionType.income) {
                        ing += t.amount;
                      } else {
                        gas += t.amount;
                      }
                    }
                    return ListView(
                      padding: EdgeInsets.only(bottom: app.spacing.lg),
                      children: [
                        Container(
                          width: double.infinity,
                          color: app.colors.surfaceVariant,
                          padding: EdgeInsets.symmetric(
                              horizontal: app.spacing.md,
                              vertical: app.spacing.sm),
                          child: Text(
                            '${txns.length} movimientos · '
                            'Ingresos ${MoneyFormat.format(ing)} · '
                            'Gastos ${MoneyFormat.format(gas)}',
                            style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: app.colors.textSecondary),
                          ),
                        ),
                        for (final t in txns)
                          _ResultTile(txn: t, categoryName: catName[t.categoryId]),
                      ],
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _typeChip(String label, TransactionType? value, SearchFilters f,
      SearchFiltersNotifier notifier) {
    return ChoiceChip(
      label: Text(label),
      selected: f.type == value,
      onSelected: (_) => notifier.setType(value),
    );
  }

  String _dateLabel(SearchFilters f) {
    if (f.from == null && f.to == null) return 'Fechas';
    String d(DateTime? x) => x == null ? '…' : '${x.day}/${x.month}/${x.year}';
    return '${d(f.from)}–${d(f.to)}';
  }

  String _amountLabel(SearchFilters f) {
    if (f.minBps == null && f.maxBps == null) return 'Importe';
    String m(int? b) => b == null
        ? '…'
        : MoneyFormat.format(Decimal.parse((b / 10000).toStringAsFixed(2)));
    return '${m(f.minBps)}–${m(f.maxBps)}';
  }

  Future<void> _pickCategories(List<Category> cats) async {
    final notifier = ref.read(searchFiltersProvider.notifier);
    final selected = {...ref.read(searchFiltersProvider).categoryIds};
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSt) => DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.6,
          maxChildSize: 0.9,
          builder: (ctx, controller) => Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Categorías',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold)),
                    TextButton(
                      onPressed: () {
                        notifier.setCategories(selected);
                        Navigator.pop(ctx);
                      },
                      child: const Text('Aplicar'),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView(
                  controller: controller,
                  children: [
                    for (final c in cats)
                      CheckboxListTile(
                        value: selected.contains(c.id),
                        title: Text(c.name),
                        onChanged: (v) => setSt(() {
                          if (v == true) {
                            selected.add(c.id);
                          } else {
                            selected.remove(c.id);
                          }
                        }),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickDates() async {
    final notifier = ref.read(searchFiltersProvider.notifier);
    final f = ref.read(searchFiltersProvider);
    final now = DateTime.now();
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2000),
      lastDate: DateTime(now.year + 1, 12, 31),
      initialDateRange: f.from != null && f.to != null
          ? DateTimeRange(start: f.from!, end: f.to!)
          : null,
    );
    if (picked != null) {
      notifier.setDateRange(picked.start, picked.end);
    }
  }

  Future<void> _pickAmount() async {
    final notifier = ref.read(searchFiltersProvider.notifier);
    final f = ref.read(searchFiltersProvider);
    final minCtrl = TextEditingController(
        text: f.minBps == null ? '' : (f.minBps! / 10000).toString());
    final maxCtrl = TextEditingController(
        text: f.maxBps == null ? '' : (f.maxBps! / 10000).toString());
    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Rango de importe'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: minCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Mínimo'),
            ),
            TextField(
              controller: maxCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Máximo'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              notifier.setAmountRange(null, null);
              Navigator.pop(ctx);
            },
            child: const Text('Quitar'),
          ),
          FilledButton(
            onPressed: () {
              int? toBps(String s) {
                final d = double.tryParse(s.replaceAll(',', '').trim());
                return d == null ? null : (d * 10000).round();
              }

              notifier.setAmountRange(toBps(minCtrl.text), toBps(maxCtrl.text));
              Navigator.pop(ctx);
            },
            child: const Text('Aplicar'),
          ),
        ],
      ),
    );
  }
}

class _ResultTile extends StatelessWidget {
  final Transaction txn;
  final String? categoryName;
  const _ResultTile({required this.txn, required this.categoryName});

  @override
  Widget build(BuildContext context) {
    final c = context.app.colors;
    final isIncome = txn.type == TransactionType.income;
    final d = txn.date;
    return ListTile(
      leading: Icon(
        isIncome ? Icons.arrow_downward : Icons.arrow_upward,
        color: isIncome ? c.income : c.expense,
        size: 20,
      ),
      title: Text(categoryName ?? 'Sin categoría'),
      subtitle: Text(
        '${d.day}/${d.month}/${d.year}'
        '${(txn.description ?? '').isNotEmpty ? ' · ${txn.description}' : ''}'
        '${txn.isRecurring ? ' · recurrente' : ''}',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: Text(
        '${isIncome ? '+' : '-'}${MoneyFormat.format(txn.amount)}',
        style: TextStyle(
            fontWeight: FontWeight.bold,
            color: isIncome ? c.income : c.expense),
      ),
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
            builder: (_) => TransactionDetailScreen(transaction: txn)),
      ),
    );
  }
}
