# Noova Premium — Plan de implementación por feature (Fase 2)

Decisiones registradas:
- **Modo default = CLARO** (cuerpo claro + hero navy), oscuro por switch. Se aplica en Fase 3 junto con la migración de tokens.
- Estado: **se mantiene Riverpod** (no se cambia de gestor en esta iteración).
- Charts: **fl_chart** (ya en uso; se actualiza 0.69→1.x).
- Persistencia: **Isar** (ya en uso). Routing: **go_router** (ya en uso).
- Sin dependencias pesadas nuevas: se evita `fpdart`; se crea un `Result<T,E>` propio (Dart 3 sealed).

## Resumen por feature

| # | Feature | Estado | Objetivo de producto | Patrón adoptado + justificación | Paquetes | Complejidad | Riesgo |
|---|---|---|---|---|---|---|---|
| F0 | **Onboarding** | NUEVO | Explicar valor en 2–3 pasos + primera acción (importar o empezar), reducir fricción inicial | Progressive onboarding (Wise/M3): una idea por pantalla, CTA único. Adaptado: sin KYC; nombre/moneda→PIN→"importar/empezar" | — (PageView nativo) | S | Bajo |
| F1 | **Dashboard con insights** | ELEVAR (existe) | Convertir el dashboard en "estado del dinero + qué hacer ahora" | Monzo (hero de balance, cifras tabulares, feed) + Revolut (comparación vs periodo previo, toggle de periodo, insights). Adaptado a jerarquía de categorías Y26 | fl_chart (existente) | M | Medio (lógica de insights) |
| F2 | **Agregar transacción** | ELEVAR (existe) | Registro en <10s, sensación premium | Monzo/Revolut: monto primero, teclado grande, chips de categoría con icono/color, sheet arrastrable | — | S | Bajo |
| F3 | **Metas de ahorro** | NUEVO | Motivar ahorro con progreso visual y aportes | Monzo **Pots** (coin + barra + "£x de £y"), Revolut Pockets. Adaptado: metas ligadas a saldo y a "Prestamos"/Ahorro | fl_chart (anillo) o ring custom | M–L | Medio (modelo nuevo) |
| F4 | **Estados vacíos/error** | NUEVO (transversal) | Nunca dejar pantallas "rotas" ni frías | M3 + Monzo (copy conversacional + CTA). Componentes reutilizables Empty/Error/Loading | — | S | Bajo |

## Detalle: pantallas, widgets y archivos

### F0 — Onboarding
- `lib/features/onboarding/onboarding_screen.dart` → `OnboardingScreen`, `OnboardingStep`
- `lib/features/onboarding/widgets/onboarding_page.dart` → `OnboardingPage` (título, subtítulo, ilustración, CTA, dots)
- Persistencia: flag `onboardingDone` en `AppSettings`
- Premium: transición de página con `PageView` + dots animados; copy corto; primera decisión = importar o manual.

### F1 — Dashboard con insights (elevar el actual)
- Elevar `lib/features/dashboard/dashboard_screen.dart` (`DashboardScreen`)
- Nuevos widgets: `widgets/balance_hero_card.dart` (`BalanceHeroCard`, fondo `hero` navy, número tabular), `widgets/insight_card.dart` (`InsightCard`), `widgets/category_donut_chart.dart` (`CategoryDonutChart` con fl_chart + `RepaintBoundary`), `widgets/period_selector.dart`
- Provider: extender `dashboard_provider.dart` con `Insight` (top categoría, delta vs quincena/mes anterior, alerta de presupuesto), comparación vs periodo previo
- Estados: loading/empty/error vía componentes F4
- Premium: número héroe tabular, verde/rojo semántico, insights accionables ("Restaurante +18% vs quincena pasada"), toggle de periodo.

