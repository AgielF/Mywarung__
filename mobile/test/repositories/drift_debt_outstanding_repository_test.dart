import 'package:flutter_test/flutter_test.dart';
import 'package:pos_warung_ai/infrastructure/database/app_database.dart';
import 'package:pos_warung_ai/infrastructure/repositories/drift_customer_repository.dart';
import 'package:pos_warung_ai/infrastructure/repositories/drift_debt_repository.dart';
import 'package:pos_warung_ai/infrastructure/repositories/drift_debt_outstanding_repository.dart';

void main() {
  late AppDatabase db;
  late DriftCustomerRepository customerRepo;
  late DriftDebtRepository debtRepo;
  late DriftDebtOutstandingRepository repository;

  setUp(() {
    db = AppDatabase.memory();
    customerRepo = DriftCustomerRepository(db);
    debtRepo = DriftDebtRepository(db);
    repository = DriftDebtOutstandingRepository(db);
  });

  tearDown(() async {
    await db.close();
  });

  test('3 customer dengan beberapa unpaid debt -> total, counts benar, urut desc', () async {
    // Insert customers
    final c1Id = await customerRepo.create(name: 'C1', phone: '1');
    final c2Id = await customerRepo.create(name: 'C2', phone: '2');
    final c3Id = await customerRepo.create(name: 'C3', phone: '3');
    
    // c1: 2 unpaid debts, total 30000, paid 5000 -> remaining 25000
    await debtRepo.createDebt(customerId: c1Id, amount: 10000);
    await debtRepo.createDebt(customerId: c1Id, amount: 20000);
    final c1Debts = await db.select(db.debts).get();
    await debtRepo.payDebt(debtId: c1Debts.first.id, payment: 5000);

    // c2: 1 unpaid debt, total 50000, paid 0 -> remaining 50000
    await debtRepo.createDebt(customerId: c2Id, amount: 50000);

    // c3: 1 unpaid debt, total 10000, paid 0 -> remaining 10000
    await debtRepo.createDebt(customerId: c3Id, amount: 10000);

    final report = await repository.getOutstandingReport();
    
    expect(report.customerCount, 3);
    expect(report.debtCount, 4);
    expect(report.totalOutstanding, 85000); // 25000 + 50000 + 10000
    expect(report.summaries.length, 3);
    
    // Sort descending by remaining
    expect(report.summaries[0].customer.id, c2Id); // 50000
    expect(report.summaries[1].customer.id, c1Id); // 25000
    expect(report.summaries[2].customer.id, c3Id); // 10000
    
    // Check specific summary
    expect(report.summaries[1].unpaidCount, 2);
    expect(report.summaries[1].totalDebt, 30000);
    expect(report.summaries[1].totalPaid, 5000);
  });

  test('customer dengan debt lunas -> tidak masuk summaries', () async {
    final c1Id = await customerRepo.create(name: 'C1', phone: '');
    await debtRepo.createDebt(customerId: c1Id, amount: 10000);
    
    final debts = await db.select(db.debts).get();
    await debtRepo.payDebt(debtId: debts.first.id, payment: 10000); // lunas

    final report = await repository.getOutstandingReport();
    expect(report.customerCount, 0);
    expect(report.debtCount, 0);
    expect(report.totalOutstanding, 0);
    expect(report.summaries.isEmpty, isTrue);
  });

  test('tidak ada debt sama sekali -> total=0, list kosong', () async {
    final report = await repository.getOutstandingReport();
    expect(report.customerCount, 0);
    expect(report.debtCount, 0);
    expect(report.totalOutstanding, 0);
    expect(report.summaries.isEmpty, isTrue);
  });

  test('filter tenant berbeda -> hasil tidak tercampur', () async {
    final c1Id = await customerRepo.create(name: 'T1', phone: '', tenantId: 'tenant-1');
    await debtRepo.createDebt(customerId: c1Id, amount: 10000, tenantId: 'tenant-1');
    
    final c2Id = await customerRepo.create(name: 'T2', phone: '', tenantId: 'tenant-2');
    await debtRepo.createDebt(customerId: c2Id, amount: 20000, tenantId: 'tenant-2');

    final report1 = await repository.getOutstandingReport(tenantId: 'tenant-1');
    expect(report1.customerCount, 1);
    expect(report1.totalOutstanding, 10000);

    final report2 = await repository.getOutstandingReport(tenantId: 'tenant-2');
    expect(report2.customerCount, 1);
    expect(report2.totalOutstanding, 20000);
  });
}
