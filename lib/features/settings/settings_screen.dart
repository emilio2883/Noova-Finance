import 'package:flutter/material.dart';

/// Settings: PIN, reminders, export, import shortcut. Implemented progressively.
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ajustes')),
      body: const Center(child: Text('Settings - TODO')),
    );
  }
}
