# Noova Finance — Fase 1 (003-phase1) · Plan de arquitectura

Documento vivo. Se actualiza al cerrar cada feature. Estado: en progreso.

## Principios
- Offline-first, 100% local. Sin red ni analytics. Riverpod 2.6 (no v3). Isar 3.
- Dinero con `Decimal` + `amountBps`; nunca `double`.
- Estilo vía tokens `context.app` (colores/espaciados/radios/motion). Gate
  `tool/check_raw_values.dart` en 0 fatsales.
- Tras cualquier mutación: invalidar `dashboardProvider` y, si aplica,
  `RecurringGenerator.generateDue()`.
- Navegación inferior fija (Consumo/Presupuestos/Inicio/Metas/Ajustes) sin
  cambios; pantallas nuevas por `context.push(...)`.

## Features
### 1) Gráficos reales (Análisis)  ✅
- `lib/features/charts/charts_screen.dart`: ruta `/charts`, con
  `PeriodSelector` reutilizable (`lib/shared/widgets/period_selector.dart`).
- fl_chart: dona (gastos por categoría principal, top 6 + Otros),
  línea de saldo acumulado 12 meses (`SaldoCalculator.saldoMensual` +
  `QuincenaUtils.lastMonthEnds`), barras Ingresos vs Gastos por mes.
- Colores desde `context.app.colors`; estados vacío/error/loading con
  widgets compartidos; `Semantics` en cada gráfico.
- Entradas: acción en AppBar de Inicio (`Icons.insights_outlined`) e
  `Icons.bar_chart` en AppBar de Consumo.
- Criterio: las 3 gráficas usan datos reales y cambian al mover el periodo.

### 2) Comparativos y promedios  ⏳
### 3) Búsqueda y filtros avanzados  ⏳
### 4) UI de recurrentes + calendario de pagos  ⏳
### 5) Gestor de suscripciones  ⏳
### 6) Export CSV/PDF + respaldo/restauración  ⏳
### 7) Onboarding guiado  ⏳

## Gates por feature
`flutter analyze` (0) · `dart run tool/check_raw_values.dart` (exit 0) ·
`flutter test` (verde) · `flutter build apk --debug` (compila).
