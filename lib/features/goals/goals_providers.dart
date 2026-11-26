import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/savings_goal.dart';
import '../../data/providers.dart';

/// Active savings goals. Invalidate to refresh after mutations.
final savingsGoalsProvider =
    FutureProvider.autoDispose<List<SavingsGoal>>((ref) async {
  final repo = await ref.watch(savingsGoalRepoProvider.future);
  return repo.getActive();
});
