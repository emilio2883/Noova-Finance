import 'package:isar/isar.dart';

import '../models/category.dart';
import '../models/transaction.dart';
import '../seed/default_categories.dart';

/// CRUD + hierarchical seed for categories.
class CategoryRepository {
  final Isar _isar;
  CategoryRepository(this._isar);

  /// Idempotent seed of the Y26 hierarchy. Reuses existing categories by
  /// importKey/name so transaction foreign keys survive an upgrade.
  Future<void> seedDefaults() async {
    await _isar.writeTxn(() async {
      // 1. Parents (groups) first, so children can reference their ids.
      final parentIds = <String, int>{};
      for (final d in DefaultCategories.defs.where((d) => d.isGroup)) {
        Category? existing = await _isar.categorys
            .filter()
            .nameEqualTo(d.name)
            .and()
            .isGroupEqualTo(true)
            .findFirst();
        existing ??= await _isar.categorys
            .filter()
            .nameEqualTo(d.name)
            .findFirst();
        final cat = existing ?? Category(name: d.name, type: d.type);
        cat
          ..name = d.name
          ..type = d.type
          ..isGroup = true
          ..isActive = true
          ..isVariable = false
          ..order = d.order
          ..importKey = null
          ..parentId = null;
        parentIds[d.name] = await _isar.categorys.put(cat);
      }

      // 2. Leaves
      final knownImportKeys = <String>{};
      for (final d in DefaultCategories.defs.where((d) => !d.isGroup)) {
        if (d.importKey != null) knownImportKeys.add(d.importKey!);
        Category? existing;
        if (d.importKey != null) {
          existing = await _isar.categorys
              .filter()
              .importKeyEqualTo(d.importKey!)
              .findFirst();
        }
        existing ??= await _isar.categorys
            .filter()
            .nameEqualTo(d.name)
            .findFirst();
        final cat = existing ?? Category(name: d.name, type: d.type);
        cat
          ..name = d.name
          ..type = d.type
          ..isGroup = false
          ..isVariable = d.isVariable
          ..isRecurring = d.isRecurring
          ..isActive = true
          ..order = d.order
          ..importKey = d.importKey
          ..parentId = d.parent != null ? parentIds[d.parent!] : null;
        await _isar.categorys.put(cat);
      }

      // 3. Deactivate legacy categories not part of the new tree
      final all = await _isar.categorys.where().findAll();
      for (final c in all) {
        if (c.isGroup) continue;
        if (c.importKey == null || !knownImportKeys.contains(c.importKey)) {
          if (c.isActive) {
            c.isActive = false;
            await _isar.categorys.put(c);
          }
        }
      }
    });
  }

  /// All categories, ordered.
  Future<List<Category>> getAll() =>
      _isar.categorys.where().sortByOrder().findAll();

  /// Top-level categories (principal groups + standalone), by type.
  Future<List<Category>> getTopLevel(TransactionType type) =>
      _isar.categorys
          .filter()
          .typeEqualTo(type)
          .and()
          .parentIdIsNull()
          .sortByOrder()
          .findAll();

  /// Children of a principal category.
  Future<List<Category>> getChildren(int parentId) =>
      _isar.categorys
          .filter()
          .parentIdEqualTo(parentId)
          .sortByOrder()
          .findAll();

  /// Active LEAF categories of a type (for the transaction selector).
  /// Excludes principal groups so transactions attach to subcategories.
  Future<List<Category>> getLeaves(TransactionType type) async {
    final all = await _isar.categorys
        .filter()
        .typeEqualTo(type)
        .and()
        .isActiveEqualTo(true)
        .sortByOrder()
        .findAll();
    return all.where((c) => !c.isGroup).toList();
  }

  /// Kept for backward compatibility: active non-group categories of a type.
  Future<List<Category>> getActive(TransactionType type) => getLeaves(type);

  Future<Category?> getById(int id) => _isar.categorys.get(id);

  Future<Category?> getByImportKey(String key) =>
      _isar.categorys.filter().importKeyEqualTo(key).findFirst();

  /// Ids of [categoryId] plus all its direct children (2-level tree).
  Future<List<int>> getSelfAndDescendantIds(int categoryId) async {
    final children = await getChildren(categoryId);
    return [categoryId, ...children.map((c) => c.id)];
  }

  Future<int> insert(Category c) =>
      _isar.writeTxn(() => _isar.categorys.put(c));

  Future<void> update(Category c) =>
      _isar.writeTxn(() => _isar.categorys.put(c));

  /// Move a subcategory under a different principal (or to top-level).
  Future<void> setParent(Category c, int? parentId) async {
    c.parentId = parentId;
    await _isar.writeTxn(() => _isar.categorys.put(c));
  }

  Future<void> hide(Category c) async {
    c.isActive = false;
    await _isar.writeTxn(() => _isar.categorys.put(c));
  }

  Future<void> delete(int id) =>
      _isar.writeTxn(() => _isar.categorys.delete(id));

  /// Wipe all categories (used by full data reset).
  Future<void> clearAll() =>
      _isar.writeTxn(() => _isar.categorys.clear());
}
