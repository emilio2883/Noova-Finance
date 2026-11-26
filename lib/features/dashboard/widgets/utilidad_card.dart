import 'package:flutter/material.dart';

import 'package:noova_finance/theme/app_theme.dart';

/// Monthly ingresos / gastos / utilidad summary card.
class UtilidadCard extends StatelessWidget {
  final String ingresos;
  final String gastos;
  final String utilidad;
  final bool utilidadPositiva;

  const UtilidadCard({
    super.key,
    required this.ingresos,
    required this.gastos,
    required this.utilidad,
    required this.utilidadPositiva,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.app.colors;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              child: _MiniStat(label: 'Ingresos', value: ingresos, color: c.income),
            ),
            Expanded(
              child: _MiniStat(label: 'Gastos', value: gastos, color: c.expense),
            ),
            Expanded(
              child: _MiniStat(
                label: 'Utilidad',
                value: utilidad,
                color: utilidadPositiva ? c.income : c.expense,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _MiniStat({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          label.toUpperCase(),
          style: TextStyle(
            color: context.app.colors.textSecondary,
            fontSize: 10,
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 4),
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            value,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ),
      ],
    );
  }
}
