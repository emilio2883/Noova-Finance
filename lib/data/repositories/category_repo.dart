import 'package:isar/isar.dart';

import '../models/category.dart';
import '../models/transaction.dart';
import '../seed/default_categories.dart';

/// CRUD + seed for categories.
class CategoryRepository {
  final Isar _isar;
  CategoryRepository(this._isar);

  /// Seed the 26 default categories on first launch (spec FR-008).
  Future<void> seedDefaults() async {
    final count = await _isar.categorys.count();
    if (count > 0) return;
    await _isar.writeTxn(() async {
      await _isar.categorys.putAll(DefaultCategories.all);
    });
  }

  Future<List<Category>> getAll() =>
      _isar.categorys.where().sortByOrder().findAll();

  Future<List<Category>> getActive(TransactionType type) =>
      _isar.categorys
          .filter()
          .isActiveEqualTo(true)
          .and()
          .typeEqualTo(type)
          .sortByOrder()
          .findAll();

  Future<Category?> getById(int id) => _isar.categorys.get(id);

  /// Find by the original Excel row name (import mapping).
  Future<Category?> getByImportKey(String key) =>
      _isar.categorys.filter().importKeyEqualTo(key).findFirst();

  Future<int> insert(Category c) =>
      _isar.writeTxn(() => _isar.categorys.put(c));

  Future<void> update(Category c) =>
      _isar.writeTxn(() => _isar.categorys.put(c));

  /// Hide (deactivate) instead of delete: past transactions stay visible.
  Future<void> hide(Category c) async {
    c.isActive = false;
    await _isar.writeTxn(() => _isar.categorys.put(c));
  }

  Future<void> delete(int id) =>
      _isar.writeTxn(() => _isar.categorys.delete(id));
}
