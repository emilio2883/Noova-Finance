# Feature Specification: Noova Finance MVP

**Feature Branch**: `001-noova-finance-mvp`

**Created**: 2026-11-17

**Status**: Draft

**Input**: Personal finance mobile app based on 2+ years of historical data tracked manually in Excel (sheets Y24, Y25, Y26). App replaces the Excel workflow with a Flutter offline-first mobile application.

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Quick Transaction Registration (Priority: P1)

As a user, I want to register a transaction (income or expense) in 3 taps from the home screen, so that I can capture spending in the moment without opening a spreadsheet.

**Why this priority**: This is the core value proposition. The Excel requires sitting down at a computer and manually entering data. The app's primary advantage is capturing transactions on the go — at the supermarket, restaurant, gas station. Without this, the app offers nothing the Excel doesn't.

**Independent Test**: Can be fully tested by opening the app, tapping "+", entering an amount and category, and saving. The transaction appears in the recent transactions list on the dashboard.

**Acceptance Scenarios**:

1. **Given** the app is unlocked and on the dashboard, **When** I tap the "+" button, **Then** a registration modal opens with amount input focused, category selector, and today's date pre-filled
2. **Given** the registration modal is open, **When** I enter an amount, select a category, and tap save, **Then** the transaction is persisted locally, the modal closes, and the dashboard updates the saldo and recent transactions list
3. **Given** the registration modal is open, **When** I select "Income" instead of "Expense", **Then** the amount is recorded as positive and the category list switches to income categories
4. **Given** I want to register a transaction with a past date, **When** I tap the date field, **Then** a date picker appears and I can select any date, which determines which quincena the transaction belongs to

---

### User Story 2 - Import Historical Data from Excel (Priority: P1)

As a user, I want to import my existing Excel file with 2+ years of financial data, so that the app starts with my full history and correct saldo inicial from day one.

**Why this priority**: Without historical data, the app is an empty shell. The 2+ years of data in Y24/Y25/Y26 are the foundation for budgets, charts, and saldo continuity. This must happen before the app is useful.

**Independent Test**: Can be tested by selecting the Excel file `Estado Financiero-2.xlsx` from the import screen, confirming the category mapping, and verifying that transactions from Y24, Y25, and Y26 appear with correct amounts and dates.

**Acceptance Scenarios**:

1. **Given** the app is freshly installed with no data, **When** I navigate to Settings > Import and select an `.xlsx` file, **Then** the app parses all sheets (Y24, Y25, Y26), detects categories, and shows a mapping preview
2. **Given** the import preview is shown, **When** I confirm the mapping, **Then** all transactions are inserted into the local database with their exact dates, amounts, categories, and types (income/expense)
3. **Given** the import is complete, **When** I view the dashboard, **Then** the saldo inicial reflects the most recent historical saldo and all past transactions are available in reports
4. **Given** I re-import the same Excel file, **When** the import completes, **Then** no duplicate transactions are created (idempotent import)

---

### User Story 3 - Dashboard with Saldo and Utilidad (Priority: P1)

As a user, I want to see my current saldo and monthly utilidad (net profit/loss) when I open the app, so that I have immediate context on my financial position.

**Why this priority**: The dashboard is the home screen. It must answer "how much do I have?" and "am I gaining or losing this month?" in one glance. This is the first thing seen after unlocking.

**Independent Test**: Can be tested by opening the app and verifying the dashboard shows: current saldo, current month's ingresos, current month's gastos, and current month's utilidad neta (ingresos - gastos).

**Acceptance Scenarios**:

1. **Given** the app has imported historical data, **When** I open the app and unlock it, **Then** the dashboard shows the current saldo (sum of all transactions up to today), this month's total ingresos, total gastos, and utilidad neta
2. **Given** I am on the dashboard, **When** I scroll down, **Then** I see a list of recent transactions (last 10-15) with date, category, and amount
3. **Given** I am on the dashboard, **When** I tap on a transaction in the recent list, **Then** I can view its details and edit or delete it

---

### User Story 4 - Automatic Recurring Expenses (Priority: P2)

As a user, I want recurring fixed expenses (mortgage, insurance, loan payments) to be auto-generated each quincena, so that I don't have to manually register ~15 identical transactions every period.

**Why this priority**: Approximately 60-70% of the user's expenses are recurring and predictable. Automating them eliminates repetitive data entry and ensures fixed costs are never missed. This is what makes the app more efficient than the Excel.

**Independent Test**: Can be tested by defining a recurring expense (e.g., "Casa Augusta/GG: $3,280 every quincena 1"), advancing the system date to the next quincena, and verifying the transaction was auto-generated.

**Acceptance Scenarios**:

