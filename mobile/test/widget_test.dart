
import 'package:flutter_test/flutter_test.dart';

import 'package:pos_warung_ai/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const POSWarungAIApp());

    // Verify that the title text is present.
    expect(find.text('POS Warung AI'), findsWidgets);
    expect(find.text('Offline-First POS untuk Warung Indonesia'), findsOneWidget);
  });
}
