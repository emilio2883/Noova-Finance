import 'package:flutter/material.dart';

import '../../../core/theme.dart';
import '../../../core/utils/money_format.dart';
import '../../../data/models/transaction.dart';
import '../../../data/providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Last 15 transactions with tap-to-edit.
class RecentTransactions extends ConsumerWidget {
  final List<Transaction> transactions;
  final void Function(Transaction)? onTap;

  const RecentTransactions({
    super.key,
    required this.transactions,
    this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (transactions.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Center(
            child: Text('Sin transacciones todavía.\n¡Registra la primera con el botón +!',
              textAlign: TextAlign.center),
          ),
        ),
      );
    }

    final categoriesAsync = ref.watch(categoryRepoProvider);

    return Card(
      child: categoriesAsync.maybeWhen(
        loading: () => const SizedBox(),
        orElse: () => Column(
          children: [
            for (final t in transactions)
              FutureBuilder<String>(
                future: _categoryName(ref, t.categoryId),
                builder: (context, snap) => ListTile(
                  dense: true,
                  leading: Icon(
                    t.type == TransactionType.income
                        ? Icons.arrow_downward
                        : Icons.arrow_upward,
                    color: t.type == TransactionType.income
                        ? NoovaTheme.income
                        : NoovaTheme.expense,
                    size: 20,
                  ),
                  title: Text(snap.data ?? '…'),
                  subtitle: Text(
                    '${t.date.day}/${t.date.month}',
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
                  onTap: onTap != null ? () => onTap!(t) : null,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Future<String> _categoryName(WidgetRef ref, int categoryId) async {
    final repo = await ref.read(categoryRepoProvider.future);
    final cat = await repo.getById(categoryId);
    return cat?.name ?? 'Sin categoría';
  }
}
