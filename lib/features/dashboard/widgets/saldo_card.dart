import 'package:flutter/material.dart';

import '../../../core/theme.dart';

/// Big current-saldo card at the top of the dashboard.
class SaldoCard extends StatelessWidget {
  final String saldoFormatted;

  const SaldoCard({super.key, required this.saldoFormatted});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'SALDO ACTUAL',
              style: TextStyle(
                color: NoovaTheme.textSecondary,
                fontSize: 12,
                letterSpacing: 1.5,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              saldoFormatted,
              style: const TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.bold,
                color: NoovaTheme.income,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