1. **Given** I have defined a recurring expense (category, amount, frequency, activation day), **When** the activation day arrives, **Then** the transaction is auto-generated and appears in the quincenal view and dashboard
2. **Given** a recurring expense has been auto-generated, **When** I view it in the transaction list, **Then** it is marked as recurring and I can edit the amount for just this occurrence or for all future occurrences
3. **Given** I want to stop a recurring expense, **When** I deactivate it, **Then** no future transactions are generated but past ones remain unchanged
4. **Given** a recurring expense amount changes (e.g., insurance premium increases), **When** I edit the recurring rule amount, **Then** all future auto-generated transactions use the new amount

---

### User Story 5 - Quincenal View (Priority: P2)

As a user, I want to view my finances organized by quincena (1-15, 15-30) like my Excel, so that I can review all categories and totals for a specific period.

**Why this priority**: The quincenal structure is how the user has organized finances for 2+ years. The view provides the familiar Excel-like detail that the dashboard summarizes. It bridges the old and new workflow.

**Independent Test**: Can be tested by navigating to the quincenal view, selecting a specific year and quincena, and verifying all categories with their amounts and the period totals (ingresos, gastos, utilidad) are displayed.

**Acceptance Scenarios**:

1. **Given** I am in the app, **When** I navigate to the Quincenal View tab, **Then** I see the current quincena with all categories listed, their amounts, and totals for ingresos, gastos, and utilidad neta
2. **Given** I am in the quincenal view, **When** I swipe or use the date selector to change to a different quincena, **Then** the view updates with that period's data
3. **Given** I am in the quincenal view, **When** I tap on a category row, **Then** I see the individual transactions that make up that category's total for the selected quincena

---

### User Story 6 - Charts and Visualizations (Priority: P2)

As a user, I want to see a bar chart of expenses by category and a line chart of my monthly saldo, so that I can visually understand where my money goes and how my saldo trends over time.

**Why this priority**: The Excel has no visualizations. Charts transform raw numbers into instant insight — "Casa is 42% of my expenses" or "my saldo is trending up". This is information that currently requires mental calculation.

**Independent Test**: Can be tested by navigating to the Charts tab and verifying: (a) a bar chart shows expense categories sorted by amount with percentages, and (b) a line chart shows saldo at the end of each month for the past 12+ months.

**Acceptance Scenarios**:

1. **Given** the app has historical data, **When** I navigate to the Charts tab, **Then** I see a bar chart with expense categories for the current month, sorted descending by amount, with percentage of total
2. **Given** I am on the Charts tab, **When** I view the saldo trend chart, **Then** I see a line chart with the saldo at month-end for the past 12 months minimum
3. **Given** I am on the bar chart, **When** I tap on a category bar, **Then** I see the detail of transactions for that category in the current month

---

### User Story 7 - Budgets and Spending Alerts (Priority: P3)

As a user, I want to set budgets for variable expense categories (restaurants, groceries, gas, etc.) and receive alerts when I reach 80% of the budget, so that I can control discretionary spending.

**Why this priority**: Budgets turn passive tracking into active management. The alerts create a feedback loop — "you've spent 80% of your restaurant budget, maybe cook tonight". This requires the data entry habit (P1) to be established first.

**Independent Test**: Can be tested by setting a budget for "Restaurante" at $400/quincena, registering expenses totaling $320, and verifying an alert notification appears at 80% threshold.

**Acceptance Scenarios**:

1. **Given** I have historical data, **When** I navigate to Settings > Budgets, **Then** I see suggested budgets for variable categories based on my average historical spending, which I can accept or adjust
2. **Given** a budget is set for a category, **When** my spending in that category reaches 80% of the budget for the current quincena, **Then** I receive a local notification alerting me
3. **Given** a budget is set, **When** my spending exceeds 100% of the budget, **Then** I receive a notification that the budget has been exceeded
4. **Given** I am in the budget settings, **When** I deactivate a budget, **Then** no further alerts are generated for that category

---

### User Story 8 - App Security (Priority: P3)

As a user, I want the app to require a PIN or biometric authentication to open, so that my financial data is protected if someone accesses my phone.

**Why this priority**: Financial data is sensitive. The lock screen is a standard expectation for any finance app. It's P3 because it doesn't affect functionality, only access control.

**Independent Test**: Can be tested by enabling PIN lock in settings, closing and reopening the app, and verifying the PIN screen appears before any financial data is visible.

**Acceptance Scenarios**:

1. **Given** the app is installed, **When** I first open it, **Then** I am prompted to set a 4-6 digit PIN and optionally enable biometric unlock
2. **Given** the PIN is set, **When** I close and reopen the app, **Then** the lock screen appears requesting the PIN or biometric scan before showing any financial data
3. **Given** the lock screen is showing, **When** I enter an incorrect PIN 3 times, **Then** the app imposes a 30-second cooldown before allowing another attempt
4. **Given** I am in Settings, **When** I change or disable the PIN, **Then** the new setting takes effect on the next app launch

