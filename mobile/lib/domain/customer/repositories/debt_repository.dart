import '../entities/debt.dart';

abstract class DebtRepository {
  Stream<List<Debt>> watchAll({String tenantId = 'tenant-1'});
  Stream<List<Debt>> watchByCustomer(int customerId, {String tenantId = 'tenant-1'});
  Future<List<Debt>> getUnpaidByCustomer(int customerId, {String tenantId = 'tenant-1'});
  Future<int> createDebt({required int customerId, required double amount, String tenantId = 'tenant-1'});
  Future<void> payDebt({required int debtId, required double payment, String tenantId = 'tenant-1'});
  Future<void> delete(int id, {String tenantId = 'tenant-1'});
}
