import 'dart:convert';
import 'dart:io';

import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../models/app_settings.dart';
import '../models/budget.dart';
import '../models/category.dart';
import '../models/recurring_rule.dart';
import '../models/savings_contribution.dart';
import '../models/savings_goal.dart';
import '../models/transaction.dart';

/// Full local snapshot backup/restore (offline, versioned JSON).
class BackupService {
  final Isar _isar;
  BackupService(this._isar);

  static const int schemaVersion = 1;
  static const List<String> collections = [
    'transactions',
    'categories',
    'budgets',
    'recurringRules',
    'savingsGoals',
    'savingsContributions',
    'settings',
  ];

  String _d(DateTime? d) => d?.toIso8601String() ?? '';
  DateTime? _pd(dynamic s) =>
      (s is String && s.isNotEmpty) ? DateTime.tryParse(s) : null;

  Future<Map<String, dynamic>> _snapshot() async {
    final txns = await _isar.transactions.where().findAll();
    final cats = await _isar.categorys.where().findAll();
    final budgets = await _isar.budgets.where().findAll();
    final rules = await _isar.recurringRules.where().findAll();
    final goals = await _isar.savingsGoals.where().findAll();
    final contribs = await _isar.savingsContributions.where().findAll();
    final settings = await _isar.appSettings.get(0);

    return {
      'schemaVersion': schemaVersion,
      'exportedAt': DateTime.now().toIso8601String(),
      'transactions': [
        for (final t in txns)
          {
            'id': t.id,
            'date': _d(t.date),
            'amountBps': t.amountBps,
            'type': t.type.name,
            'categoryId': t.categoryId,
            'description': t.description,
            'isRecurring': t.isRecurring,
            'recurringRuleId': t.recurringRuleId,
            'importHash': t.importHash,
            'createdAt': _d(t.createdAt),
          }
      ],
      'categories': [
        for (final c in cats)
          {
            'id': c.id,
            'name': c.name,
            'type': c.type.name,
            'isVariable': c.isVariable,
            'isRecurring': c.isRecurring,
            'isActive': c.isActive,
            'order': c.order,
            'importKey': c.importKey,
            'parentId': c.parentId,
            'isGroup': c.isGroup,
          }
      ],
      'budgets': [
        for (final b in budgets)
          {
            'id': b.id,
            'categoryId': b.categoryId,
            'amountPerQuincenaBps': b.amountPerQuincenaBps,
            'alertThreshold': b.alertThreshold,
            'isActive': b.isActive,
            'createdAt': _d(b.createdAt),
          }
      ],
      'recurringRules': [
        for (final r in rules)
          {
            'id': r.id,
            'categoryId': r.categoryId,
            'amountBps': r.amountBps,
            'frequency': r.frequency.name,
            'type': r.type.name,
            'activationDay': r.activationDay,
            'isActive': r.isActive,
            'startDate': _d(r.startDate),
            'endDate': _d(r.endDate),
            'lastGenerated': _d(r.lastGenerated),
            'label': r.label,
            'isSubscription': r.isSubscription,
            'reminderDaysBefore': r.reminderDaysBefore,
          }
      ],
      'savingsGoals': [
        for (final g in goals)
          {
            'id': g.id,
            'name': g.name,
            'targetBps': g.targetBps,
            'savedBps': g.savedBps,
            'periodMonths': g.periodMonths,
            'colorArgb': g.colorArgb,
            'iconName': g.iconName,
            'deadline': _d(g.deadline),
            'isActive': g.isActive,
            'isRecurring': g.isRecurring,
            'lastAutoMonth': g.lastAutoMonth,
            'createdAt': _d(g.createdAt),
          }
      ],
      'savingsContributions': [
        for (final c in contribs)
          {
            'id': c.id,
            'goalId': c.goalId,
            'amountBps': c.amountBps,
            'date': _d(c.date),
            'createdAt': _d(c.createdAt),
          }
      ],
      'settings': settings == null
          ? null
          : {
              'id': settings.id,
              'pinHash': settings.pinHash,
              'biometricEnabled': settings.biometricEnabled,
              'reminderEnabled': settings.reminderEnabled,
              'reminderHour': settings.reminderHour,
              'reminderMinute': settings.reminderMinute,
              'defaultCurrency': settings.defaultCurrency,
              'themeMode': settings.themeMode,
              'themeChoiceMade': settings.themeChoiceMade,
              'userName': settings.userName,
              'isImported': settings.isImported,
              'lastExportDate': _d(settings.lastExportDate),
            },
    };
  }

  Future<String> exportJson() async => jsonEncode(await _snapshot());

  Future<File> exportAndShare() async {
    final json = await exportJson();
    final dir = await getApplicationDocumentsDirectory();
    final now = DateTime.now();
    final name =
        'noova_backup_${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}.noova';
    final f = File('${dir.path}/$name');
    await f.writeAsString(json);
    await Share.shareXFiles([XFile(f.path)], text: 'Respaldo Noova Finance');
    return f;
  }

  TransactionType _type(String s) =>
      s == 'income' ? TransactionType.income : TransactionType.expense;
  RecurringFrequency _freq(String s) =>
      s == 'quincenal' ? RecurringFrequency.quincenal : RecurringFrequency.monthly;

