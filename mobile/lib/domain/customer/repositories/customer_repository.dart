import '../entities/customer.dart';

abstract class CustomerRepository {
  Stream<List<Customer>> watchAll();
  Future<Customer?> getById(int id);
  Future<List<Customer>> getAll();
  Future<int> create({required String name, String? phone, String tenantId = 'tenant-1'});
  Future<void> update(Customer customer);
  Future<void> delete(int id);
}
