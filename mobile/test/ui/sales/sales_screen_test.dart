import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pos_warung_ai/domain/inventory/entities/product.dart';
import 'package:pos_warung_ai/domain/inventory/repositories/product_repository.dart';
import 'package:pos_warung_ai/domain/sales/entities/transaction.dart' as domain;
import 'package:pos_warung_ai/domain/sales/repositories/transaction_repository.dart';
import 'package:pos_warung_ai/ui/sales/sales_screen.dart';

class FakeProductRepository implements ProductRepository {
  final List<Product> _products = [
    Product(id: 1, tenantId: 'tenant-1', name: 'Indomie', price: 3000, stock: 10, createdAt: DateTime.now()),
  ];
  
  @override Future<int> create(Product product) async => 1;
  @override Future<bool> delete(int id) async => true;
  @override Future<List<Product>> getAll() async => _products;
  @override Future<Product?> getById(int id) async => _products.first;
  @override Future<bool> update(Product product) async => true;
  @override Stream<List<Product>> watchAll() async* {
    yield _products;
  }
}

class FakeTransactionRepository implements TransactionRepository {
  List<domain.Transaction> created = [];

  @override Future<int> create(domain.Transaction transaction) async {
    created.add(transaction);
    return 1;
  }
  @override Future<domain.Transaction?> getById(int id) async => null;
  @override Future<List<domain.Transaction>> getAll({DateTime? from, DateTime? to}) async => [];
  @override Stream<List<domain.Transaction>> watchAll({DateTime? from, DateTime? to}) async* { yield []; }
}

void main() {
  late FakeProductRepository productRepo;
  late FakeTransactionRepository transactionRepo;

  setUp(() {
    productRepo = FakeProductRepository();
    transactionRepo = FakeTransactionRepository();
  });

  Widget createWidget() {
    return MaterialApp(
      home: SalesScreen(
        productRepository: productRepo,
        transactionRepository: transactionRepo,
      ),
    );
  }

  testWidgets('menampilkan daftar produk', (tester) async {
    await tester.pumpWidget(createWidget());
    await tester.pump();

    expect(find.text('Indomie'), findsOneWidget);
    expect(find.text('Rp 3000'), findsOneWidget);
    
    await tester.pumpWidget(Container());
  });

  testWidgets('tap produk -> tambah ke cart & total terupdate', (tester) async {
    await tester.pumpWidget(createWidget());
    await tester.pump();

    await tester.tap(find.text('Indomie'));
    await tester.pump();

    expect(find.text('Rp 3000'), findsWidgets); // Rp 3000 product + Rp 3000 in bottom bar

    await tester.tap(find.byIcon(Icons.shopping_cart));
    await tester.pumpAndSettle();

    expect(find.text('Rp 3000.0 x 1 = Rp 3000.0'), findsOneWidget);
    
    await tester.pumpWidget(Container());
  });
}
