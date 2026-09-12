import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pos_warung_ai/domain/inventory/entities/product.dart';
import 'package:pos_warung_ai/domain/inventory/repositories/product_repository.dart';
import 'package:pos_warung_ai/domain/sales/entities/transaction.dart' as domain;
import 'package:pos_warung_ai/domain/sales/repositories/transaction_repository.dart';
import 'package:pos_warung_ai/domain/customer/entities/customer.dart';
import 'package:pos_warung_ai/domain/customer/entities/debt.dart';
import 'package:pos_warung_ai/domain/customer/repositories/customer_repository.dart';
import 'package:pos_warung_ai/domain/customer/repositories/debt_repository.dart';
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

class FakeCustomerRepository implements CustomerRepository {
  bool isEmpty = false;
  final List<Customer> _customers = [
    Customer(id: 1, tenantId: 'tenant-1', name: 'Budi Kasbon', createdAt: DateTime.now())
  ];
  @override Stream<List<Customer>> watchAll({String tenantId = 'tenant-1'}) async* { 
    if (isEmpty) {
      yield [];
    } else {
      yield _customers; 
    }
  }
  @override Future<Customer?> getById(int id, {String tenantId = 'tenant-1'}) async => null;
  @override Future<List<Customer>> getAll({String tenantId = 'tenant-1'}) async => [];
  @override Future<int> create({required String name, String? phone, String tenantId = 'tenant-1'}) async => 1;
  @override Future<void> update(Customer customer, {String tenantId = 'tenant-1'}) async {}
  @override Future<void> delete(int id, {String tenantId = 'tenant-1'}) async {}
}

class FakeDebtRepository implements DebtRepository {
  bool createDebtCalled = false;
  double? createdAmount;
  int? createdCustomerId;

  @override Stream<List<Debt>> watchAll({String tenantId = 'tenant-1'}) async* {}
  @override Stream<List<Debt>> watchByCustomer(int customerId, {String tenantId = 'tenant-1'}) async* {}
  @override Future<List<Debt>> getUnpaidByCustomer(int customerId, {String tenantId = 'tenant-1'}) async => [];
  @override Future<int> createDebt({required int customerId, required double amount, String tenantId = 'tenant-1'}) async {
    createDebtCalled = true;
    createdAmount = amount;
    createdCustomerId = customerId;
    return 1;
  }
  @override Future<void> payDebt({required int debtId, required double payment, String tenantId = 'tenant-1'}) async {}
  @override Future<void> delete(int id, {String tenantId = 'tenant-1'}) async {}
}

