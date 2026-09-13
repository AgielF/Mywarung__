import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pos_warung_ai/domain/inventory/entities/product.dart';
import 'package:pos_warung_ai/domain/inventory/repositories/product_repository.dart';
import 'package:pos_warung_ai/ui/inventory/inventory_list_screen.dart';

class FakeProductRepository implements ProductRepository {
  final List<Product> _products = [];
  final _controller = StreamController<List<Product>>.broadcast();
  int _idCounter = 1;

  @override
  Future<int> create(Product product) async {
    final newProduct = product.copyWith(id: _idCounter++);
    _products.add(newProduct);
    _controller.add(List.from(_products));
    return newProduct.id!;
  }

  @override
  Future<bool> delete(int id) async {
    _products.removeWhere((p) => p.id == id);
    _controller.add(List.from(_products));
    return true;
  }

  @override
  Future<List<Product>> getAll() async {
    return List.from(_products);
  }

  @override
  Future<Product?> getById(int id) async {
    try {
      return _products.firstWhere((p) => p.id == id);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<bool> update(Product product) async {
    final index = _products.indexWhere((p) => p.id == product.id);
    if (index != -1) {
      _products[index] = product;
      _controller.add(List.from(_products));
      return true;
    }
    return false;
  }

  @override
  Stream<List<Product>> watchAll() async* {
    yield List.from(_products);
    yield* _controller.stream;
  }

  void dispose() {
    _controller.close();
  }
}

void main() {
  late FakeProductRepository repository;

  setUp(() {
    repository = FakeProductRepository();
  });

  tearDown(() {
    repository.dispose();
  });

  Widget createWidgetUnderTest() {
    return MaterialApp(home: InventoryListScreen(repository: repository));
  }

  testWidgets('renders "Belum ada produk" when empty', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pump();

    expect(find.text('Belum ada produk'), findsOneWidget);
    expect(find.byIcon(Icons.inventory_2), findsOneWidget);
  });

  testWidgets('renders product name after insert', (WidgetTester tester) async {
    await repository.create(
      Product(
        tenantId: 'tenant-1',
        name: 'Kopi Kapal Api',
        price: 1500,
        stock: 20,
        createdAt: DateTime.now(),
      ),
    );

    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pump();

    expect(find.text('Kopi Kapal Api'), findsOneWidget);
    expect(find.text('Stok: 20'), findsOneWidget);
    expect(find.text(' | Rp 1500'), findsOneWidget);
  });

  testWidgets('Filter "Stok Menipis" hanya tampilkan low stock', (
    WidgetTester tester,
  ) async {
    await repository.create(
      Product(
        tenantId: 't1',
        name: 'Low Stock Item',
        price: 1000,
        stock: 3,
        createdAt: DateTime.now(),
      ),
    );
    await repository.create(
      Product(
        tenantId: 't1',
        name: 'High Stock Item',
        price: 1000,
        stock: 20,
        createdAt: DateTime.now(),
      ),
    );

    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pumpAndSettle();

    expect(find.text('Low Stock Item'), findsOneWidget);
    expect(find.text('High Stock Item'), findsOneWidget);

    await tester.tap(find.text('Stok Menipis'));
    await tester.pumpAndSettle();

    expect(find.text('Low Stock Item'), findsOneWidget);
    expect(find.text('High Stock Item'), findsNothing);
  });

  testWidgets('Badge stok muncul untuk produk stock=3', (
    WidgetTester tester,
  ) async {
    await repository.create(
      Product(
        tenantId: 't1',
        name: 'Low Stock Item',
        price: 1000,
        stock: 3,
        createdAt: DateTime.now(),
      ),
    );

    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pumpAndSettle();

    final textWidget = tester.widget<Text>(find.text('Stok: 3'));
    expect(textWidget.style?.color, Colors.red);
  });

  testWidgets('Badge tidak muncul untuk produk stock=20', (
    WidgetTester tester,
  ) async {
    await repository.create(
      Product(
        tenantId: 't1',
        name: 'High Stock Item',
        price: 1000,
        stock: 20,
        createdAt: DateTime.now(),
      ),
    );

    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pumpAndSettle();

    final textWidget = tester.widget<Text>(find.text('Stok: 20'));
    expect(textWidget.style?.color, null);
  });
}
