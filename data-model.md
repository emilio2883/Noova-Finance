# Data Model: Noova Finance MVP

**Branch**: `001-noova-finance-mvp` | **Date**: 2026-11-17

## Entity Definitions (Isar Collections)

### Transaction

```dart
@collection
class Transaction {
  Id id = Isar.autoIncrement;

  @Index() // for date-range queries
  DateTime date;

  Decimal amount;          // positive = income, negative = expense
  TransactionType type;    // income | expense
  int categoryId;          // FK -> Category.id
  String? description;

  bool isRecurring;
  int? recurringRuleId;    // FK -> RecurringRule.id (null if manual)

  @Index() // for import deduplication
  String? importHash;       // hash of (date + amount + category + sheet)

  DateTime createdAt;
  DateTime? updatedAt;
}

enum TransactionType { income, expense }
```

**Indexes**: `date` (range queries for saldo, quincena, month), `importHash` (idempotent import), `categoryId` (category aggregation)

### Category

```dart
@collection
class Category {
  Id id = Isar.autoIncrement;

  String name;
  TransactionType type;     // income | expense
  bool isVariable;          // true = eligible for budgets
  bool isRecurring;         // true = has associated RecurringRule
  bool isActive;            // false = hidden from selector
  int order;                // display order
  String? icon;             // optional icon identifier

  @Index()
  String? importKey;        // original Excel row name for mapping
}
```

**Indexes**: `importKey` (Excel mapping during import), `type` (filter income/expense)

### RecurringRule

```dart
@collection
class RecurringRule {
  Id id = Isar.autoIncrement;

  int categoryId;           // FK -> Category.id
  Decimal amount;
  RecurringFrequency frequency;  // quincenal | monthly
  int activationDay;        // day of month (1-31) or quincena (1 or 16)
  bool isActive;

  DateTime startDate;
  DateTime? endDate;        // null = indefinite

  DateTime lastGenerated;   // last auto-generation date
}

enum RecurringFrequency { quincenal, monthly }
```

### Budget

```dart
@collection
class Budget {
  Id id = Isar.autoIncrement;

  int categoryId;           // FK -> Category.id (variable categories only)
  Decimal amountPerQuincena;
  int alertThreshold;       // percentage (default: 80)
  bool isActive;

  DateTime createdAt;
  DateTime? updatedAt;
}
```

### AppSettings

```dart
@collection
class AppSettings {
  Id id = 0; // singleton

  String? pinHash;          // bcrypt/hash of PIN
  bool biometricEnabled;
  bool reminderEnabled;
  int reminderHour;         // 0-23
  int reminderMinute;       // 0-59
  String defaultCurrency;   // "USD"

  bool isImported;          // has historical data been imported
  DateTime? lastExportDate;
}
```

## Default Categories (pre-loaded from Excel)

### Income Categories
| Name | isVariable | isRecurring |
|------|-----------|-------------|
| Salario | false | true |
| Otros Ingresos | true | false |

### Fixed Expense Categories (recurring)
| Name | isVariable | isRecurring | Approx. Amount |
|------|-----------|-------------|----------------|
| Casa Augusta/GG | false | true | $3,280/q |
| Casa de playa | false | true | $70/q |
| Gas | false | true | variable |
| IDAAN | false | true | $17.90/q |
| Mantenimiento de Casa | false | true | $60/q |
| QLU MBA - IFARHU | false | true | $178/q |
| Progreso | false | true | $150/q |
| MAFRE Casa | false | true | $55/q |
| MAFRE Carro | false | true | variable |
| PALIG Salud | false | true | $171/q |
| Seguro médico padres | false | true | variable |
| Impuesto Sobre la Renta | false | true | variable |
| Seguro Social | false | true | variable |
| Seguro Educativo | false | true | variable |

### Variable Expense Categories
| Name | isVariable | isRecurring |
|------|-----------|-------------|
| Restaurante | true | false |
| Supermercado | true | false |
| Gasolina | true | false |
| PANAPASS | true | false |
| Carro | true | false |
| Valeria | true | false |
| Lala | true | false |
| Gastos Médicos | true | false |
| Gastos generales | true | false |
| Viaje | true | false |

## Derived Calculations (not stored, computed at query time)

### Saldo (current balance)
```
saldo = Σ(all transactions where date <= today).amount
```

### Utilidad Neta (for a period)
```
ingresos = Σ(transactions where type=income AND date in period).amount
gastos = |Σ(transactions where type=expense AND date in period).amount|
utilidadNeta = ingresos - gastos
```

### Quincena (derived from date)
```
quincenaNumber = (day <= 15) ? 1 : 2
quincenaLabel = "${month} ${quincenaNumber == 1 ? '1-15' : '16-end'}"
```

### Budget Status (for a category in current quincena)
```
spent = |Σ(expenses in category for current quincena)|
percentage = (spent / budget.amountPerQuincena) * 100
status = percentage >= 100 ? "exceeded"
       : percentage >= alertThreshold ? "warning"
       : "ok"
```
