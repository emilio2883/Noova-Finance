---

description: "Task list for Noova Finance MVP implementation"
---

# Tasks: Noova Finance MVP

**Input**: Design documents from `/specs/001-noova-finance-mvp/`

**Prerequisites**: plan.md (required), spec.md (required), data-model.md (required)

**Tests**: TDD is non-negotiable per constitution. Tests written FIRST, must FAIL before implementation.

**Organization**: Tasks grouped by user story for independent implementation and testing.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: Which user story this task belongs to (e.g., US1, US2, US3)
- Include exact file paths in descriptions

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: Flutter project initialization and basic structure

- [x] T001 Initialize Flutter project with `flutter create noova_finance` and configure pubspec.yaml with all dependencies (riverpod, isar, fl_chart, excel, syncfusion_flutter_xlsio, local_auth, flutter_local_notifications, flutter_secure_storage, intl, decimal, file_picker)
- [x] T002 [P] Configure dark theme in lib/core/theme.dart (background #1A1A2E, card #16213E, accent green #00E676 for income, accent red #FF5252 for expense, text #E0E0E0)
- [x] T003 [P] Configure GoRouter navigation in lib/core/router.dart with routes: /lock, /dashboard, /quincenal, /charts, /budgets, /categories, /import, /settings
- [x] T004 [P] Create utility files: lib/core/utils/decimal_utils.dart, date_utils.dart, money_format.dart

**Checkpoint**: Flutter project compiles with `flutter analyze` passing

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Core data layer that MUST be complete before ANY user story

**⚠️ CRITICAL**: No user story work can begin until this phase is complete

- [x] T005 Setup Isar database instance in lib/data/database.dart with all 5 collections (Transaction, Category, RecurringRule, Budget, AppSettings)
- [x] T006 [P] [US-all] Create Category model in lib/data/models/category.dart per data-model.md
- [x] T007 [P] [US-all] Create Transaction model in lib/data/models/transaction.dart per data-model.md
- [x] T008 [P] [US-all] Create RecurringRule model in lib/data/models/recurring_rule.dart per data-model.md
- [x] T009 [P] [US-all] Create Budget model in lib/data/models/budget.dart per data-model.md
- [x] T010 [P] [US-all] Create AppSettings model in lib/data/models/app_settings.dart per data-model.md
- [x] T011 [P] [US-all] Create CategoryRepository in lib/data/repositories/category_repo.dart (CRUD + seed defaults)
- [x] T012 [P] [US-all] Create TransactionRepository in lib/data/repositories/transaction_repo.dart (CRUD + date-range queries + saldo calc)
- [x] T013 [P] [US-all] Create RecurringRepository in lib/data/repositories/recurring_repo.dart (CRUD + find due rules)
- [x] T014 [P] [US-all] Create BudgetRepository in lib/data/repositories/budget_repo.dart (CRUD + find by category)
- [x] T015 [P] [US-all] Create SettingsRepository in lib/data/repositories/settings_repo.dart (singleton get/update)
- [x] T016 Seed default categories on first launch using the 26 categories from data-model.md
- [x] T017 [P] [US-all] Create SaldoCalculator in lib/data/services/saldo_calculator.dart (saldo, utilidad, quincena grouping)

**Checkpoint**: Data layer ready — all models, repos, and services tested and passing

---

## Phase 3: User Story 1 — Quick Transaction Registration (Priority: P1) 🎯 MVP

**Goal**: User can register a transaction in 3 taps from home screen

**Independent Test**: Open app → tap "+" → enter amount + category → save → transaction appears in recent list

### Tests for User Story 1

- [x] T018 [P] [US1] Unit test for TransactionRepository.insert in test/data/repositories/transaction_repo_test.dart
- [x] T019 [P] [US1] Widget test for QuickAddModal in test/features/quick_add_test.dart

### Implementation for User Story 1

- [x] T020 [P] [US1] Create shared AmountInput widget in lib/shared/widgets/amount_input.dart (numeric keypad, decimal support)
- [x] T021 [P] [US1] Create shared CategorySelector widget in lib/shared/widgets/category_selector.dart (dropdown filtered by type)
- [x] T022 [P] [US1] Create shared DatePickerField widget in lib/shared/widgets/date_picker_field.dart (defaults to today)
- [x] T023 [US1] Create QuickAddModal in lib/features/transaction/quick_add_modal.dart (amount → category → date → save, income/expense toggle)
- [x] T024 [US1] Create TransactionProvider in lib/features/transaction/providers/transaction_provider.dart (Riverpod provider for insert/delete/update)

**Checkpoint**: User can register a transaction and it persists in Isar

---

## Phase 4: User Story 2 — Import Historical Data from Excel (Priority: P1) 🎯 MVP

**Goal**: Import Y24/Y25/Y26 from Estado Financiero-2.xlsx into local database

**Independent Test**: Select Excel file → confirm mapping → verify transactions from all 3 sheets appear with correct amounts

### Tests for User Story 2

- [x] T025 [P] [US2] Unit test for ExcelImporter.parseSheet in test/data/services/excel_importer_test.dart (parse Y26 sheet, verify category names and amounts)
- [x] T026 [P] [US2] Unit test for import idempotency (import twice → no duplicates)

### Implementation for User Story 2

- [x] T027 [P] [US2] Create ExcelImporter service in lib/data/services/excel_importer.dart (read .xlsx, parse sheets by name Y24/Y25/Y26, map rows to categories, extract quincena columns, generate importHash per transaction)
- [x] T028 [US2] Create ImportScreen in lib/features/import/import_screen.dart (file picker, preview mapping, confirm, progress indicator, success/error states)

**Checkpoint**: Full Excel import works — 2+ years of data loaded

---

## Phase 5: User Story 3 — Dashboard with Saldo and Utilidad (Priority: P1) 🎯 MVP

**Goal**: Dashboard shows saldo, monthly ingresos/gastos, utilidad, and recent transactions

**Independent Test**: Open app → see saldo, utilidad, recent transactions list

### Tests for User Story 3

- [x] T029 [P] [US3] Unit test for SaldoCalculator in test/data/services/saldo_calculator_test.dart (verify saldo = sum of all txns, utilidad = ingresos - gastos)
- [x] T030 [P] [US3] Widget test for DashboardScreen in test/features/dashboard_test.dart

### Implementation for User Story 3

- [x] T031 [P] [US3] Create SaldoCard widget in lib/features/dashboard/widgets/saldo_card.dart (current saldo, formatted USD)
- [x] T032 [P] [US3] Create UtilidadCard widget in lib/features/dashboard/widgets/utilidad_card.dart (monthly ingresos, gastos, net, color-coded)
- [x] T033 [P] [US3] Create RecentTransactions widget in lib/features/dashboard/widgets/recent_transactions.dart (last 15 txns, tap to edit)
- [x] T034 [P] [US3] Create QuickAddButton widget in lib/features/dashboard/widgets/quick_add_button.dart (FAB with "+" icon, opens QuickAddModal)
- [x] T035 [US3] Create DashboardProvider in lib/features/dashboard/providers/dashboard_provider.dart (Riverpod: saldo, utilidad, recent txns — recomputes on new txn)
- [x] T036 [US3] Create DashboardScreen in lib/features/dashboard/dashboard_screen.dart (compose all widgets, bottom nav bar)

**Checkpoint**: Dashboard fully functional — MVP (US1+US2+US3) is usable

---

## Phase 6: User Story 4 — Automatic Recurring Expenses (Priority: P2)

**Goal**: Recurring expenses auto-generate each quincena

**Independent Test**: Define recurring rule → advance date → verify auto-generated transaction

### Tests for User Story 4

- [x] T037 [P] [US4] Unit test for RecurringGenerator in test/data/services/recurring_generator_test.dart

### Implementation for User Story 4

- [x] T038 [US4] Create RecurringGenerator service in lib/data/services/recurring_generator.dart (find due rules, generate transactions, update lastGenerated)
- [ ] T039 [US4] Hook RecurringGenerator into app startup (run on app launch, generate any overdue recurring txns)
- [ ] T040 [US4] Add recurring rule management UI in lib/features/settings/ (create/edit/deactivate recurring rules)

**Checkpoint**: Recurring expenses auto-generate correctly

---

## Phase 7: User Story 5 — Quincenal View (Priority: P2)

**Goal**: View finances by quincena like the Excel

**Independent Test**: Navigate to quincenal view → see categories with amounts and totals

### Implementation for User Story 5

- [x] T041 [P] [US5] Create CategoryRow widget in lib/features/quincenal/widgets/category_row.dart (category name, amount, tap for detail)
- [x] T042 [US5] Create QuincenalScreen in lib/features/quincenal/quincenal_screen.dart (date selector for year+quincena, list of category rows, totals footer)

**Checkpoint**: Quincenal view shows data like the Excel

---

## Phase 8: User Story 6 — Charts and Visualizations (Priority: P2)

**Goal**: Bar chart of expenses by category + line chart of monthly saldo

**Independent Test**: Navigate to charts → see bar chart and line chart with real data

### Implementation for User Story 6

- [x] T043 [P] [US6] Create ExpenseBarChart widget in lib/features/charts/widgets/expense_bar_chart.dart (fl_chart BarChart, categories sorted desc, percentages)
- [x] T044 [P] [US6] Create SaldoLineChart widget in lib/features/charts/widgets/saldo_line_chart.dart (fl_chart LineChart, 12+ months of saldo)
- [x] T045 [US6] Create ChartsScreen in lib/features/charts/charts_screen.dart (compose both charts, month selector)

**Checkpoint**: Charts render with real data

---

## Phase 9: User Story 7 — Budgets and Spending Alerts (Priority: P3)

**Goal**: Set budgets for variable categories, get alerts at 80% and 100%

**Independent Test**: Set budget → register expenses to 80% → verify notification

### Tests for User Story 9

- [x] T046 [P] [US7] Unit test for BudgetChecker in test/data/services/budget_checker_test.dart

### Implementation for User Story 7

- [x] T047 [US7] Create BudgetChecker service in lib/data/services/budget_checker.dart (calculate spent per category, compare to budget, trigger notifications)
- [x] T048 [US7] Create BudgetProvider in lib/features/budgets/providers/budget_provider.dart (load budgets, suggest from historical average)
- [x] T049 [US7] Create BudgetsScreen in lib/features/budgets/budgets_screen.dart (list variable categories, suggested amounts, edit thresholds, enable/disable)
- [ ] T050 [US7] Hook BudgetChecker into transaction save flow (after each new expense, check thresholds)

**Checkpoint**: Budgets and alerts work

---

## Phase 10: User Story 8 — App Security (Priority: P3)

**Goal**: PIN or biometric required to open app

**Independent Test**: Enable PIN → close app → reopen → PIN screen appears

### Tests for User Story 10

- [x] T051 [P] [US8] Widget test for LockScreen in test/features/lock_screen_test.dart

### Implementation for User Story 8

- [x] T052 [US8] Create LockScreen in lib/features/auth/lock_screen.dart (PIN pad 0-9, biometric button, 3-strike cooldown)
- [ ] T053 [US8] Create PinSetup widget in lib/features/settings/widgets/pin_setup.dart (first-run PIN creation, confirm PIN)
- [ ] T054 [US8] Store PIN hash in flutter_secure_storage, check on app launch, route to /lock or /dashboard

**Checkpoint**: App requires authentication to access financial data

---

## Phase 11: User Story 9 — Export to Excel (Priority: P3)

**Goal**: Export all data to .xlsx with structure similar to original Excel

### Tests for User Story 11

- [x] T055 [P] [US9] Unit test for ExcelExporter in test/data/services/excel_exporter_test.dart

### Implementation for User Story 9

- [x] T056 [US9] Create ExcelExporter service in lib/data/services/excel_exporter.dart (query all txns, group by year+quincena, build sheets with syncfusion_flutter_xlsio, save file)
- [ ] T057 [US9] Add export button in Settings screen (trigger export, share/save file)

**Checkpoint**: Export produces valid .xlsx

---

## Phase 12: User Story 10 — Category Management (Priority: P3)

**Goal**: Create, rename, hide, reorder categories

### Implementation for User Story 10

- [x] T058 [US10] Create CategoriesScreen in lib/features/categories/categories_screen.dart (list, create, rename, hide, drag-to-reorder)
- [x] T059 [US10] Add category management to Settings navigation

**Checkpoint**: Categories are fully manageable from the app

---

## Phase 13: User Story 11 — Registration Reminder Notifications (Priority: P3)

**Goal**: Daily reminder at configurable time to register transactions

### Implementation for User Story 11

- [ ] T060 [US11] Create ReminderConfig widget in lib/features/settings/widgets/reminder_config.dart (enable/disable, time picker)
- [ ] T061 [US11] Schedule daily local notification via flutter_local_notifications on settings save

**Checkpoint**: Reminders fire at configured time

---

## Phase 14: Polish & Cross-Cutting Concerns

**Purpose**: Final integration, testing, and validation

- [x] T062 [P] Create quickstart.md validation scenarios in specs/001-noova-finance-mvp/quickstart.md
- [ ] T063 Run `flutter analyze` and fix all warnings
- [ ] T064 Run `flutter test` and ensure all tests pass
- [ ] T065 Create integration_test/app_test.dart — end-to-end: unlock → register txn → verify dashboard → view quincenal → view charts
- [ ] T066 Build debug APK and verify on device/emulator
- [ ] T067 Test Excel import with real Estado Financiero-2.xlsx file
- [ ] T068 Test Excel export and verify file opens in Excel

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: No dependencies — start immediately
- **Foundational (Phase 2)**: Depends on Phase 1 — BLOCKS all user stories
- **US1-3 (Phases 3-5)**: All depend on Phase 2. These are P1 and form the MVP.
  - US1 and US3 can partially overlap (shared widgets)
  - US2 is independent (import service)
- **US4-6 (Phases 6-8)**: Depend on Phase 2 + ideally US1 (need transactions to display)
- **US7-11 (Phases 9-13)**: Depend on Phase 2 + US1 (need transaction flow)
- **Polish (Phase 14)**: Depends on all desired user stories being complete

### MVP First Strategy

1. Phase 1 (Setup) → Phase 2 (Foundational) → Phase 3 (US1) → Phase 4 (US2) → Phase 5 (US3)
2. **STOP and VALIDATE**: MVP is usable — can register, import, and see dashboard
3. Then proceed to P2 stories (US4, US5, US6) in any order
4. Then P3 stories (US7-US11) in any order
5. Phase 14 (Polish) last

### Parallel Opportunities

- T002, T003, T004 can run in parallel (Setup)
- T006-T010 can run in parallel (models, different files)
- T011-T015 can run in parallel (repos, different files)
- T020, T021, T022 can run in parallel (shared widgets)
- T031, T032, T033, T034 can run in parallel (dashboard widgets)
- T043, T044 can run in parallel (chart widgets)

---

## Notes

- TDD is non-negotiable: write test → verify it fails → implement → verify it passes
- Commit after each task or logical group
- Stop at any checkpoint to validate independently
- All amounts use Decimal, never double
- All dates are DateTime, quincenas are derived not stored
- Import is idempotent via importHash deduplication