void main() {
  late FakeProductRepository productRepo;
  late FakeTransactionRepository transactionRepo;
  late FakeCustomerRepository customerRepo;
  late FakeDebtRepository debtRepo;

  setUp(() {
    productRepo = FakeProductRepository();
    transactionRepo = FakeTransactionRepository();
    customerRepo = FakeCustomerRepository();
    debtRepo = FakeDebtRepository();
  });

  Widget createWidget() {
    return MaterialApp(
      home: Scaffold(
        body: SalesScreen(
          productRepository: productRepo,
          transactionRepository: transactionRepo,
          customerRepository: customerRepo,
          debtRepository: debtRepo,
        ),
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

    await tester.tap(find.widgetWithText(ElevatedButton, 'Tambah'));
    await tester.pump();

    expect(find.text('Rp 3000'), findsWidgets); // Rp 3000 product + Rp 3000 in bottom bar

    await tester.tap(find.byIcon(Icons.shopping_cart));
    await tester.pumpAndSettle();

    expect(find.text('Rp 3000.0 x 1 = Rp 3000.0'), findsOneWidget);
    
    await tester.pumpWidget(Container());
  });

  testWidgets('pilih Kasbon -> dialog pilih customer tampil', (tester) async {
    await tester.pumpWidget(createWidget());
    await tester.pump();
    await tester.tap(find.widgetWithText(ElevatedButton, 'Tambah'));
    await tester.pump();
    await tester.tap(find.byIcon(Icons.shopping_cart));
    await tester.pumpAndSettle();
    
    await tester.tap(find.text('Bayar').last);
    await tester.pumpAndSettle();
    
    await tester.tap(find.text('Kasbon'));
    await tester.pumpAndSettle();

    expect(find.text('Pilih Customer'), findsOneWidget);
    expect(find.text('Budi Kasbon'), findsOneWidget);
    
    await tester.pumpWidget(Container());
  });

  testWidgets('pilih Kasbon + pilih customer -> debtRepository.createDebt dipanggil', (tester) async {
    await tester.pumpWidget(createWidget());
    await tester.pump();
    await tester.tap(find.widgetWithText(ElevatedButton, 'Tambah'));
    await tester.pump();
    await tester.tap(find.byIcon(Icons.shopping_cart));
    await tester.pumpAndSettle();
    
    await tester.tap(find.text('Bayar').last);
    await tester.pumpAndSettle();
    
    await tester.tap(find.text('Kasbon'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Budi Kasbon'));
    await tester.pumpAndSettle();

    expect(debtRepo.createDebtCalled, isTrue);
    expect(debtRepo.createdAmount, 3000.0);
    expect(debtRepo.createdCustomerId, 1);
    
    await tester.pumpWidget(Container());
  });

  testWidgets('pilih Kasbon, dialog kosong, tap "Tambah Customer" -> CustomerFormScreen muncul', (tester) async {
    customerRepo.isEmpty = true;
    
    await tester.pumpWidget(createWidget());
    await tester.pump();
    await tester.tap(find.widgetWithText(ElevatedButton, 'Tambah'));
    await tester.pump();
    await tester.tap(find.byIcon(Icons.shopping_cart));
    await tester.pumpAndSettle();
    
    await tester.tap(find.text('Bayar').last);
    await tester.pumpAndSettle();
    
    await tester.tap(find.text('Kasbon'));
    await tester.pumpAndSettle();

    expect(find.text('Belum ada customer'), findsOneWidget);
    
    await tester.tap(find.text('Tambah Customer'));
    await tester.pumpAndSettle();
    
    expect(find.widgetWithText(AppBar, 'Tambah Customer'), findsOneWidget); // title of CustomerFormScreen
    
    await tester.pumpWidget(Container());
  });

  testWidgets('SalesScreen shows Tambah button when qty=0', (tester) async {
    await tester.pumpWidget(createWidget());
    await tester.pump();

    // Verifikasi tombol Tambah muncul saat awal (qty=0)
    expect(find.widgetWithText(ElevatedButton, 'Tambah'), findsOneWidget);
    
    await tester.pumpWidget(Container());
  });

  testWidgets('SalesScreen shows [− qty +] when qty>0, + disabled at stock limit', (tester) async {
    await tester.pumpWidget(createWidget());
    await tester.pump();

    // Tap Tambah 1x (masuk cart)
    await tester.tap(find.widgetWithText(ElevatedButton, 'Tambah'));
    await tester.pump();

    // Verifikasi tombol Tambah hilang, digantikan oleh row qty controls
    expect(find.widgetWithText(ElevatedButton, 'Tambah'), findsNothing);
    expect(find.byIcon(Icons.remove), findsOneWidget);
    expect(find.byIcon(Icons.add), findsOneWidget);
    
    // Verifikasi text '1' di dalam Card produk (di sebelah tombol remove/add)
    expect(find.descendant(of: find.byType(Card), matching: find.text('1')), findsOneWidget);

    // Tap icon add -> quantity 2
    await tester.tap(find.byIcon(Icons.add));
    await tester.pump();

    expect(find.descendant(of: find.byType(Card), matching: find.text('2')), findsOneWidget);
    
    // Simulate tapping add until stock limit (stock=10)
    for (int i = 2; i < 10; i++) {
      await tester.tap(find.byIcon(Icons.add));
      await tester.pump();
    }
    
    expect(find.descendant(of: find.byType(Card), matching: find.text('10')), findsOneWidget);
    
    // Icon add is disabled at stock limit, so tapping it should not increase
    await tester.tap(find.byIcon(Icons.add));
    await tester.pump();
    
    // Still 10
    expect(find.descendant(of: find.byType(Card), matching: find.text('10')), findsOneWidget);
    
    // Tap minus -> quantity 9
    await tester.tap(find.byIcon(Icons.remove));
    await tester.pump();
    expect(find.descendant(of: find.byType(Card), matching: find.text('9')), findsOneWidget);

    await tester.pumpWidget(Container());
  });

  testWidgets('SalesScreen tap minus when qty=1 removes item from cart', (tester) async {
    await tester.pumpWidget(createWidget());
    await tester.pump();

    // Tap Tambah 1x (masuk cart)
    await tester.tap(find.widgetWithText(ElevatedButton, 'Tambah'));
    await tester.pump();

    // Verifikasi qty 1
    expect(find.descendant(of: find.byType(Card), matching: find.text('1')), findsOneWidget);

    // Tap minus -> remove from cart
    await tester.tap(find.byIcon(Icons.remove));
    await tester.pump();

    // Verifikasi tombol Tambah muncul lagi
    expect(find.widgetWithText(ElevatedButton, 'Tambah'), findsOneWidget);
    expect(find.byIcon(Icons.remove), findsNothing);
    
    await tester.pumpWidget(Container());
  });
}
