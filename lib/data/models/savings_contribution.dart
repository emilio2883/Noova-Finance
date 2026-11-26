import 'package:isar/isar.dart';

part 'savings_contribution.g.dart';

/// A single contribution (aporte) to a savings goal, with its date.
@collection
class SavingsContribution {
  Id id = Isar.autoIncrement;

  @Index()
  int goalId;

  int amountBps;

  DateTime date;

  DateTime? createdAt;

  SavingsContribution({
    required this.goalId,
    required this.amountBps,
    required this.date,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();
}
