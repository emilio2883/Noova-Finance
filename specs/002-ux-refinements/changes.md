# Cambios v2 — Refinamientos UX (branch 002-ux-refinements)

Surgidos tras usar la app. Jerarquía de categorías basada **solo en la hoja Y26**
de Estado Financiero-2.xlsx. Decisiones de diseño confirmadas por el usuario:
dashboard agrupado por principales con drill-down (1A), jerarquía de 2 niveles
totalmente editable (2A), presupuestos en subcategorías variables con totales
globales (3A).

## Jerarquía Y26 sembrada

```
INGRESOS:  Salario · Otros Ingresos
GASTOS (6 principales):
  Impuestos y Prestamos → Impuesto Sobre la Renta · Seguro Social · Seguro Educativo
  Casa → Gas · IDAAN · Mantenimiento de Casa · Casa - Augusta/GG · QLU MBA - IFARHU · Mantenimiento casa de playa
  Seguro → Progreso · MAFRE - CASA · PALIG - Salud · MAFRE - CARRO · Seguro médico padres
  Alimentos → Restaurante · Supermercado
  Carro → Gasolina · PANAPASS
  Otros → Valeria · Lala · Viaje (All in one) · Gastos Medicos · Gastos generales
```
Total: 6 principales + 25 hojas = 31 categorías.

## Los 7 cambios

1. **Categorías jerárquicas** — modelo `Category.parentId` + `isGroup`; árbol en
   UI con crear/renombrar/mover entre principales/ocultar/eliminar. El import
   asigna cada hoja del Excel a su principal.
2. **Editar/borrar datos** — pantalla de detalle/edición de transacción
   (pantalla completa, scrollable, con eliminar). Saldo inicial importado como
   transacción para que el histórico cuadre. "Borrar todos los datos" en Ajustes.
3. **Transacciones recientes → vista Quincena** — lista con filtro por categoría,
   navegación de quincenas y botón "+" para agregar.
4. **Inicio = dashboard dinámico** — saldo, resumen mensual, presupuesto global,
   y dashboards por categoría. Se recalcula al cambiar datos.
5. **Exportar al dispositivo** — escribe .xlsx en el almacenamiento del teléfono,
   permite Abrir (Excel vía OpenFilex) o Compartir (share_plus).
6. **Modo claro/oscuro** — switch en Ajustes, persistido en AppSettings.themeMode.
7. **Dashboard por categoría** — barras ordenadas dinámicamente por gasto,
   monto de cada categoría, presupuesto por subcategoría reflejado, total global;
   tocar despliega opciones; deslizar ↓ = agregar gasto, ↑ = editar presupuesto.

## Datos técnicos

- Modelo: `Category.parentId` (int?), `Category.isGroup` (bool); `AppSettings.themeMode`.
- Importer: saldo inicial como transacción oculta (categoría "Saldo Inicial"),
  idempotente por hash `OPENING|initial`.
- Persistencia: Isar (offline-first), montos como int en diezmilésimas.
- Tests: 51 pasando; analyze limpio.


## v2.1 — Corrección de importación y taxonomía real (archivo TEST)

Tras probar con "NOOVA Estado Financiero - TEST.xlsx":

- **Bug raíz resuelto**: el paquete `excel` no evalúa fórmulas y lee números como
  fechas → importaba 0 filas. Nuevo `XlsxReader` lee los valores cacheados `<v>`
  directamente del XML del .xlsx. Verificado: 345 transacciones importadas,
  saldo inicial 107652.2599 (exacto), 0 filas no reconocidas.
- **Taxonomía según pestaña "Categorias"**: 8 principales (Ingresos, Impuestos,
  Casa, Seguro, Alimentos, Carro, Otros, Prestamos) + 26 hojas.
  Mapeo fila→categoría: IDAAN→Agua IDAAN, Mantenimiento de Casa→Mantenimiento
  Augusta, Mantenimiento casa de playa→Mantenimiento Lajas, Casa - Augusta/GG→
  Hipoteca Augusta (Prestamos), QLU MBA-IFARHU→Prestamos.
- **Importación multi-archivo**: hash por archivo (`archivo|hoja|fila|col`),
  historial de importaciones (ImportRecord), botón "Volver a Ajustes".
- **Presupuestos**: cubren todas las subcategorías (no solo variables), así que
  Casa/Seguro/Impuestos muestran las suyas.
- **Navegación**: sub-pantallas con `push` para que el botón regreso funcione.
