# Implementation Plan: Noova Finance MVP

**Branch**: `001-noova-finance-mvp` | **Date**: 2026-11-17 | **Spec**: [spec.md](./spec.md)

**Input**: Feature specification from `/specs/001-noova-finance-mvp/spec.md`

## Summary

Noova Finance is a Flutter-based offline-first personal finance mobile app that replaces a manual Excel workflow. The app imports 2+ years of historical financial data from an `.xlsx` file, enables quick transaction registration on the go, auto-generates recurring expenses, displays dashboards with charts, manages budgets with alerts, and exports data back to Excel. All data is stored locally (Isar/SQLite) with PIN/biometric protection. Dark mode UI, single currency (USD/PAB).

## Technical Context

**Language/Version**: Dart 3.x (Flutter 3.27.x stable)

**Primary Dependencies**:
- `flutter_riverpod` — state management
- `isar` + `isar_flutter_libs` — local embedded database (NoSQL, fast, offline)
- `fl_chart` — bar and line charts
- `excel` — read `.xlsx` for import
- `syncfusion_flutter_xlsio` — write `.xlsx` for export
- `local_auth` — biometric (fingerprint/face) unlock
- `flutter_local_notifications` — budget alerts and registration reminders
- `flutter_secure_storage` — PIN hash storage
- `intl` — date/number formatting
- `decimal` — decimal arithmetic for financial calculations
- `file_picker` — select Excel file for import

**Storage**: Isar (embedded NoSQL database on device). No server, no cloud.

**Testing**: `flutter_test` (unit + widget tests), `integration_test` (end-to-end)

**Target Platform**: Android 8.0+ / iOS 12.0+ (single Flutter codebase)

**Project Type**: mobile-app

**Performance Goals**: Dashboard loads < 1s, transaction registration < 10s end-to-end, Excel import < 30s for 3 sheets

**Constraints**: Fully offline (no network calls), dark mode only, single currency USD/PAB, single user, single device

**Scale/Scope**: ~10 screens, 5 entities, ~27 functional requirements, 11 user stories

## Constitution Check

| Principle | Status | Notes |
|-----------|--------|-------|
| I. Offline-First | ✅ Pass | Isar is embedded, no network dependency |
| II. Privacy by Design | ✅ Pass | No analytics, no telemetry, data stays on device |
| III. Test-First | ✅ Pass | TDD enforced — tests written before implementation |
| IV. Simplicity & YAGNI | ✅ Pass | 10 screens, no speculative features, every feature traces to spec |
| V. Data Integrity | ✅ Pass | `decimal` package for arithmetic, idempotent import via hash dedup |
| VI. UX Consistency | ✅ Pass | Dark mode default, 3-tap registration, consistent navigation |

No violations. No complexity tracking needed.

## Project Structure

### Documentation (this feature)

```text
specs/001-noova-finance-mvp/
├── spec.md              # Feature specification
├── plan.md              # This file
├── data-model.md        # Isar schema definitions
├── quickstart.md        # Key validation scenarios
└── tasks.md             # Executable task list
```

### Source Code (repository root)