---

### User Story 9 - Export to Excel (Priority: P3)

As a user, I want to export my financial data to an `.xlsx` file, so that I can back up my data, share it with an accountant, or analyze it in Excel.

**Why this priority**: Export provides a safety net — data is never trapped in the app. It also enables continuity with the existing Excel workflow during transition. It's P3 because it's not needed for daily use.

**Independent Test**: Can be tested by navigating to Settings > Export, generating an `.xlsx` file, and verifying it opens in Excel with transactions, categories, and totals similar to the original Excel structure.

**Acceptance Scenarios**:

1. **Given** the app has data, **When** I navigate to Settings > Export and tap "Export to Excel", **Then** an `.xlsx` file is generated with all transactions organized by year and quincena
2. **Given** the export file is generated, **When** I open it in Excel, **Then** the structure resembles the original Excel (sheets per year, columns per quincena, rows per category, with totals)
3. **Given** I want to export a specific date range, **When** I select start and end dates before exporting, **Then** only transactions within that range are included

---

### User Story 10 - Category Management (Priority: P3)

As a user, I want to create, rename, hide, and reorder expense and income categories, so that the app adapts as my financial life changes.

**Why this priority**: Categories are pre-loaded from the Excel but life changes — a new insurance, a canceled subscription, a new person to support. Configurable categories ensure the app stays relevant without code changes. It's P3 because the defaults work for the MVP.

**Independent Test**: Can be tested by navigating to Settings > Categories, creating a new category "Gym", verifying it appears in the category selector during transaction registration, then hiding it and verifying it no longer appears.

**Acceptance Scenarios**:

1. **Given** I am in Settings > Categories, **When** I tap "New Category", **Then** I can enter a name, select type (income/expense), mark as variable or fixed, and save
2. **Given** a category exists, **When** I rename it, **Then** all past and future transactions with that category show the new name
3. **Given** a category exists, **When** I hide it, **Then** it no longer appears in the category selector for new transactions but past transactions with it remain visible
4. **Given** I am in the category list, **When** I drag to reorder, **Then** the new order is persisted and reflected in the category selector

---

### User Story 11 - Registration Reminder Notifications (Priority: P3)

As a user, I want a daily reminder at a configurable time to register my transactions, so that I don't forget to track my spending.

**Why this priority**: The habit of registering is the hardest part of personal finance tracking. A gentle reminder reduces the chance of forgetting and accumulating unregistered expenses. It's P3 because it's a convenience, not core functionality.

**Independent Test**: Can be tested by setting a reminder for 8:00 PM, advancing the device time to 8:00 PM, and verifying a local notification appears asking to register transactions.

**Acceptance Scenarios**:

1. **Given** I am in Settings, **When** I enable registration reminders and set a time (e.g., 8:00 PM), **Then** a daily local notification is scheduled at that time
2. **Given** the reminder is enabled, **When** the scheduled time arrives, **Then** I receive a notification "Have you registered your transactions today?"
3. **Given** I am in Settings, **When** I disable reminders, **Then** no further notifications are sent

---

### Edge Cases

