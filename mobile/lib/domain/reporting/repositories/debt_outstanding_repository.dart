import '../entities/debt_outstanding_report.dart';

abstract class DebtOutstandingRepository {
  Future<DebtOutstandingReport> getOutstandingReport({String tenantId = 'tenant-1'});
}
