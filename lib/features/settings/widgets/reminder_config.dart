import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/services/notification_service.dart';

import '../../../data/providers.dart';
import 'package:noova_finance/theme/app_theme.dart';

/// Daily registration reminder config (US11).
/// Toggle + time picker -> schedules a daily local notification.
class ReminderConfig extends ConsumerStatefulWidget {
  const ReminderConfig({super.key});

  @override
  ConsumerState<ReminderConfig> createState() => _ReminderConfigState();
}

class _ReminderConfigState extends ConsumerState<ReminderConfig> {
  bool _enabled = false;
  int _hour = 20;
  int _minute = 0;
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final repo = await ref.read(settingsRepoProvider.future);
    final settings = await repo.get();
    if (mounted) {
      setState(() {
        _enabled = settings.reminderEnabled;
        _hour = settings.reminderHour;
        _minute = settings.reminderMinute;
        _loaded = true;
      });
    }
  }

  Future<void> _persist() async {
    final repo = await ref.read(settingsRepoProvider.future);
    final settings = await repo.get();
    settings.reminderEnabled = _enabled;
    settings.reminderHour = _hour;
    settings.reminderMinute = _minute;
    await repo.update(settings);

    if (_enabled) {
      await NotificationService.scheduleDailyReminder(
        hour: _hour,
        minute: _minute,
      );
    } else {
      await NotificationService.cancelReminders();
    }
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: _hour, minute: _minute),
    );
    if (picked != null) {
      setState(() {
        _hour = picked.hour;
        _minute = picked.minute;
      });
      await _persist();
    }
  }

  String get _timeLabel {
    final h = _hour.toString().padLeft(2, '0');
    final m = _minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  @override
  Widget build(BuildContext context) {
    if (!_loaded) {
      return const SizedBox.shrink();
    }
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Column(
        children: [
          SwitchListTile(
            title: const Text('Recordatorio diario'),
            subtitle: Text(
              _enabled
                  ? 'Aviso diario a las $_timeLabel'
                  : 'Recordatorio desactivado',
              style: const TextStyle(fontSize: 12),
            ),
            activeColor: context.app.colors.primary,
            value: _enabled,
            onChanged: (v) async {
              setState(() => _enabled = v);
              await _persist();
            },
          ),
          if (_enabled)
            ListTile(
              leading: Icon(Icons.schedule, color: context.app.colors.primary),
              title: const Text('Hora del recordatorio'),
              trailing: Text(
                _timeLabel,
                style: const TextStyle(
                    fontWeight: FontWeight.bold, fontSize: 16),
              ),
              onTap: _pickTime,
            ),
        ],
      ),
    );
  }
}
