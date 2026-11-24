import 'package:flutter_test/flutter_test.dart';

import 'package:noova_finance/app.dart';

void main() {
  testWidgets('App builds and shows dashboard placeholder', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const NoovaApp());

    // Verify the dashboard placeholder renders.
    expect(find.text('Noova Finance'), findsWidgets);
  });
}
