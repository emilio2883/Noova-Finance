# Fase 5 — Arquitectura de errores + plan Riverpod v3

## Hecho en esta fase
- `lib/core/result.dart`: `Result<T,E>` sealed (`Ok`/`Err`) + `runCatching`. Sin dependencias externas.
- Estados UI reutilizables: `EmptyState`, `ErrorState` (con Reintentar), `LoadingState`.
- Dashboard usa `LoadingState`/`ErrorState` (ya no `Text('Error: $e')`).
- Metas de ahorro usan `LoadingState`/`ErrorState`/`EmptyState`.

## Gestor de estado
- Se mantiene **Riverpod 2.6** (no se cambia de gestor en esta iteración).

## Plan de migración a Riverpod v3 (documentado, no ejecutado)
1. Cambios mecánicos: `StateNotifier` → `Notifier`/`AsyncNotifier`; `ref.watch` igual; `autoDispose` pasa a `.autoDispose` modifiers o `NotifierProvider.autoDispose`.
2. Migrar `themeModeProvider` (StateNotifier) a `Notifier<ThemeMode>`.
3. Migrar repos `FutureProvider` a `AsyncNotifier`/`Provider` según necesidad (los repos son inmutables, pueden quedar como Provider async).
4. Ejecutar por feature con analyze+tests como gate; nunca big-bang. Actualizar `flutter_riverpod` a 3.x y `riverpod_annotation` si se usa codegen.

## Result en repos (adopción incremental)
- Nuevos repos (p.ej. SavingsGoal) pueden exponer `Future<Result<T,String>>` para errores explícitos.
- Repos existentes se migran por feature, envolviendo llamadas de escritura con `runCatching`.
