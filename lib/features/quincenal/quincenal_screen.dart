import 'package:flutter/material.dart';

/// Quincenal view (Excel-like). Implemented in Phase 7 (US5).
class QuincenalScreen extends StatelessWidget {
  const QuincenalScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Quincenal')),
      body: const Center(child: Text('Quincenal View - TODO Phase 7')),
    );
  }
}