```text
lib/
├── main.dart                    # App entry point, theme, routing
├── app.dart                     # MaterialApp configuration
├── core/
│   ├── constants.dart           # App constants (currency, categories)
│   ├── theme.dart               # Dark theme definition
│   ├── router.dart              # GoRouter navigation config
│   └── utils/
│       ├── decimal_utils.dart   # Decimal arithmetic helpers
│       ├── date_utils.dart      # Quincena calculation helpers
│       └── money_format.dart    # USD/PAB formatting
├── data/
│   ├── database.dart            # Isar instance setup
│   ├── models/
│   │   ├── transaction.dart     # Transaction entity
│   │   ├── category.dart        # Category entity
│   │   ├── recurring_rule.dart  # RecurringRule entity
│   │   ├── budget.dart          # Budget entity
│   │   └── app_settings.dart    # AppSettings entity
│   ├── repositories/
│   │   ├── transaction_repo.dart
│   │   ├── category_repo.dart
│   │   ├── recurring_repo.dart
│   │   ├── budget_repo.dart
│   │   └── settings_repo.dart
│   └── services/
│       ├── excel_importer.dart  # Parse .xlsx → transactions
│       ├── excel_exporter.dart  # Transactions → .xlsx
│       ├── recurring_generator.dart  # Auto-generate recurring txns
│       ├── budget_checker.dart  # Check budget thresholds
│       └── saldo_calculator.dart # Calculate saldo and utilidad
├── features/
│   ├── auth/
│   │   └── lock_screen.dart     # PIN/biometric unlock
│   ├── dashboard/
│   │   ├── dashboard_screen.dart
│   │   ├── widgets/
│   │   │   ├── saldo_card.dart
│   │   │   ├── utilidad_card.dart
│   │   │   ├── recent_transactions.dart
│   │   │   └── quick_add_button.dart
│   │   └── providers/
│   │       └── dashboard_provider.dart
│   ├── transaction/
│   │   ├── quick_add_modal.dart
│   │   ├── transaction_detail.dart
│   │   └── providers/
│   │       └── transaction_provider.dart
│   ├── quincenal/
│   │   ├── quincenal_screen.dart
│   │   └── widgets/
│   │       └── category_row.dart
│   ├── charts/
│   │   ├── charts_screen.dart
│   │   └── widgets/
│   │       ├── expense_bar_chart.dart
│   │       └── saldo_line_chart.dart
│   ├── budgets/
│   │   ├── budgets_screen.dart
│   │   └── providers/
│   │       └── budget_provider.dart
│   ├── categories/
│   │   └── categories_screen.dart
│   ├── import/
│   │   └── import_screen.dart
│   └── settings/
│       ├── settings_screen.dart
│       └── widgets/
│           ├── pin_setup.dart
│           └── reminder_config.dart
└── shared/
    └── widgets/
        ├── amount_input.dart
        ├── category_selector.dart
        └── date_picker_field.dart

test/
├── data/
│   ├── models/
│   │   ├── transaction_test.dart
│   │   ├── category_test.dart
│   │   └── recurring_rule_test.dart
│   ├── repositories/
│   │   ├── transaction_repo_test.dart
│   │   └── category_repo_test.dart
│   └── services/
│       ├── excel_importer_test.dart
│       ├── excel_exporter_test.dart
│       ├── recurring_generator_test.dart
│       ├── budget_checker_test.dart
│       └── saldo_calculator_test.dart
├── features/
│   ├── dashboard_test.dart
│   ├── quick_add_test.dart
│   └── lock_screen_test.dart
└── core/
    └── utils/
        ├── decimal_utils_test.dart
        └── date_utils_test.dart

integration_test/
└── app_test.dart                 # End-to-end flow tests
```

**Structure Decision**: Single Flutter project (Option 1 adapted for mobile). `lib/` follows feature-first organization with shared core/data layers. Tests mirror the structure. No separate API or backend — all data is local.

## Key Technical Decisions

### 1. Isar vs Drift (SQLite)
**Choice**: Isar
**Rationale**: Isar is a fast NoSQL embedded database for Flutter. It requires no SQL boilerplate, supports complex queries natively, and is optimized for offline-first apps. For a single-user app with 5 entities and ~5000 transactions, Isar's simplicity wins over Drift's SQL mapping overhead.

### 2. Riverpod vs Provider
**Choice**: Riverpod
**Rationale**: Riverpod provides compile-safe dependency injection, better testability (easy override of providers in tests), and no BuildContext dependency. For an app with complex state (dashboard aggregation, budget checking, recurring generation), Riverpod's computed providers and async support are essential.

### 3. Decimal Arithmetic
**Choice**: `decimal` package
**Rationale**: The Excel data has 4 decimal places (e.g., 107652.2599). Floating-point would introduce rounding errors. The `Decimal` type from the `decimal` package preserves precision. All amounts stored as `Decimal`, displayed rounded to 2 places.

### 4. Quincena Calculation
**Choice**: Date-based, derived at query time
**Rationale**: Quincenas are not stored — they are derived from the transaction's DateTime. Quincena 1 = days 1-15, Quincena 2 = days 16-end of month. This allows flexible grouping (by day, week, quincena, month, year) without denormalizing data.

### 5. Import Idempotency
**Choice**: Hash-based deduplication
**Rationale**: Each imported transaction gets a composite hash (date + amount + category + sheet). Before inserting, check if hash exists. If yes, skip. This makes re-import safe.

### 6. Excel Parsing Strategy
**Choice**: Row-based parsing with known structure
**Rationale**: The Excel has a fixed structure: Saldo Inicial row, Ingresos section, Gastos section, category rows. Parse by row name, map to known categories, extract values from quincena columns. Handle 3 sheets (Y24, Y25, Y26) sequentially.
