import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:noova_finance/app.dart';

void main() {
  testWidgets('App builds and shows dashboard', (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: NoovaApp()));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    // Dashboard app bar renders (brand header; data loads async).
    expect(find.byType(AppBar), findsOneWidget);
  });
}
