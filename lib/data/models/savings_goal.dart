import 'package:isar/isar.dart';

part 'savings_goal.g.dart';

/// A savings goal (Monzo "Pots" style). Amounts stored in bps (1/10000).
@collection
class SavingsGoal {
  Id id = Isar.autoIncrement;

  late String name;

  int targetBps;
  int savedBps;

  /// Planned period in months (0 = open-ended). Used to compute monthly aporte.
  int periodMonths;

  /// ARGB color for the goal accent.
  int colorArgb;

  /// Simple icon key (mapped in UI).
  String iconName;

  DateTime? deadline;
  bool isActive;

  /// If true, monthly aportes are auto-generated from target/periodMonths.
  bool isRecurring;

  /// year*100+month of the last auto-generated contribution (0 = none).
  int lastAutoMonth;
  DateTime? createdAt;

  SavingsGoal({
    required this.name,
    required this.targetBps,
    this.savedBps = 0,
    this.periodMonths = 0,
    this.colorArgb = 0xFF22A06B,
    this.iconName = 'savings',
    this.deadline,
    this.isActive = true,
    this.isRecurring = false,
    this.lastAutoMonth = 0,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();
}
