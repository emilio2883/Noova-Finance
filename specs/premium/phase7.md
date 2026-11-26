# Fase 7 — Evaluación de UI kit + adopción de patrones

## Kits evaluados (patrones, no dependencia)
| Kit | Patrón clave | ¿Adoptado? | Cómo en Noova |
|---|---|---|---|
| Aether Finance | Hero card con gradiente navy, tipografía grande | Sí (patrón) | `SaldoCard` hero navy, cifras tabulares |
| Finova | CTAs tipo pill, chips de categoría con color | Sí (patrón) | FilledButtons, chips de categoría |
| Pockora | Bar/ring charts, listas con progreso | Sí (patrón) | `AnimatedProgressBar`, Metas con progreso |
| Monzo | Pots, feed, estados vacíos conversacionales | Sí (patrón) | Metas (=Pots), `EmptyState` |
| Revolut | Insights por periodo, toggle de periodo | Sí (patrón) | `buildInsights`, selector de mes en Gráficos |

## Decisión
- **No se añade un UI kit como dependencia** (licencias, peso, choque con Material 3 y nuestro sistema de tokens). En su lugar, los patrones se implementan con nuestros tokens (`context.app`), manteniendo una sola fuente de verdad de diseño.
- Mapeo de tokens: colores → `AppColors`; espaciados → `AppSpacing`; radios → `AppRadii`; sombras → `AppShadows`; motion → `AppMotion`; tipografía → `AppTypography`.

## Pendiente (opcional)
- Explorar un `ThemeExtension` de iconografía propia si se desea un set de íconos 100% de marca.
