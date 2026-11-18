# Noova Finance Constitution

## Core Principles

### I. Offline-First
All financial data is stored locally on the device (SQLite/Isar). No cloud dependency, no network requirement for core functionality. The app must function fully offline. Sync/backup may be added later but is not a v1 concern.

### II. Privacy by Design
Financial data never leaves the device without explicit user action (e.g., manual export). No analytics, no telemetry, no third-party data sharing. The app is a personal tool, not a platform.

### III. Test-First (NON-NEGOTIABLE)
TDD mandatory for all business logic: models, calculations, import/export, recurring generation. UI widgets tested with widget tests. Red-Green-Refactor cycle strictly enforced. No production code without a failing test first.

### IV. Simplicity & YAGNI
Start with the minimum viable feature set. No speculative features, no future-proofing abstractions. Every feature traces to a concrete user story from the spec. Max 3 screens of complexity per iteration.

### V. Data Integrity
Financial calculations use decimal arithmetic, never floating-point. Balances must always reconcile: Saldo Inicial + Ingresos - Gastos = Saldo Final. Import must be idempotent (re-importing the same data does not create duplicates).

### VI. User Experience Consistency
Dark mode is the default and only theme for v1. Consistent navigation patterns. Registration of a transaction takes max 3 taps from home screen. All amounts displayed in USD/PAB with 2 decimal places.

## Technology Stack

- **Framework**: Flutter (Dart)
- **Local Storage**: Isar or Drift (SQLite)
- **State Management**: Riverpod or Provider
- **Charts**: fl_chart
- **Excel I/O**: syncfusion_flutter_xlsio (export), excel package (import)
- **Biometrics**: local_auth
- **Notifications**: flutter_local_notifications
- **Testing**: flutter_test, integration_test

## Development Workflow

- Spec-driven: all features begin with a spec in `specs/` before any code
- Feature branches: each feature gets its own branch `###-feature-name`
- Code review: every commit must pass `flutter analyze` and `flutter test`
- Commits are atomic and reference the task number from `tasks.md`

## Governance

The constitution supersedes all other practices. Amendments require documentation, user approval, and a migration plan. Any violation of principles must be documented with a justified exception in the plan's Complexity Tracking table.

**Version**: 1.0.0 | **Ratified**: 2026-11-17 | **Last Amended**: 2026-11-17
