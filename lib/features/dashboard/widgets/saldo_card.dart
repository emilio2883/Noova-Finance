import 'package:flutter/material.dart';

import 'package:noova_finance/theme/app_radii.dart';
import 'package:noova_finance/theme/app_theme.dart';

/// Hero current-saldo card (navy gradient, reference look & feel).
class SaldoCard extends StatelessWidget {
  final String saldoFormatted;

  const SaldoCard({super.key, required this.saldoFormatted});

  @override
  Widget build(BuildContext context) {
    final c = context.app.colors;
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [c.hero, Color.lerp(c.hero, c.primary, 0.18)!],
        ),
        borderRadius: AppRadii.standard.brXl,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.account_balance_wallet_outlined,
                  size: 18, color: c.onHero.withValues(alpha: 0.85)),
              const SizedBox(width: 8),
              Text('SALDO ACTUAL',
                  style: TextStyle(
                      color: c.onHero.withValues(alpha: 0.85),
                      fontSize: 12,
                      letterSpacing: 1.5)),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            saldoFormatted,
            style: TextStyle(
              color: c.onHero,
              fontSize: 40,
              fontWeight: FontWeight.bold,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
          const SizedBox(height: 4),
          Text('Disponible',
              style: TextStyle(
                  color: c.onHero.withValues(alpha: 0.7), fontSize: 12)),
        ],
      ),
    );
  }
}
