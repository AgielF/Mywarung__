import '../entities/transaction.dart';

abstract class TransactionRepository {
  Future<int> create(Transaction transaction);
  Future<Transaction?> getById(int id);
  Future<List<Transaction>> getAll({DateTime? from, DateTime? to});
  Stream<List<Transaction>> watchAll({DateTime? from, DateTime? to});
}
