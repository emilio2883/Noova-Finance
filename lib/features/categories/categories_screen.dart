import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme.dart';
import '../../data/models/transaction.dart';
import '../../data/providers.dart';

/// Category management: create, rename, hide, reorder (US10).
class CategoriesScreen extends ConsumerStatefulWidget {
  const CategoriesScreen({super.key});

  @override
  ConsumerState<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends ConsumerState<CategoriesScreen> {
  Future<void> _addCategory() async {
    final nameController = TextEditingController();
    TransactionType type = TransactionType.expense;
    bool isVariable = true;

    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          backgroundColor: NoovaTheme.surface,
          title: const Text('Nueva categoria'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                autofocus: true,
                decoration: const InputDecoration(labelText: 'Nombre'),
              ),
              const SizedBox(height: 12),
              SegmentedButton<TransactionType>(
                segments: const [
                  ButtonSegment(value: TransactionType.expense, label: Text('Gasto')),
                  ButtonSegment(value: TransactionType.income, label: Text('Ingreso')),
                ],
                selected: {type},
                onSelectionChanged: (s) =>
                    setDialogState(() => type = s.first),
              ),
              CheckboxListTile(
                title: const Text('Variable (con presupuesto)'),
                value: isVariable,
                onChanged: (v) =>
                    setDialogState(() => isVariable = v ?? false),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Crear'),
            ),
          ],
        ),
      ),
    );

    if (result == true && nameController.text.trim().isNotEmpty) {
      final repo = await ref.read(categoryRepoProvider.future);
      final all = await repo.getAll();
      await repo.insert(Category(
        name: nameController.text.trim(),
        type: type,
        isVariable: isVariable,
        order: all.length + 1,
      ));
      ref.invalidate(categoryRepoProvider);
    }
  }

  Future<void> _rename(dynamic category) async {
    final controller = TextEditingController(text: category.name);
    final result = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: NoovaTheme.surface,
        title: const Text('Renombrar categoria'),
        content: TextField(controller: controller, autofocus: true),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, controller.text),
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
    if (result != null && result.trim().isNotEmpty) {
      final repo = await ref.read(categoryRepoProvider.future);
      category.name = result.trim();
      await repo.update(category);
      ref.invalidate(categoryRepoProvider);
    }
  }

  @override
  Widget build(BuildContext context) {
    final categoriesAsync = ref.watch(categoryRepoProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Categorias')),
      floatingActionButton: FloatingActionButton(
        onPressed: _addCategory,
        child: const Icon(Icons.add),
      ),
      body: categoriesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (repo) => FutureBuilder(
          future: repo.getAll(),
          builder: (context, snapshot) {
            final categories = snapshot.data ?? [];
            return ListView(
              children: [
                for (final c in categories)
                  Card(
                    margin:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    child: ListTile(
                      leading: Icon(
                        c.type == TransactionType.income
                            ? Icons.arrow_downward
                            : Icons.arrow_upward,
                        color: c.type == TransactionType.income
                            ? NoovaTheme.income
                            : NoovaTheme.expense,
                      ),
                      title: Text(
                        c.name,
                        style: TextStyle(
                          color: c.isActive
                              ? null
                              : NoovaTheme.textSecondary,
                        ),
                      ),
                      subtitle: Text(
                        c.isVariable ? 'Variable' : 'Fija',
                        style: const TextStyle(fontSize: 11),
                      ),
                      trailing: PopupMenuButton<String>(
                        onSelected: (action) async {
                          if (action == 'rename') {
                            await _rename(c);
                          } else if (action == 'hide') {
                            final r =
                                await ref.read(categoryRepoProvider.future);
                            if (c.isActive) {
                              await r.hide(c);
                            } else {
                              c.isActive = true;
                              await r.update(c);
                            }
                            ref.invalidate(categoryRepoProvider);
                          }
                        },
                        itemBuilder: (_) => [
                          const PopupMenuItem(
                            value: 'rename',
                            child: Text('Renombrar'),
                          ),
                          PopupMenuItem(
                            value: 'hide',
                            child:
                                Text(c.isActive ? 'Ocultar' : 'Mostrar'),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}
