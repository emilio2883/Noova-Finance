import 'package:flutter/material.dart';

import 'package:noova_finance/theme/app_theme.dart';

/// Big current-saldo card at the top of the dashboard.
class SaldoCard extends StatelessWidget {
  final String saldoFormatted;

  const SaldoCard({super.key, required this.saldoFormatted});

  @override
  Widget build(BuildContext context) {
    final c = context.app.colors;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'SALDO ACTUAL',
              style: TextStyle(
                color: c.textSecondary,
                fontSize: 12,
                letterSpacing: 1.5,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              saldoFormatted,
              style: TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.bold,
                color: c.income,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
