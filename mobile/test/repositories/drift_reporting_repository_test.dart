import 'package:flutter_test/flutter_test.dart';
import 'package:drift/drift.dart' as drift;
import 'package:pos_warung_ai/domain/sales/entities/transaction.dart' as sales_domain;
import 'package:pos_warung_ai/infrastructure/database/app_database.dart';
import 'package:pos_warung_ai/infrastructure/repositories/drift_reporting_repository.dart';

void main() {
  late AppDatabase db;
  late DriftReportingRepository repository;

  setUp(() async {
    db = AppDatabase.memory();
    repository = DriftReportingRepository(db);

    await db.into(db.products).insert(ProductsCompanion.insert(tenantId: 'tenant-1', name: 'Indomie', price: 3000, stock: const drift.Value(100), createdAt: DateTime.now()));

    final now = DateTime.now();
    final yesterday = now.subtract(const Duration(days: 1));

    int t1 = await db.into(db.transactions).insert(TransactionsCompanion.insert(
      tenantId: 'tenant-1', total: 3000, paymentMethod: 'cash', createdAt: now,
    ));
    await db.into(db.transactionItems).insert(TransactionItemsCompanion.insert(
      transactionId: t1, productId: 1, quantity: 1, price: 3000, subtotal: 3000,
    ));

    int t2 = await db.into(db.transactions).insert(TransactionsCompanion.insert(
      tenantId: 'tenant-1', total: 6000, paymentMethod: 'qris', createdAt: now.subtract(const Duration(hours: 1)),
    ));
    await db.into(db.transactionItems).insert(TransactionItemsCompanion.insert(
      transactionId: t2, productId: 1, quantity: 2, price: 3000, subtotal: 6000,
    ));

    int t3 = await db.into(db.transactions).insert(TransactionsCompanion.insert(
      tenantId: 'tenant-1', total: 9000, paymentMethod: 'debt', customerId: const drift.Value(1), createdAt: yesterday,
    ));
    await db.into(db.transactionItems).insert(TransactionItemsCompanion.insert(
      transactionId: t3, productId: 1, quantity: 3, price: 3000, subtotal: 9000,
    ));
    
    int t4 = await db.into(db.transactions).insert(TransactionsCompanion.insert(
      tenantId: 'tenant-2', total: 12000, paymentMethod: 'cash', createdAt: now,
    ));
    await db.into(db.transactionItems).insert(TransactionItemsCompanion.insert(
      transactionId: t4, productId: 1, quantity: 4, price: 3000, subtotal: 12000,
    ));
  });

  tearDown(() async {
    await db.close();
  });

  test('getDailyReport hari ini -> total benar, count benar, breakdown benar (ignore tenant-2)', () async {
    final report = await repository.getDailyReport(DateTime.now());
    expect(report.transactionCount, 2);
    expect(report.totalSales, 9000.0);
    
    final cash = report.breakdown.firstWhere((e) => e.method == sales_domain.PaymentMethod.cash);
    expect(cash.transactionCount, 1);
    expect(cash.totalAmount, 3000.0);

    final qris = report.breakdown.firstWhere((e) => e.method == sales_domain.PaymentMethod.qris);
    expect(qris.transactionCount, 1);
    expect(qris.totalAmount, 6000.0);

    final debt = report.breakdown.firstWhere((e) => e.method == sales_domain.PaymentMethod.debt);
    expect(debt.transactionCount, 0);
    expect(debt.totalAmount, 0.0);
  });

  test('getDailyReport hari kosong -> total=0, count=0, list kosong', () async {
    final report = await repository.getDailyReport(DateTime.now().add(const Duration(days: 1))); 
    expect(report.transactionCount, 0);
    expect(report.totalSales, 0.0);
    expect(report.transactions, isEmpty);
    expect(report.breakdown.length, 3);
  });

  test('getRangeReport 7 hari -> hasil sesuai (termasuk kemarin)', () async {
    final from = DateTime.now().subtract(const Duration(days: 6));
    final to = DateTime.now();
    final reports = await repository.getRangeReport(from, to);
    
    expect(reports.length, 7);
    
    final reportToday = reports.last;
    expect(reportToday.transactionCount, 2);
    
    final reportYesterday = reports[reports.length - 2];
    expect(reportYesterday.transactionCount, 1);
    expect(reportYesterday.totalSales, 9000.0);
  });
  
  test('watchDailyReport stream emits updated report', () async {
    final stream = repository.watchDailyReport(DateTime.now());
    final report = await stream.first;
    expect(report.transactionCount, 2);
  });
}