### F2 — Agregar transacción (elevar)
- Refactor `lib/features/transaction/quick_add_modal.dart` → `quick_add_sheet.dart` (`QuickAddSheet`, `DraggableScrollableSheet`)
- Widgets: `widgets/amount_keypad.dart` (`AmountKeypad`), `shared/widgets/category_chip.dart` (`CategoryChip` con icono/color), segmented gasto/ingreso
- Premium: teclado numérico propio, háptica, chips con color por categoría, validación inline, guardado de un toque.

### F3 — Metas de ahorro (nuevo)
- Modelo: `lib/data/models/savings_goal.dart` (`SavingsGoal`: name, targetBps, savedBps, deadline?, colorIcon, isActive) + `SavingsContribution`
- Repo: `lib/data/repositories/savings_goal_repo.dart`
- Provider: `lib/features/goals/providers/goals_provider.dart`
- Pantallas: `lib/features/goals/goals_screen.dart` (`GoalsScreen`), `lib/features/goals/goal_detail_screen.dart` (`GoalDetailScreen`)
- Widgets: `widgets/goal_ring.dart` (`GoalRing` con fl_chart/gradient), `widgets/goal_card.dart` (`GoalCard`), acción "Aportar"
- Premium: `Hero` lista→detalle, anillo de progreso, estados vacíos ("Crea tu primera meta"), `Result<T,E>` en carga.
- Confirmación de diseño: las metas son un *concepto nuevo* (no ligadas 1:1 a categorías); se conectan visualmente al saldo, no reescriben transacciones.

### F4 — Estados vacíos / error (transversal)
- `lib/shared/ui/empty_state.dart` (`EmptyState`: icono/ilustración + título + subtítulo + CTA)
- `lib/shared/ui/error_state.dart` (`ErrorState`: mensaje humano + botón Reintentar)
- `lib/shared/ui/loading_state.dart` (`LoadingState` skeleton)
- `lib/core/result.dart` (`Result<T,E>` sealed; `Ok`, `Err`)
- Se adopta en TODAS las pantallas migrate/elevadas.

## Diagrama de dependencias

```
[Fase 1 Tokens] ✔
      │
      ├──> [F4 Empty/Error + Result]  (habilitador transversal)
      │         │
      ├──> [F0 Onboarding] ──(flag onboardingDone)
      │
      ├──> [F1 Dashboard insights] ──(usa tokens + dashboard_provider + fl_chart)
      │
      ├──> [F2 Add txn] ──(usa tokens + categorías)
      │
      └──> [F3 Metas] ──(usa Result + modelo nuevo + Hero)
```

## Orden de construcción recomendado
1. **F4 enablers** (Empty/Error/Loading + Result) — baratos y desbloquean el resto.
2. **F0 Onboarding**.
3. **F1 Dashboard con insights** (mayor impacto percibido).
4. **F2 Agregar transacción**.
5. **F3 Metas de ahorro** (feature nueva).
Ajuste vs prompt: adelanto F4 (enablers) antes de F0 porque Onboarding y todos usan esos estados. El resto sigue el orden pedido (onboarding → dashboard → add txn → metas → empty/error).

## Mapeo a las fases del playbook
- Fase 3 (migrar estilos): migrar pantallas existentes a tokens (dashboard actual, quincena, charts, categorías, presupuestos, import, lock, settings) + **activar default claro**.
- Fase 4 (motion): `PageView` onboarding, `Hero` metas, `AnimatedSwitcher` estados, curvas `AppMotion`.
- Fase 5 (arquitectura/errores): `Result<T,E>` en repos críticos; DI ya por Riverpod; plan de Riverpod v3 documentado.
- Fase 6 (código crítico): F1 dashboard insights + F3 metas (con diff previo para aprobación).
- Fase 7 (UI kit): evaluar Aether/Finova/Pockora → recomendar 1 y mapear tokens.
- Fase 8 (a11y + cierre): Semantics, escala 200%, tap ≥48, widget tests, CI (analyze + gate + test), informe antes/después.
