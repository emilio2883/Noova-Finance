import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';
import 'core/router.dart';
import 'core/services/notification_service.dart';
import 'data/database.dart';
import 'data/repositories/recurring_repo.dart';
import 'data/repositories/savings_goal_repo.dart';
import 'data/repositories/settings_repo.dart';
import 'data/repositories/transaction_repo.dart';
import 'data/models/recurring_rule.dart';
import 'data/models/transaction.dart';
import 'data/services/recurring_generator.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Offline startup: open DB, generate overdue recurring txns (T039),
  // cache PIN state, init local notifications.
  final isar = await AppDatabase.instance;
  final generator = RecurringGenerator(
    RecurringRepository(isar),
    TransactionRepository(isar),
  );
  await generator.generateDue();
  await SavingsGoalRepository(isar).generateRecurring();

  final settings = await SettingsRepository(isar).get();
  UnlockState.instance.pinRequired =
      settings.pinHash?.isNotEmpty ?? false;

  await NotificationService.init();

  // Re-schedule bill/subscription reminders for active rules (offline).
  try {
    final recRepo = RecurringRepository(isar);
    final rules = await recRepo.getActive();
    final now = DateTime.now();
    for (final r in rules) {
      final when = _nextBillDate(r, now);
      if (when == null) continue;
      final remind = when.subtract(Duration(days: r.reminderDaysBefore));
      if (remind.isAfter(now)) {
        await NotificationService.scheduleBillReminder(
          id: 2000 + r.id,
          when: remind,
          title: 'Pago programado',
          body: '${r.label ?? 'Recurrente'} · '
              '${r.type == TransactionType.expense ? 'Cargo' : 'Ingreso'}',
        );
      }
    }
  } catch (_) {
    // Notifications are best-effort; never block startup.
  }

  runApp(
    const ProviderScope(
      child: NoovaApp(),
    ),
  );
}


DateTime? _nextBillDate(RecurringRule r, DateTime now) {
  var y = now.year, m = now.month;
  final startDay = DateTime(r.startDate.year, r.startDate.month, r.startDate.day);
  for (var i = 0; i < 3; i++) {
    final last = DateTime(y, m + 1, 0).day;
    final day = r.activationDay > last ? last : r.activationDay;
    final d = DateTime(y, m, day);
    final okStart = !d.isBefore(startDay);
    final okEnd = r.endDate == null || !d.isAfter(r.endDate!);
    final okNow = !d.isBefore(DateTime(now.year, now.month, now.day));
    if (okStart && okEnd && okNow) return d;
    m++;
    if (m > 12) {
      m = 1;
      y++;
    }
  }
  return null;
}
