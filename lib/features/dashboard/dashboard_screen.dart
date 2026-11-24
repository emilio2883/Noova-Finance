import 'package:flutter/material.dart';

/// Home dashboard: saldo, utilidad, recent transactions, quick-add FAB.
/// Implemented in Phase 5 (US3).
class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Noova Finance')),
      body: const Center(child: Text('Dashboard - TODO Phase 5')),
    );
  }
}
