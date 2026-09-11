import 'package:flutter_test/flutter_test.dart';

import 'package:pos_warung_ai/main.dart';
import 'package:pos_warung_ai/domain/reporting/repositories/reporting_repository.dart';
import 'package:pos_warung_ai/domain/reporting/entities/daily_report.dart';
import 'package:pos_warung_ai/domain/reporting/entities/sales_trend_point.dart';
import 'package:pos_warung_ai/infrastructure/database/app_database.dart';
import 'package:pos_warung_ai/infrastructure/repositories/drift_product_repository.dart';
import 'package:pos_warung_ai/infrastructure/repositories/drift_transaction_repository.dart';
import 'package:pos_warung_ai/infrastructure/repositories/drift_customer_repository.dart';
import 'package:pos_warung_ai/infrastructure/repositories/drift_debt_repository.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    final database = AppDatabase.memory();
    final repository = DriftProductRepository(database);
    final txRepository = DriftTransactionRepository(database);
    final customerRepo = DriftCustomerRepository(database);
    final debtRepo = DriftDebtRepository(database);
    final reportingRepo = FakeReportingRepository();

    // Build our app and trigger a frame.
    await tester.pumpWidget(POSWarungAIApp(
      productRepository: repository,
      transactionRepository: txRepository,
      customerRepository: customerRepo,
      debtRepository: debtRepo,
      reportingRepository: reportingRepo,
    ));

    // Verify that the title text is present.
    expect(find.text('POS Warung AI'), findsWidgets);
    expect(find.text('Offline-First POS untuk Warung Indonesia'), findsOneWidget);

    await database.close();
  });
}

class FakeReportingRepository implements ReportingRepository {
  @override
  Future<DailyReport> getDailyReport(DateTime date, {String tenantId = 'tenant-1'}) async => DailyReport(date: date, totalSales: 0, transactionCount: 0, breakdown: const [], transactions: const []);
  @override
  Stream<DailyReport> watchDailyReport(DateTime date, {String tenantId = 'tenant-1'}) async* {}
  @override
  Future<List<DailyReport>> getRangeReport(DateTime from, DateTime to, {String tenantId = 'tenant-1'}) async => [];
  @override
  Future<List<SalesTrendPoint>> getSalesTrend({int days = 7, String tenantId = 'tenant-1'}) async => [];
}