  /// Restore from a JSON snapshot. Validates version and replaces data.
  Future<void> restoreJson(String json) async {
    final data = jsonDecode(json) as Map<String, dynamic>;
    final version = data['schemaVersion'];
    if (version is! int || version < 1) {
      throw const FormatException('Respaldo inválido: schemaVersion ausente');
    }
    if (version > schemaVersion) {
      throw const FormatException('Respaldo de una versión más nueva');
    }

    final txns = <Transaction>[
      for (final m in (data['transactions'] as List? ?? []))
        (Transaction(
          date: _pd(m['date']) ?? DateTime.now(),
          amountBps: m['amountBps'] as int,
          type: _type(m['type'] as String? ?? 'expense'),
          categoryId: m['categoryId'] as int,
          description: m['description'] as String?,
          isRecurring: m['isRecurring'] as bool? ?? false,
          recurringRuleId: m['recurringRuleId'] as int?,
          importHash: m['importHash'] as String?,
        ))
          ..id = m['id'] as int
    ];
    final cats = <Category>[
      for (final m in (data['categories'] as List? ?? []))
        (Category(name: m['name'] as String, type: _type(m['type'] as String? ?? 'expense'))
          ..id = m['id'] as int
          ..isVariable = m['isVariable'] as bool? ?? false
          ..isRecurring = m['isRecurring'] as bool? ?? false
          ..isActive = m['isActive'] as bool? ?? true
          ..order = m['order'] as int? ?? 0
          ..importKey = m['importKey'] as String?
          ..parentId = m['parentId'] as int?
          ..isGroup = m['isGroup'] as bool? ?? false)
    ];
    final budgets = <Budget>[
      for (final m in (data['budgets'] as List? ?? []))
        (Budget(
          categoryId: m['categoryId'] as int,
          amountPerQuincenaBps: m['amountPerQuincenaBps'] as int,
          alertThreshold: m['alertThreshold'] as int? ?? 80,
          isActive: m['isActive'] as bool? ?? true,
        ))
          ..id = m['id'] as int
    ];
    final rules = <RecurringRule>[
      for (final m in (data['recurringRules'] as List? ?? []))
        (RecurringRule(
          categoryId: m['categoryId'] as int,
          amountBps: m['amountBps'] as int,
          frequency: _freq(m['frequency'] as String? ?? 'monthly'),
          type: _type(m['type'] as String? ?? 'expense'),
          activationDay: m['activationDay'] as int? ?? 1,
          isActive: m['isActive'] as bool? ?? true,
          startDate: _pd(m['startDate']) ?? DateTime.now(),
          endDate: _pd(m['endDate']),
          lastGenerated: _pd(m['lastGenerated']),
          label: m['label'] as String?,
          isSubscription: m['isSubscription'] as bool? ?? false,
          reminderDaysBefore: m['reminderDaysBefore'] as int? ?? 0,
        ))
          ..id = m['id'] as int
    ];
    final goals = <SavingsGoal>[
      for (final m in (data['savingsGoals'] as List? ?? []))
        (SavingsGoal(
          name: m['name'] as String,
          targetBps: m['targetBps'] as int,
          savedBps: m['savedBps'] as int? ?? 0,
          periodMonths: m['periodMonths'] as int? ?? 0,
          colorArgb: m['colorArgb'] as int? ?? 0xFF22A06B,
          iconName: m['iconName'] as String? ?? 'savings',
          deadline: _pd(m['deadline']),
          isActive: m['isActive'] as bool? ?? true,
          isRecurring: m['isRecurring'] as bool? ?? false,
          lastAutoMonth: m['lastAutoMonth'] as int? ?? 0,
        ))
          ..id = m['id'] as int
    ];
    final contribs = <SavingsContribution>[
      for (final m in (data['savingsContributions'] as List? ?? []))
        (SavingsContribution(
          goalId: m['goalId'] as int,
          amountBps: m['amountBps'] as int,
          date: _pd(m['date']) ?? DateTime.now(),
        ))
          ..id = m['id'] as int
    ];

    await _isar.writeTxn(() async {
      await _isar.transactions.clear();
      await _isar.categorys.clear();
      await _isar.budgets.clear();
      await _isar.recurringRules.clear();
      await _isar.savingsGoals.clear();
      await _isar.savingsContributions.clear();
      await _isar.transactions.putAll(txns);
      await _isar.categorys.putAll(cats);
      await _isar.budgets.putAll(budgets);
      await _isar.recurringRules.putAll(rules);
      await _isar.savingsGoals.putAll(goals);
      await _isar.savingsContributions.putAll(contribs);
      final s = data['settings'];
      if (s is Map<String, dynamic>) {
        final settings = AppSettings(
          pinHash: s['pinHash'] as String?,
          biometricEnabled: s['biometricEnabled'] as bool? ?? false,
          reminderEnabled: s['reminderEnabled'] as bool? ?? false,
          reminderHour: s['reminderHour'] as int? ?? 20,
          reminderMinute: s['reminderMinute'] as int? ?? 0,
          defaultCurrency: s['defaultCurrency'] as String? ?? 'USD',
          themeMode: s['themeMode'] as String? ?? 'light',
          themeChoiceMade: s['themeChoiceMade'] as bool? ?? false,
          userName: s['userName'] as String?,
          isImported: s['isImported'] as bool? ?? false,
          lastExportDate: _pd(s['lastExportDate']),
        )..id = 0;
        await _isar.appSettings.put(settings);
      }
    });
  }

  Future<void> restoreFile(File file) async =>
      restoreJson(await file.readAsString());
}
