import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pos_warung_ai/domain/customer/entities/customer.dart';
import 'package:pos_warung_ai/domain/customer/entities/debt.dart';
import 'package:pos_warung_ai/domain/customer/repositories/customer_repository.dart';
import 'package:pos_warung_ai/domain/customer/repositories/debt_repository.dart';
import 'package:pos_warung_ai/domain/sales/entities/transaction.dart' as domain;
import 'package:pos_warung_ai/domain/sales/repositories/transaction_repository.dart';
import 'package:pos_warung_ai/ui/customer/debt_list_screen.dart';

class MockCustomerRepository implements CustomerRepository {
  bool deleteCalled = false;

  @override Stream<List<Customer>> watchAll({String tenantId = 'tenant-1'}) async* {}
  @override Future<Customer?> getById(int id, {String tenantId = 'tenant-1'}) async => null;
  @override Future<List<Customer>> getAll({String tenantId = 'tenant-1'}) async => [];
  @override Future<int> create({required String name, String? phone, String tenantId = 'tenant-1'}) async => 1;
  @override Future<void> update(Customer customer, {String tenantId = 'tenant-1'}) async {}
  @override Future<void> delete(int id, {String tenantId = 'tenant-1'}) async {
    deleteCalled = true;
  }
}

class MockDebtRepository implements DebtRepository {
  @override Stream<List<Debt>> watchAll({String tenantId = 'tenant-1'}) async* {}
  @override Stream<List<Debt>> watchByCustomer(int customerId, {String tenantId = 'tenant-1'}) async* {
    yield [];
  }
  @override Future<List<Debt>> getUnpaidByCustomer(int customerId, {String tenantId = 'tenant-1'}) async => [];
  @override Future<int> createDebt({required int customerId, required double amount, String tenantId = 'tenant-1'}) async => 1;
  @override Future<void> payDebt({required int debtId, required double payment, String tenantId = 'tenant-1'}) async {}
  @override Future<void> delete(int id, {String tenantId = 'tenant-1'}) async {}
}

class MockTransactionRepository implements TransactionRepository {
  @override Stream<List<domain.Transaction>> watchAll({DateTime? from, DateTime? to}) async* {}
  @override Future<List<domain.Transaction>> getAll({DateTime? from, DateTime? to}) async => [];
  @override Future<domain.Transaction?> getById(int id) async => null;
  @override Future<int> create(domain.Transaction transaction) async => 1;
}

void main() {
  late MockCustomerRepository customerRepo;
  late MockDebtRepository debtRepo;
  late MockTransactionRepository txRepo;

  final testCustomer = Customer(id: 1, tenantId: 'tenant-1', name: 'Budi Kasbon', createdAt: DateTime.now());

  setUp(() {
    customerRepo = MockCustomerRepository();
    debtRepo = MockDebtRepository();
    txRepo = MockTransactionRepository();
  });

  Widget createWidget() {
    return MaterialApp(
      home: DebtListScreen(
        customer: testCustomer,
        debtRepository: debtRepo,
        customerRepository: customerRepo,
        transactionRepository: txRepo,
      ),
    );
  }

  testWidgets('DebtListScreen shows popup menu with Edit and Hapus', (tester) async {
    await tester.pumpWidget(createWidget());
    await tester.pumpAndSettle();

    final popupMenuButton = find.byType(PopupMenuButton<String>);
    expect(popupMenuButton, findsOneWidget);

    await tester.tap(popupMenuButton);
    await tester.pumpAndSettle();

    expect(find.text('Edit Customer'), findsOneWidget);
    expect(find.text('Hapus Customer'), findsOneWidget);
  });

  testWidgets('DebtListScreen hapus customer tanpa kasbon berhasil', (tester) async {
    await tester.pumpWidget(createWidget());
    await tester.pumpAndSettle();

    await tester.tap(find.byType(PopupMenuButton<String>));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Hapus Customer'));
    await tester.pumpAndSettle();

    // Dialog confirm
    expect(find.text('Hapus Customer'), findsWidgets); // Title and button
    
    await tester.tap(find.text('Hapus'));
    await tester.pumpAndSettle();

    expect(customerRepo.deleteCalled, isTrue);
  });
}
