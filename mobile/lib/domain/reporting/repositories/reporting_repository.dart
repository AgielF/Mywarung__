import '../entities/daily_report.dart';

abstract class ReportingRepository {
  Future<DailyReport> getDailyReport(DateTime date, {String tenantId = 'tenant-1'});
  Stream<DailyReport> watchDailyReport(DateTime date, {String tenantId = 'tenant-1'});
  Future<List<DailyReport>> getRangeReport(DateTime from, DateTime to, {String tenantId = 'tenant-1'});
}
