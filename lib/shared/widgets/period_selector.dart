import 'package:flutter/material.dart';

import 'package:noova_finance/theme/app_theme.dart';
import '../../core/utils/date_utils.dart';

/// Period granularity used across Análisis/Consumo.
enum PeriodView { quincena, mes, anio }

extension PeriodRangeX on PeriodView {
  /// Inclusive (start, end) for [anchor] at this granularity.
  (DateTime, DateTime) range(DateTime anchor) {
    switch (this) {
      case PeriodView.quincena:
        return (
          QuincenaUtils.quincenaStart(anchor),
          QuincenaUtils.quincenaEnd(anchor),
        );
      case PeriodView.mes:
        return (QuincenaUtils.monthStart(anchor), QuincenaUtils.monthEnd(anchor));
      case PeriodView.anio:
        return (QuincenaUtils.yearStart(anchor), QuincenaUtils.yearEnd(anchor));
    }
  }

  String label(DateTime anchor) {
    const months = [
      'Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun',
      'Jul', 'Ago', 'Sep', 'Oct', 'Nov', 'Dic'
    ];
    switch (this) {
      case PeriodView.quincena:
        return QuincenaUtils.quincenaLabel(anchor);
      case PeriodView.mes:
        return '${months[anchor.month - 1]} ${anchor.year}';
      case PeriodView.anio:
        return 'Año ${anchor.year}';
    }
  }

  String get textLabel {
    switch (this) {
      case PeriodView.quincena:
        return 'Quincena';
      case PeriodView.mes:
        return 'Mes';
      case PeriodView.anio:
        return 'Año';
    }
  }
}

/// Reusable period selector: SegmentedButton (Quincena/Mes/Año) + chevrons +
/// centered label. Anchors to a [DateTime] the caller advances/shrinks.
class PeriodSelector extends StatelessWidget {
  final PeriodView view;
  final DateTime anchor;
  final ValueChanged<PeriodView> onViewChanged;
  final ValueChanged<int> onShift;

  const PeriodSelector({
    super.key,
    required this.view,
    required this.anchor,
    required this.onViewChanged,
    required this.onShift,
  });

  @override
  Widget build(BuildContext context) {
    final app = context.app;
    return Card(
      child: Padding(
        padding: EdgeInsets.all(app.spacing.md),
        child: Column(
          children: [
            SegmentedButton<PeriodView>(
              showSelectedIcon: false,
              segments: [
                for (final v in PeriodView.values)
                  ButtonSegment(value: v, label: Text(v.textLabel)),
              ],
              selected: {view},
              onSelectionChanged: (s) => onViewChanged(s.first),
            ),
            SizedBox(height: app.spacing.sm),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  onPressed: () => onShift(-1),
                  icon: const Icon(Icons.chevron_left),
                  tooltip: 'Periodo anterior',
                ),
                Expanded(
                  child: Semantics(
                    liveRegion: true,
                    child: Text(
                      view.label(anchor),
                      textAlign: TextAlign.center,
                      style: theme(context).textTheme.titleMedium
                          ?.copyWith(fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => onShift(1),
                  icon: const Icon(Icons.chevron_right),
                  tooltip: 'Periodo siguiente',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  ThemeData theme(BuildContext context) => Theme.of(context);
}
