import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pos_warung_ai/domain/customer/entities/customer.dart';
import 'package:pos_warung_ai/domain/customer/repositories/customer_repository.dart';
import 'package:pos_warung_ai/domain/customer/repositories/debt_repository.dart';
import 'package:pos_warung_ai/ui/customer/customer_list_screen.dart';
import 'package:pos_warung_ai/domain/customer/entities/debt.dart';
import 'package:pos_warung_ai/domain/sales/repositories/transaction_repository.dart';
import 'package:pos_warung_ai/domain/sales/entities/transaction.dart';

class MockCustomerRepository implements CustomerRepository {
  List<Customer> _customers = [];
  bool throwError;

  MockCustomerRepository({List<Customer>? initialCustomers, this.throwError = false}) {
    if (initialCustomers != null) {
      _customers = initialCustomers;
    }
  }

  @override
  Stream<List<Customer>> watchAll({String tenantId = 'tenant-1'}) async* {
    if (throwError) {
      throw Exception('Simulated Error');
    }
    yield _customers;
  }

  @override
  Future<Customer?> getById(int id, {String tenantId = 'tenant-1'}) async => null;

  @override
  Future<List<Customer>> getAll({String tenantId = 'tenant-1'}) async => _customers;

  @override
  Future<int> create({required String name, String? phone, String tenantId = 'tenant-1'}) async => 1;

  @override
  Future<void> update(Customer customer, {String tenantId = 'tenant-1'}) async {}

  @override
  Future<void> delete(int id, {String tenantId = 'tenant-1'}) async {}
}

class MockDebtRepository implements DebtRepository {
  @override
  Stream<List<Debt>> watchAll({String tenantId = 'tenant-1'}) async* {}

  @override
  Stream<List<Debt>> watchByCustomer(int customerId, {String tenantId = 'tenant-1'}) async* {}

  @override
  Future<List<Debt>> getUnpaidByCustomer(int customerId, {String tenantId = 'tenant-1'}) async => [];

  @override
  Future<int> createDebt({required int customerId, required double amount, String tenantId = 'tenant-1'}) async => 1;

  @override
  Future<void> payDebt({required int debtId, required double payment, String tenantId = 'tenant-1'}) async {}

  @override
  Future<void> delete(int id, {String tenantId = 'tenant-1'}) async {}
}


class MockTransactionRepository implements TransactionRepository {
  @override
  Stream<List<Transaction>> watchAll({DateTime? from, DateTime? to}) async* {}

  @override
  Future<List<Transaction>> getAll({DateTime? from, DateTime? to}) async => [];

  @override
  Future<Transaction?> getById(int id) async => null;

  @override
  Future<int> create(Transaction transaction) async => 1;
}

void main() {
  testWidgets('CustomerListScreen shows empty state', (WidgetTester tester) async {
    final customerRepo = MockCustomerRepository();
    final debtRepo = MockDebtRepository();
    final txRepo = MockTransactionRepository();

    await tester.pumpWidget(MaterialApp(
      home: CustomerListScreen(
        customerRepository: customerRepo,
        debtRepository: debtRepo,
        transactionRepository: txRepo,
      ),
    ));

    await tester.pumpAndSettle();

    expect(find.text('Belum ada customer'), findsOneWidget);
    expect(find.byType(FloatingActionButton), findsOneWidget);
  });

  testWidgets('CustomerListScreen shows list of customers', (WidgetTester tester) async {
    final customerRepo = MockCustomerRepository(initialCustomers: [
      Customer(id: 1, tenantId: 'tenant-1', name: 'Budi', createdAt: DateTime.now()),
      Customer(id: 2, tenantId: 'tenant-1', name: 'Ani', phone: '08123456789', createdAt: DateTime.now()),
    ]);
    final debtRepo = MockDebtRepository();
    final txRepo = MockTransactionRepository();

    await tester.pumpWidget(MaterialApp(
      home: CustomerListScreen(
        customerRepository: customerRepo,
        debtRepository: debtRepo,
        transactionRepository: txRepo,
      ),
    ));

    await tester.pumpAndSettle();

    expect(find.text('Budi'), findsOneWidget);
    expect(find.text('Ani'), findsOneWidget);
    expect(find.text('08123456789'), findsOneWidget);
    expect(find.byType(ListTile), findsNWidgets(2));
  });

  testWidgets('CustomerListScreen shows error state and retry button', (WidgetTester tester) async {
    final customerRepo = MockCustomerRepository(throwError: true);
    final debtRepo = MockDebtRepository();
    final txRepo = MockTransactionRepository();

    await tester.pumpWidget(MaterialApp(
      home: CustomerListScreen(
        customerRepository: customerRepo,
        debtRepository: debtRepo,
        transactionRepository: txRepo,
      ),
    ));

    await tester.pumpAndSettle();

    expect(find.textContaining('Terjadi kesalahan'), findsOneWidget);
    expect(find.text('Coba Lagi'), findsOneWidget);
    expect(find.byType(ElevatedButton), findsOneWidget);
  });
}
