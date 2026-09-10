import 'package:flutter_test/flutter_test.dart';
import 'package:pos_warung_ai/domain/inventory/entities/product.dart';
import 'package:pos_warung_ai/infrastructure/database/app_database.dart' hide Product;
import 'package:pos_warung_ai/infrastructure/repositories/drift_product_repository.dart';

void main() {
  late AppDatabase database;
  late DriftProductRepository repository;

  setUp(() {
    database = AppDatabase.memory();
    repository = DriftProductRepository(database);
  });

  tearDown(() async {
    await database.close();
  });

  final testProduct = Product(
    tenantId: 'tenant-1',
    name: 'Indomie Goreng',
    price: 3500.0,
    stock: 10,
    category: 'Makanan',
    createdAt: DateTime.now(), // Akan di-override di repository
  );

  test('create product -> getById returns product dengan field sesuai', () async {
    final id = await repository.create(testProduct);
    final product = await repository.getById(id);

    expect(product, isNotNull);
    expect(product!.id, id);
    expect(product.name, 'Indomie Goreng');
    expect(product.price, 3500.0);
    expect(product.stock, 10);
    expect(product.isDeleted, false);
  });

  test('getAll returns list, empty jika belum ada', () async {
    final initialList = await repository.getAll();
    expect(initialList, isEmpty);

    await repository.create(testProduct);
    final list = await repository.getAll();
    expect(list.length, 1);
  });

  test('update product -> getById reflects perubahan', () async {
    final id = await repository.create(testProduct);
    final product = await repository.getById(id);

    final updatedProduct = product!.copyWith(
      price: 4000.0,
      stock: 5,
    );

    final success = await repository.update(updatedProduct);
    expect(success, isTrue);

    final result = await repository.getById(id);
    expect(result!.price, 4000.0);
    expect(result.stock, 5);
  });

  test('delete product -> getAll tidak include product itu (soft delete)', () async {
    final id = await repository.create(testProduct);
    final listBefore = await repository.getAll();
    expect(listBefore.length, 1);

    final success = await repository.delete(id);
    expect(success, isTrue);

    final listAfter = await repository.getAll();
    expect(listAfter, isEmpty);
    
    final getByIdResult = await repository.getById(id);
    expect(getByIdResult, isNull);
  });

  test('watchAll stream emits list', () async {
    final stream = repository.watchAll();
    
    final expectation = expectLater(
      stream,
      emitsInOrder([
        [],
        isA<List<Product>>().having((list) => list.length, 'length', 1),
      ]),
    );

    await Future.delayed(Duration.zero);
    await repository.create(testProduct);
    
    await expectation;
  });
}
