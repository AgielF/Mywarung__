import '../entities/daily_report.dart';
import '../entities/sales_trend_point.dart';

abstract class ReportingRepository {
  Future<DailyReport> getDailyReport(DateTime date, {String tenantId = 'tenant-1'});
  Stream<DailyReport> watchDailyReport(DateTime date, {String tenantId = 'tenant-1'});
  Future<List<DailyReport>> getRangeReport(DateTime from, DateTime to, {String tenantId = 'tenant-1'});
  Stream<List<DailyReport>> watchRangeReport(DateTime from, DateTime to, {String tenantId = 'tenant-1'});
  Future<List<SalesTrendPoint>> getSalesTrend({int days = 7, String tenantId = 'tenant-1'});
}
