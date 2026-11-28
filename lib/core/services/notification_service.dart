import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

/// Local notifications wrapper (budget alerts + registration reminders).
/// Fully offline: notifications are scheduled locally, no push service.
class NotificationService {
  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  static bool _initialized = false;

  static Future<void> init() async {
    if (_initialized) return;
    tzdata.initializeTimeZones();
    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings();
    const settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );
    await _plugin.initialize(settings);
    _initialized = true;
  }

  /// Show an immediate notification.
  static Future<void> show({
    required int id,
    required String title,
    required String body,
  }) async {
    if (!_initialized) await init();
    const androidDetails = AndroidNotificationDetails(
      'noova_channel',
      'Noova Finance',
      channelDescription: 'Alertas de presupuesto y recordatorios',
      importance: Importance.high,
      priority: Priority.high,
    );
    const iosDetails = DarwinNotificationDetails();
    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );
    await _plugin.show(id, title, body, details);
  }

  /// Schedule a daily reminder at [hour]:[minute].
  static Future<void> scheduleDailyReminder({
    required int hour,
    required int minute,
  }) async {
    if (!_initialized) await init();
    await _plugin.cancelAll();
    final now = DateTime.now();
    var scheduled = DateTime(now.year, now.month, now.day, hour, minute);
    if (!scheduled.isAfter(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }
    const androidDetails = AndroidNotificationDetails(
      'noova_reminder',
      'Recordatorio diario',
      channelDescription: 'Aviso diario para registrar transacciones',
      importance: Importance.defaultImportance,
      priority: Priority.defaultPriority,
    );
    const iosDetails = DarwinNotificationDetails();
    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );
    await _plugin.zonedSchedule(
      1000,
      'Noova Finance',
      '¿Registraste tus transacciones de hoy?',
      tz.TZDateTime.from(scheduled, tz.local),
      details,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time, // repeats daily
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  /// Cancel all scheduled reminders.
  static Future<void> cancelReminders() async {
    await _plugin.cancel(1000);
  }

  /// Schedule a single bill/subscription reminder at [when] (unique [id]).
  static Future<void> scheduleBillReminder({
    required int id,
    required DateTime when,
    required String title,
    required String body,
  }) async {
    if (!_initialized) await init();
    if (!when.isAfter(DateTime.now())) return;
    const androidDetails = AndroidNotificationDetails(
      'noova_bills',
      'Recordatorios de pago',
      channelDescription: 'Avisos de cobros y suscripciones',
      importance: Importance.high,
      priority: Priority.high,
    );
    const iosDetails = DarwinNotificationDetails();
    const details = NotificationDetails(android: androidDetails, iOS: iosDetails);
    await _plugin.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.from(when, tz.local),
      details,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }
}
