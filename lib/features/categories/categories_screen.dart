import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme.dart';
import '../../data/models/category.dart';
import '../../data/models/transaction.dart';
import '../../data/providers.dart';

/// Category management with a 2-level tree (principal -> subcategory).
class CategoriesScreen extends ConsumerStatefulWidget {
  const CategoriesScreen({super.key});

  @override
  ConsumerState<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends ConsumerState<CategoriesScreen> {
  Future<List<Category>> _principals() async {
    final repo = await ref.read(categoryRepoProvider.future);
    final exp = await repo.getTopLevel(TransactionType.expense);
    final inc = await repo.getTopLevel(TransactionType.income);
    return [...inc, ...exp];
  }

  Future<List<Category>> _children(int id) async {
    final repo = await ref.read(categoryRepoProvider.future);
    return repo.getChildren(id);
  }

  Future<void> _addCategory() async {
    final repo = await ref.read(categoryRepoProvider.future);
    final principals = await _principals();

    final nameCtrl = TextEditingController();
    TransactionType type = TransactionType.expense;
    var isGroup = false;
    var isVariable = true;
    int? parentId;

    if (!mounted) return;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) {
          final possibleParents = principals
              .where((p) => p.isGroup && p.type == type)
              .toList();
          return AlertDialog(
            title: const Text('Nueva categoría'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameCtrl,
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
                    onSelectionChanged: (s) => setDialogState(() {
                      type = s.first;
                      parentId = null;
                    }),
                  ),
                  CheckboxListTile(
                    title: const Text('Es categoría principal'),
                    subtitle: const Text('Agrupa subcategorías'),
                    value: isGroup,
                    onChanged: (v) => setDialogState(() {
                      isGroup = v ?? false;
                      parentId = null;
                    }),
                  ),
                  if (!isGroup)
                    DropdownButtonFormField<int?>(
                      value: parentId,
                      decoration: const InputDecoration(labelText: 'Categoría principal'),
                      items: [
                        const DropdownMenuItem<int?>(
                            value: null, child: Text('Sin principal')),
                        for (final p in possibleParents)
                          DropdownMenuItem<int?>(value: p.id, child: Text(p.name)),
                      ],
                      onChanged: (v) => setDialogState(() => parentId = v),
                    ),
                  if (!isGroup && type == TransactionType.expense)
                    CheckboxListTile(
                      title: const Text('Variable (con presupuesto)'),
                      value: isVariable,
                      onChanged: (v) => setDialogState(() => isVariable = v ?? false),
                    ),
                ],
              ),
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
          );
        },
      ),
    );

    if (ok == true && nameCtrl.text.trim().isNotEmpty) {
      final all = await repo.getAll();
      await repo.insert(Category(
        name: nameCtrl.text.trim(),
        type: type,
        isGroup: isGroup,
        isVariable: isVariable,
        parentId: parentId,
        order: all.length + 1,
      ));
      setState(() {});
    }
  }

  Future<void> _rename(Category c) async {
    final ctrl = TextEditingController(text: c.name);
    final res = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Renombrar'),
        content: TextField(controller: ctrl, autofocus: true),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
          FilledButton(onPressed: () => Navigator.pop(ctx, ctrl.text), child: const Text('Guardar')),
        ],
      ),
    );
    if (res != null && res.trim().isNotEmpty) {
      final repo = await ref.read(categoryRepoProvider.future);
      c.name = res.trim();
      await repo.update(c);
      setState(() {});
    }
  }

  Future<void> _move(Category c) async {
    final repo = await ref.read(categoryRepoProvider.future);
    final principals = (await _principals())
        .where((p) => p.isGroup && p.type == c.type && p.id != c.id)
        .toList();
    if (!mounted) return;
    final res = await showDialog<int?>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Mover "${c.name}"'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: const Text('Sin principal (nivel superior)'),
                onTap: () => Navigator.pop(ctx, -1),
              ),
              for (final p in principals)
                ListTile(
                  title: Text(p.name),
                  onTap: () => Navigator.pop(ctx, p.id),
                ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
        ],
      ),
    );
    if (res != null) {
      await repo.setParent(c, res == -1 ? null : res);
      setState(() {});
    }
  }

  Future<void> _delete(Category c) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eliminar categoría'),
        content: Text('¿Eliminar "${c.name}"? Las transacciones existentes conservarán su registro.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancelar')),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(backgroundColor: NoovaTheme.expense),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
    if (ok == true) {
      final repo = await ref.read(categoryRepoProvider.future);
      await repo.delete(c.id);
      setState(() {});
    }
  }

  Widget _menu(Category c, {required bool isChild}) {
    return PopupMenuButton<String>(
      onSelected: (a) async {
        switch (a) {
          case 'rename':
            await _rename(c);
          case 'move':
            await _move(c);
          case 'hide':
            final repo = await ref.read(categoryRepoProvider.future);
            if (c.isActive) {
              await repo.hide(c);
            } else {
              c.isActive = true;
              await repo.update(c);
            }
            setState(() {});
          case 'delete':
            await _delete(c);
        }
      },
      itemBuilder: (_) => [
        const PopupMenuItem(value: 'rename', child: Text('Renombrar')),
        if (isChild)
          const PopupMenuItem(value: 'move', child: Text('Mover a...')),
        PopupMenuItem(value: 'hide', child: Text(c.isActive ? 'Ocultar' : 'Mostrar')),
        const PopupMenuItem(value: 'delete', child: Text('Eliminar')),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Categorías')),
      floatingActionButton: FloatingActionButton(
        onPressed: _addCategory,
        child: const Icon(Icons.add),
      ),
      body: FutureBuilder<List<Category>>(
        future: _principals(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final principals = snapshot.data!;
          return ListView(
            padding: const EdgeInsets.only(bottom: 88),
            children: [
              for (final p in principals)
                if (p.isGroup)
                  FutureBuilder<List<Category>>(
                    future: _children(p.id),
                    builder: (context, cs) {
                      final children = cs.data ?? [];
                      return Card(
                        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        child: ExpansionTile(
                          leading: Icon(
                            p.type == TransactionType.income
                                ? Icons.arrow_downward
                                : Icons.arrow_upward,
                            color: p.type == TransactionType.income
                                ? NoovaTheme.income
                                : NoovaTheme.expense,
                          ),
                          title: Text(p.name,
                              style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: p.isActive ? null : NoovaTheme.textSecondary)),
                          subtitle: Text('${children.length} subcategorías',
                              style: const TextStyle(fontSize: 11)),
                          trailing: _menu(p, isChild: false),
                          children: [
                            for (final c in children)
                              ListTile(
                                contentPadding: const EdgeInsets.only(left: 40, right: 8),
                                title: Text(c.name,
                                    style: TextStyle(
                                        color: c.isActive ? null : NoovaTheme.textSecondary)),
                                subtitle: Text(c.isVariable ? 'Variable' : 'Fija',
                                    style: const TextStyle(fontSize: 11)),
                                trailing: _menu(c, isChild: true),
                              ),
                            if (children.isEmpty)
                              const Padding(
                                padding: EdgeInsets.all(12),
                                child: Text('Sin subcategorías. Agrega una con +',
                                    style: TextStyle(fontSize: 12, color: NoovaTheme.textSecondary)),
                              ),
                          ],
                        ),
                      );
                    },
                  )
                else
                  Card(
                    margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    child: ListTile(
                      leading: Icon(
                        p.type == TransactionType.income
                            ? Icons.arrow_downward
                            : Icons.arrow_upward,
                        color: p.type == TransactionType.income
                            ? NoovaTheme.income
                            : NoovaTheme.expense,
                      ),
                      title: Text(p.name),
                      subtitle: Text(p.isVariable ? 'Variable' : 'Fija',
                          style: const TextStyle(fontSize: 11)),
                      trailing: _menu(p, isChild: false),
                    ),
                  ),
            ],
          );
        },
      ),
    );
  }
}
