import 'package:drift/drift.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pos_warung_ai/infrastructure/database/app_database.dart';

void main() {
  late AppDatabase database;

  setUp(() {
    database = AppDatabase.memory();
  });

  tearDown(() async {
    await database.close();
  });

  test('Products can be created and read', () async {
    // Insert 1 product
    await database.into(database.products).insert(
      ProductsCompanion(
        tenantId: const Value('tenant-1'),
        name: const Value('Indomie Goreng'),
        price: const Value(3500.0),
        stock: const Value(10),
        createdAt: Value(DateTime.now()),
      ),
    );

    // Query all products
    final products = await database.select(database.products).get();

    // Verify
    expect(products.length, 1);
    expect(products.first.name, 'Indomie Goreng');
    expect(products.first.price, 3500.0);
    expect(products.first.stock, 10);
  });
}
