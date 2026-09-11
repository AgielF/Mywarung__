import '../entities/debt.dart';

abstract class DebtRepository {
  Stream<List<Debt>> watchAll();
  Stream<List<Debt>> watchByCustomer(int customerId);
  Future<List<Debt>> getUnpaidByCustomer(int customerId);
  Future<int> createDebt({required int customerId, required double amount, String tenantId = 'tenant-1'});
  Future<void> payDebt({required int debtId, required double payment});
  Future<void> delete(int id);
}
