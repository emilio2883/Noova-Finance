import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';
import 'core/router.dart';
import 'core/services/notification_service.dart';
import 'data/database.dart';
import 'data/repositories/recurring_repo.dart';
import 'data/repositories/settings_repo.dart';
import 'data/repositories/transaction_repo.dart';
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

  final settings = await SettingsRepository(isar).get();
  UnlockState.instance.pinRequired =
      settings.pinHash?.isNotEmpty ?? false;

  await NotificationService.init();

  runApp(
    const ProviderScope(
      child: NoovaApp(),
    ),
  );
}
