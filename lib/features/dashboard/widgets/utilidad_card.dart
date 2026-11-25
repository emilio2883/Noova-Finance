import 'package:flutter/material.dart';

import '../../../core/theme.dart';

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
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              child: _MiniStat(label: 'Ingresos', value: ingresos, color: NoovaTheme.income),
            ),
            Expanded(
              child: _MiniStat(label: 'Gastos', value: gastos, color: NoovaTheme.expense),
            ),
            Expanded(
              child: _MiniStat(
                label: 'Utilidad',
                value: utilidad,
                color: utilidadPositiva ? NoovaTheme.income : NoovaTheme.expense,
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
            color: NoovaTheme.textSecondary,
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
