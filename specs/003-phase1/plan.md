# Noova Finance — Fase 1 (003-phase1) · Plan de arquitectura

Documento vivo. Todas las features 1–7 implementadas; gates por feature verificados.

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

### 2) Comparativos y promedios  ✅
- `SaldoCalculator.deltaPeriodo / pctCambio / promedioDiario` (puros, testeados).
- `lib/features/charts/comparatives.dart`: deltas vs periodo anterior,
  promedios (diario / mes / quincena, 3m), tendencia de gasto, top movers.
- Sección "Comparativos" en Análisis. Tests: `comparatives_test.dart` (3).
### 3) Búsqueda y filtros avanzados  ✅
- `SearchFilters` + `TransactionRepository.search` (Isar por fecha; Dart por
  tipo/categoría/monto/recurrente/texto).
- `features/search/`: `SearchFiltersNotifier` (debounce) + pantalla con texto,
  tipo, multi-categoría, rango de fechas, importe, solo recurrentes; cabecera
  con conteo y totales; tap -> detalle. Ruta /search (Inicio, Consumo, Ajustes).
### 4) Recurrentes + calendario  ✅
- `RecurringRule` amplía label/isSubscription/reminderDaysBefore (+ Isar).
- `features/recurring/`: editor (categoría, monto, tipo, frecuencia, día,
  fechas, activa, etiqueta) + pantalla con toggle, editar, borrar y "Próximos
  pagos" 90 días. Ruta /recurring. Tras cambios: generateDue + dashboard.
### 5) Gestor de suscripciones  ✅
- `subscriptions_logic.dart`: total mensual/anual (quincenal x2), pausadas
  excluidas (tested). Pantalla con total, proyección y alta/edición vía
  `RecurringEditorSheet(isSubscription)`, pausar/reanudar, borrar.
- `NotificationService.scheduleBillReminder` (id 2000+ruleId); reprogramación
  en arranque (`main.dart`). Ruta /subscriptions.
### 6) Export CSV/PDF + backup/restore  ✅
- `csv_exporter.dart` (buildCsv puro, tested), `pdf_exporter.dart` (pdf+printing),
  `backup_service.dart` (snapshot JSON versionado + restore con ids, tested).
- Ajustes: Exportar CSV, Exportar PDF, Respaldar, Restaurar (file_picker +
  confirmación + invalidación de providers).
### 7) Onboarding guiado  ✅
- `AppSettings.onboardingDone` (+ Isar); `core/app_flags.dart` para el redirect
  síncrono; `features/onboarding/onboarding_screen.dart` (3 pasos). Ruta
  /onboarding; usuarios existentes (con datos) se marcan done en el arranque.

## Gates por feature
`flutter analyze` (0) · `dart run tool/check_raw_values.dart` (exit 0) ·
`flutter test` (verde) · `flutter build apk --debug` (compila).
