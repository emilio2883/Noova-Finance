import 'package:flutter_test/flutter_test.dart';

import 'package:noova_finance/app.dart';

/// End-to-end smoke test: app builds, dashboard renders, navigation works.
/// Full flows (import -> register -> verify) run on device per quickstart.md.
void main() {
  testWidgets('App boots to dashboard with bottom navigation', (tester) async {
    await tester.pumpWidget(const NoovaApp());
    await tester.pumpAndSettle();

    // Dashboard renders with its app bar and nav bar
    expect(find.text('Noova Finance'), findsOneWidget);
    expect(find.text('Inicio'), findsOneWidget);
    expect(find.text('Quincena'), findsOneWidget);
    expect(find.text('Graficos'), findsOneWidget);
    expect(find.text('Ajustes'), findsOneWidget);
  });

  testWidgets('Navigate to Ajustes via bottom nav', (tester) async {
    await tester.pumpWidget(const NoovaApp());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Ajustes'));
    await tester.pumpAndSettle();

    expect(find.text('Importar Excel'), findsOneWidget);
    expect(find.text('Categorias'), findsOneWidget);
    expect(find.text('Presupuestos'), findsOneWidget);
  });
}
