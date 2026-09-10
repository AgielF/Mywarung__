
import 'package:flutter_test/flutter_test.dart';

import 'package:pos_warung_ai/main.dart';
import 'package:pos_warung_ai/infrastructure/database/app_database.dart';
import 'package:pos_warung_ai/infrastructure/repositories/drift_product_repository.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    final database = AppDatabase.memory();
    final repository = DriftProductRepository(database);

    // Build our app and trigger a frame.
    await tester.pumpWidget(POSWarungAIApp(productRepository: repository));

    // Verify that the title text is present.
    expect(find.text('POS Warung AI'), findsWidgets);
    expect(find.text('Offline-First POS untuk Warung Indonesia'), findsOneWidget);

    await database.close();
  });
}
