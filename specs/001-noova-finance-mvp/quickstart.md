# Quickstart: Noova Finance MVP — Validation Scenarios

**Branch**: `001-noova-finance-mvp`

Key scenarios to validate the MVP end-to-end. Run these after building the app.

## Prerequisites

- Flutter 3.27.x installed (`flutter doctor`)
- A device/emulator connected (`flutter devices`)
- The real Excel file `Estado Financiero-2.xlsx` available on the device

## Scenario 1: First launch with empty data

1. Launch the app
2. **Expect**: Dashboard shows with saldo $0.00, empty recent transactions list
3. **Expect**: 26 categories seeded (verify in Ajustes > Categorias)

## Scenario 2: Import historical Excel

1. Go to Ajustes > Importar Excel
2. Pick `Estado Financiero-2.xlsx`
3. **Expect**: Import completes in < 30s (SC-002)
4. **Expect**: Report shows imported count, 0 or few unknown rows
5. **Expect**: Dashboard saldo matches the Excel's latest Saldo Final (~$117k as of Nov 2026)
6. Re-import the same file
7. **Expect**: 0 new transactions, all duplicates skipped (idempotency, FR-027)

## Scenario 3: Quick transaction registration

1. From dashboard, tap "+"
2. Enter amount 25.50, pick "Restaurante", date = today
3. Tap Guardar
4. **Expect**: Modal closes, dashboard updates instantly
5. **Expect**: Total time < 10 seconds (SC-001)
6. **Expect**: Transaction appears at top of recent list

## Scenario 4: Quincenal view

1. Tap "Quincena" in bottom nav
2. **Expect**: Current quincena with category totals, ingresos/gastos/utilidad
3. Navigate back 2 quincenas with the chevron
4. **Expect**: Historical data from the import appears

## Scenario 5: Charts

1. Tap "Graficos" in bottom nav
2. **Expect**: Bar chart of this month's expenses by category (Casa should dominate)
3. **Expect**: Line chart with 12 months of saldo history from the import

## Scenario 6: Category management

1. Ajustes > Categorias > create "Gym" (gasto, variable)
2. **Expect**: Appears in the "+" category selector
3. Hide it
4. **Expect**: Disappears from selector; past transactions unaffected

## Scenario 7: Budgets

1. Ajustes > Presupuestos
2. Enable budget for "Restaurante", set $400/quincena
3. Register restaurant expenses totaling $320 (80%)
4. **Expect**: Alert notification at the 80% threshold (FR-016)

## Scenario 8: Export

1. Ajustes > Exportar a Excel
2. **Expect**: .xlsx file generated
3. Open in Excel
4. **Expect**: Sheets per year with category rows and quincena columns (SC-008)

## Scenario 9: Offline operation

1. Enable airplane mode
2. Register a transaction, view dashboard, quincenal, charts
3. **Expect**: Everything works — no network call (SC-005)

## Verification checklist

- [ ] flutter analyze: no issues
- [ ] flutter test: all pass
- [ ] All 9 scenarios validated on device