- What happens when the user imports an Excel file with a format different from the expected Y24/Y25/Y26 structure? → Show an error with guidance on expected format
- What happens when a recurring expense falls on a date that doesn't exist (e.g., quincena 2 of February which has 28 days)? → Use the last day of the month
- How does the system handle a transaction with amount 0? → Allow it but warn the user
- What happens when the user deletes a transaction that was auto-generated by a recurring rule? → Delete only that occurrence, future ones still generate
- How does the system handle currency display for amounts with more than 2 decimal places? → Round to 2 decimal places for display, store full precision
- What happens if the user's device biometric sensor is unavailable? → Fall back to PIN-only unlock
- What happens when the saldo calculation encounters a date gap (no transactions for several days)? → Saldo remains constant, no special handling needed

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: System MUST store all financial data locally on the device using an embedded database (SQLite/Isar)
- **FR-002**: System MUST allow registration of a transaction (income or expense) with amount, category, date, and optional description
- **FR-003**: System MUST import transactions from an `.xlsx` file with sheets named Y24, Y25, Y26 containing the user's historical financial data
- **FR-004**: System MUST parse the Excel structure: rows = categories, columns = quincenas (1-15, 15-30) per month, with Saldo Inicial, Ingresos, Gastos, and Utilidad Neta rows
- **FR-005**: System MUST store each transaction with an exact DateTime, not just a quincena identifier
- **FR-006**: System MUST calculate saldo as the sum of all transactions (income positive, expense negative) up to and including the current date
- **FR-007**: System MUST calculate utilidad neta as total ingresos minus total gastos for a given period (quincena, month, or year)
- **FR-008**: System MUST pre-load default categories from the Excel: Salario, Otros Ingresos, Casa Augusta/GG, Casa de playa, Gas, IDAAN, Mantenimiento de Casa, QLU MBA - IFARHU, Progreso, MAFRE Casa, MAFRE Carro, PALIG Salud, Seguro médico padres, Impuesto Sobre la Renta, Seguro Social, Seguro Educativo, Restaurante, Supermercado, Gasolina, PANAPASS, Carro, Valeria, Lala, Gastos Médicos, Gastos generales, Viaje
- **FR-009**: System MUST allow users to create, rename, hide, and reorder categories
- **FR-010**: System MUST support recurring transactions that auto-generate on a quincenal or monthly basis
- **FR-011**: System MUST group transactions into quincenas (1-15 and 16-end of month) for reporting views
- **FR-012**: System MUST display a dashboard with current saldo, monthly ingresos, monthly gastos, and utilidad neta
- **FR-013**: System MUST display a bar chart of expenses by category for the current month
- **FR-014**: System MUST display a line chart of monthly saldo for the past 12+ months
- **FR-015**: System MUST allow setting budgets for variable expense categories with alert thresholds
- **FR-016**: System MUST send a local notification when spending reaches 80% of a category's budget for the current quincena
- **FR-017**: System MUST send a local notification when spending exceeds 100% of a category's budget
- **FR-018**: System MUST require PIN (4-6 digits) or biometric authentication to access the app
- **FR-019**: System MUST lock the app for 30 seconds after 3 failed PIN attempts
- **FR-020**: System MUST export all data to an `.xlsx` file with a structure similar to the original Excel
- **FR-021**: System MUST suggest budget amounts for variable categories based on historical average spending
- **FR-022**: System MUST send a daily registration reminder at a user-configured time
- **FR-023**: System MUST use decimal arithmetic for all financial calculations (no floating-point)
- **FR-024**: System MUST be fully functional offline with no network dependency
- **FR-025**: System MUST use dark mode as the default and only theme
- **FR-026**: System MUST display all amounts in USD/PAB with 2 decimal places
- **FR-027**: Import MUST be idempotent — re-importing the same data does not create duplicate transactions

### Key Entities *(include if feature involves data)*

- **Transaction**: A single financial movement. Attributes: id, date (DateTime), amount (decimal), type (income/expense), categoryId, description (optional), isRecurring (bool), recurringRuleId (optional). Relationships: belongs to one Category.
- **Category**: A classification for transactions. Attributes: id, name, type (income/expense), isVariable (bool, for budget eligibility), isRecurring (bool), isActive (bool), order (int), icon (optional). Relationships: has many Transactions, has optional Budget.
- **RecurringRule**: A rule for auto-generating transactions. Attributes: id, categoryId, amount (decimal), frequency (quincenal/monthly), activationDay (int), isActive (bool), startDate, endDate (optional). Relationships: belongs to one Category, generates many Transactions.
- **Budget**: A spending limit for a category. Attributes: id, categoryId, amountPerQuincena (decimal), alertThreshold (int, percentage, default 80), isActive (bool). Relationships: belongs to one Category.
- **AppSettings**: App configuration. Attributes: pinHash (string), biometricEnabled (bool), reminderEnabled (bool), reminderTime (TimeOfDay), defaultCurrency (string, "USD"). Singleton entity.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: A user can register a transaction in under 10 seconds from app launch (unlock → "+" → amount → category → save)
- **SC-002**: Importing the full Excel file (3 sheets, 2+ years of data) completes in under 30 seconds
- **SC-003**: The dashboard loads and displays saldo + utilidad in under 1 second from data cached locally
- **SC-004**: All financial calculations are accurate to the cent (no floating-point rounding errors) — verified against the Excel's own totals
- **SC-005**: The app functions 100% offline — no network call is made during any core operation
- **SC-006**: Recurring transactions auto-generate within 1 minute of their scheduled activation time
- **SC-007**: Budget alerts fire within the same quincena that the threshold is crossed
- **SC-008**: Exported `.xlsx` file opens correctly in Microsoft Excel and Google Sheets with all data intact

## Assumptions

- The user has a Flutter-capable device (Android or iOS) with biometric sensor (optional, PIN is fallback)
- The Excel file structure follows the established pattern: sheets named Y24/Y25/Y26, rows for categories, columns for quincenas with 1-15 and 15-30 sub-periods
- All financial data is in USD/PAB (1:1 peg); no multi-currency support needed for v1
- The user is the sole user of the app — no multi-user or sharing functionality required
- The user's historical Excel data is accurate and complete for the imported period
- Recurring expense amounts are stable within a reasonable period (user manually adjusts when they change)
- The app will be used on a single device; no cross-device sync in v1
- Local notifications are supported on the target device (standard on iOS 10+ and Android 8+)
