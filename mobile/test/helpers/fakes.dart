import 'package:pos_warung_ai/domain/reporting/repositories/reporting_repository.dart';
import 'package:pos_warung_ai/domain/reporting/entities/daily_report.dart';
import 'package:pos_warung_ai/domain/reporting/entities/sales_trend_point.dart';
import 'package:pos_warung_ai/domain/reporting/repositories/debt_outstanding_repository.dart';
import 'package:pos_warung_ai/domain/reporting/entities/debt_outstanding_report.dart';
import 'package:pos_warung_ai/domain/customer/repositories/debt_repository.dart';
import 'package:pos_warung_ai/domain/customer/entities/debt.dart';

class FakeReportingRepository implements ReportingRepository {
  DailyReport? fakeDailyReport;
  List<DailyReport>? fakeRangeReport;
  List<SalesTrendPoint>? fakeTrend;
  bool throwError = false; // legacy
  bool throwTrendError = false;
  bool throwReportError = false;

  bool get _shouldThrowReport => throwError || throwReportError;
  bool get _shouldThrowTrend => throwError || throwTrendError;

  @override
  Future<DailyReport> getDailyReport(DateTime date, {String tenantId = 'tenant-1'}) async {
    if (_shouldThrowReport) throw Exception('Test error');
    return fakeDailyReport ?? DailyReport(date: date, totalSales: 0, transactionCount: 0, breakdown: const [], transactions: const []);
  }

  @override
  Stream<DailyReport> watchDailyReport(DateTime date, {String tenantId = 'tenant-1'}) async* {
    if (_shouldThrowReport) throw Exception('Test error');
    yield await getDailyReport(date, tenantId: tenantId);
  }

  @override
  Future<List<DailyReport>> getRangeReport(DateTime from, DateTime to, {String tenantId = 'tenant-1'}) async {
    if (_shouldThrowReport) throw Exception('Test error');
    return fakeRangeReport ?? [];
  }

  @override
  Stream<List<DailyReport>> watchRangeReport(DateTime from, DateTime to, {String tenantId = 'tenant-1'}) async* {
    if (_shouldThrowReport) throw Exception('Test error');
    yield await getRangeReport(from, to, tenantId: tenantId);
  }

  @override
  Future<List<SalesTrendPoint>> getSalesTrend({int days = 7, String tenantId = 'tenant-1'}) async {
    if (_shouldThrowTrend) throw Exception('Test error');
    return fakeTrend ?? [];
  }
}

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
