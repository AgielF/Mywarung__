import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pos_warung_ai/domain/customer/entities/customer.dart';
import 'package:pos_warung_ai/domain/reporting/entities/customer_debt_summary.dart';
import 'package:pos_warung_ai/domain/reporting/entities/debt_outstanding_report.dart';
import 'package:pos_warung_ai/domain/reporting/repositories/debt_outstanding_repository.dart';
import 'package:pos_warung_ai/domain/customer/repositories/debt_repository.dart';
import 'package:pos_warung_ai/ui/reporting/debt_outstanding_screen.dart';
import 'package:pos_warung_ai/domain/customer/entities/debt.dart';

class FakeDebtOutstandingRepository implements DebtOutstandingRepository {
  DebtOutstandingReport? report;
  bool throwError = false;

  @override
  Future<DebtOutstandingReport> getOutstandingReport({String tenantId = 'tenant-1'}) async {
    if (throwError) throw Exception('Test error');
    if (report != null) return report!;
    return const DebtOutstandingReport(
      totalOutstanding: 0,
      customerCount: 0,
      debtCount: 0,
      summaries: [],
    );
  }
}

class FakeDebtRepository implements DebtRepository {
  @override
  Future<int> createDebt({required int customerId, required double amount, String tenantId = 'tenant-1'}) async {
    throw UnimplementedError();
  }



  @override
  Future<void> payDebt({required int debtId, required double payment, String tenantId = 'tenant-1'}) async {
    throw UnimplementedError();
  }

  @override
  Future<void> delete(int id, {String tenantId = 'tenant-1'}) async {
    throw UnimplementedError();
  }

  @override
  Future<List<Debt>> getUnpaidByCustomer(int customerId, {String tenantId = 'tenant-1'}) async {
    return [];
  }

  @override
  Stream<List<Debt>> watchAll({String tenantId = 'tenant-1'}) async* {}

  @override
  Stream<List<Debt>> watchByCustomer(int customerId, {String tenantId = 'tenant-1'}) async* {}
}

void main() {
  late FakeDebtOutstandingRepository repo;
  late FakeDebtRepository debtRepo;

  setUp(() {
    repo = FakeDebtOutstandingRepository();
    debtRepo = FakeDebtRepository();
  });

  Widget createWidget() {
    return MaterialApp(
      home: DebtOutstandingScreen(
        debtOutstandingRepository: repo,
        debtRepository: debtRepo,
      ),
    );
  }

  testWidgets('empty state tampil saat data kosong', (tester) async {
    await tester.pumpWidget(createWidget());
    await tester.pumpAndSettle();

    expect(find.text('Belum ada piutang'), findsOneWidget);
    expect(find.text('Total Piutang'), findsNothing); // summary tidak tampil
  });

  testWidgets('list customer dan summary card tampil saat ada data', (tester) async {
    repo.report = DebtOutstandingReport(
      totalOutstanding: 150000,
      customerCount: 2,
      debtCount: 3,
      summaries: [
        CustomerDebtSummary(
          customer: Customer(id: 1, tenantId: 'tenant-1', name: 'Budi', phone: '0812', createdAt: DateTime(2023)),
          totalDebt: 100000,
          totalPaid: 0,
          remaining: 100000,
          unpaidCount: 1,
        ),
        CustomerDebtSummary(
          customer: Customer(id: 2, tenantId: 'tenant-1', name: 'Andi', phone: '', createdAt: DateTime(2023)),
          totalDebt: 50000,
          totalPaid: 0,
          remaining: 50000,
          unpaidCount: 2,
        ),
      ],
    );

    await tester.pumpWidget(createWidget());
    await tester.pumpAndSettle();

    // Cek Summary
    expect(find.text('Total Piutang'), findsOneWidget);
    expect(find.text('Rp 150.000'), findsOneWidget);
    expect(find.text('2'), findsWidgets); // Jumlah customer
    expect(find.text('3'), findsWidgets); // Jumlah kasbon
    
    // Cek List
    expect(find.text('Daftar Customer'), findsOneWidget);
    expect(find.text('Budi'), findsOneWidget);
    expect(find.text('0812'), findsOneWidget);
    expect(find.text('Rp 100.000'), findsOneWidget);
    expect(find.text('1 kasbon'), findsOneWidget);

    expect(find.text('Andi'), findsOneWidget);
    expect(find.text('Tanpa nomor telepon'), findsOneWidget);
    expect(find.text('Rp 50.000'), findsOneWidget);
    expect(find.text('2 kasbon'), findsOneWidget);
  });

  testWidgets('error state tampil saat repository throw', (tester) async {
    repo.throwError = true;
    
    await tester.pumpWidget(createWidget());
    await tester.pumpAndSettle();

    expect(find.text('Terjadi kesalahan saat memuat data'), findsOneWidget);
    expect(find.text('Coba Lagi'), findsOneWidget);
  });
}
