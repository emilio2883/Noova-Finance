import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:isar/isar.dart';

import 'package:noova_finance/data/models/savings_contribution.dart';
import 'package:noova_finance/data/models/savings_goal.dart';
import 'package:noova_finance/data/repositories/savings_goal_repo.dart';

void main() {
  late Isar isar;
  late SavingsGoalRepository repo;

  setUpAll(() async {
    await Isar.initializeIsarCore(download: true);
    isar = await Isar.open(
      [SavingsGoalSchema, SavingsContributionSchema],
      directory: Directory.systemTemp.path,
      name: 'test_goal_\${DateTime.now().millisecondsSinceEpoch}',
    );
  });

  setUp(() async {
    await isar.writeTxn(() => isar.savingsGoals.clear());
    repo = SavingsGoalRepository(isar);
  });

  tearDownAll(() async {
    await isar.close();
  });

  test('insert + getActive', () async {
    final id = await repo.insert(SavingsGoal(name: 'Viaje', targetBps: 1000000));
    expect(id, greaterThan(0));
    final all = await repo.getActive();
    expect(all.length, 1);
    expect(all.first.name, 'Viaje');
    expect(all.first.savedBps, 0);
  });

  test('addContribution accumulates savedBps', () async {
    final id = await repo.insert(SavingsGoal(name: 'Fondo', targetBps: 500000));
    await repo.addContribution(id, 100000);
    await repo.addContribution(id, 50000);
    final g = await repo.getById(id);
    expect(g!.savedBps, 150000);
  });

  test('delete removes goal', () async {
    final id = await repo.insert(SavingsGoal(name: 'X', targetBps: 10000));
    await repo.delete(id);
    expect(await repo.getById(id), isNull);
  });
}
