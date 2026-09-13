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

  @override
  Stream<List<Customer>> watchAll({String tenantId = 'tenant-1'}) async* {}
  @override
  Future<Customer?> getById(int id, {String tenantId = 'tenant-1'}) async =>
      null;
  @override
  Future<List<Customer>> getAll({String tenantId = 'tenant-1'}) async => [];
  @override
  Future<int> create({
    required String name,
    String? phone,
    String tenantId = 'tenant-1',
  }) async => 1;
  @override
  Future<void> update(
    Customer customer, {
    String tenantId = 'tenant-1',
  }) async {}
  @override
  Future<void> delete(int id, {String tenantId = 'tenant-1'}) async {
    deleteCalled = true;
  }
}

class MockDebtRepository implements DebtRepository {
  List<Debt> debtsToYield = [];

  @override
  Stream<List<Debt>> watchAll({String tenantId = 'tenant-1'}) async* {}
  @override
  Stream<List<Debt>> watchByCustomer(
    int customerId, {
    String tenantId = 'tenant-1',
  }) async* {
    yield debtsToYield;
  }

  @override
  Future<List<Debt>> getUnpaidByCustomer(
    int customerId, {
    String tenantId = 'tenant-1',
  }) async => debtsToYield;
  @override
  Future<int> createDebt({
    required int customerId,
    required double amount,
    DateTime? dueDate,
    String tenantId = 'tenant-1',
  }) async => 1;
  @override
  Future<void> payDebt({
    required int debtId,
    required double payment,
    String tenantId = 'tenant-1',
  }) async {}
  @override
  Future<void> delete(int id, {String tenantId = 'tenant-1'}) async {}
}

class MockTransactionRepository implements TransactionRepository {
  @override
  Stream<List<domain.Transaction>> watchAll({
    DateTime? from,
    DateTime? to,
  }) async* {}
  @override
  Future<List<domain.Transaction>> getAll({
    DateTime? from,
    DateTime? to,
  }) async => [];
  @override
  Future<domain.Transaction?> getById(int id) async => null;
  @override
  Future<int> create(domain.Transaction transaction) async => 1;
}

void main() {
  late MockCustomerRepository customerRepo;
  late MockDebtRepository debtRepo;
  late MockTransactionRepository txRepo;

  final testCustomer = Customer(
    id: 1,
    tenantId: 'tenant-1',
    name: 'Budi Kasbon',
    createdAt: DateTime.now(),
  );

  setUp(() {
    customerRepo = MockCustomerRepository();
    debtRepo = MockDebtRepository();
    txRepo = MockTransactionRepository();
  });

  Widget createWidget() {
    return MaterialApp(
      home: Scaffold(
        body: DebtListScreen(
          customer: testCustomer,
          debtRepository: debtRepo,
          customerRepository: customerRepo,
          transactionRepository: txRepo,
        ),
      ),
    );
  }

  testWidgets('DebtListScreen shows popup menu with Edit and Hapus', (
    tester,
  ) async {
    await tester.pumpWidget(createWidget());
    await tester.pumpAndSettle();

    final popupMenuButton = find.byType(PopupMenuButton<String>);
    expect(popupMenuButton, findsOneWidget);

    await tester.tap(popupMenuButton);
    await tester.pumpAndSettle();

    expect(find.text('Edit Customer'), findsOneWidget);
    expect(find.text('Hapus Customer'), findsOneWidget);
  });

  testWidgets('DebtListScreen hapus customer tanpa kasbon berhasil', (
    tester,
  ) async {
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

  testWidgets('Debt overdue menampilkan badge Terlambat', (tester) async {
    debtRepo.debtsToYield = [
      Debt(
        id: 1,
        tenantId: 'tenant-1',
        customerId: 1,
        amount: 50000,
        paid: 0,
        status: DebtStatus.unpaid,
        createdAt: DateTime.now(),
        dueDate: DateTime.now().subtract(const Duration(days: 1)),
      ),
    ];
    await tester.pumpWidget(createWidget());
    await tester.pumpAndSettle();
    expect(find.text('Terlambat'), findsOneWidget);
  });

  testWidgets('Debt due soon menampilkan badge Segera jatuh tempo', (
    tester,
  ) async {
    debtRepo.debtsToYield = [
      Debt(
        id: 1,
        tenantId: 'tenant-1',
        customerId: 1,
        amount: 50000,
        paid: 0,
        status: DebtStatus.unpaid,
        createdAt: DateTime.now(),
        dueDate: DateTime.now().add(const Duration(days: 2)),
      ),
    ];
    await tester.pumpWidget(createWidget());
    await tester.pumpAndSettle();
    expect(find.text('Segera jatuh tempo'), findsOneWidget);
  });

  testWidgets('Debt jauh dari jatuh tempo menampilkan tanggal + sisa hari', (
    tester,
  ) async {
    debtRepo.debtsToYield = [
      Debt(
        id: 1,
        tenantId: 'tenant-1',
        customerId: 1,
        amount: 50000,
        paid: 0,
        status: DebtStatus.unpaid,
        createdAt: DateTime.now(),
        dueDate: DateTime.now().add(const Duration(days: 30, hours: 1)),
      ),
    ];
    await tester.pumpWidget(createWidget());
    await tester.pumpAndSettle();
    expect(find.text('Terlambat'), findsNothing);
    expect(find.text('Segera jatuh tempo'), findsNothing);
    expect(find.textContaining('Jatuh tempo:'), findsOneWidget);
    expect(find.textContaining('30 hari lagi'), findsOneWidget);
  });
}
