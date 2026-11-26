# Fase 8 — Accesibilidad (a11y) y cierre

## Antes vs después
| Área | Antes (auditoría) | Después (esta iteración) |
|---|---|---|
| Semántica de navegación | `Semantics(` = 0 | `Semantics(button,label,selected)` en barra inferior (Quincena/Gráficos/Inicio/Ajustes) |
| Botones solo-ícono | Sin tooltip | Tooltips/Semantics: Metas (tooltip), Inicio (Semantics), botones de nav (Semantics) |
| Tap targets | Mezcla | IconButton = 48dp; ítems de nav 66dp de alto; botón central 52dp |
| Escala de texto | fontSize fijo (46) | Flutter aplica `MediaQuery.textScaler` por defecto: el texto escala con el sistema; se evita desbordamiento con `FittedBox` en cifras |
| Contraste (claro) | Texto secundario/mint lavados | Migrado a `context.app`; `textSecondary`/`income` responden al tema |

## Verificación
- `flutter analyze` limpio, `check_raw_values` verde, tests en verde (gate CI).
- Revisión manual recomendada en dispositivo: activar tamaño de fuente grande (Ajustes Android) y verificar dashboard/gráficos.

## Cierre del refactor premium
- Tokens (Fase 1), plan (2), migración (3), motion (4), errores/Result (5), insights+metas (6), UI kit (7), a11y (8).
- Gate automatizado activo: analyze + `tool/check_raw_values.dart` + tests.
