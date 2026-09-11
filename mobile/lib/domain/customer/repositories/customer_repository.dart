import '../entities/customer.dart';

abstract class CustomerRepository {
  Stream<List<Customer>> watchAll({String tenantId = 'tenant-1'});
  Future<Customer?> getById(int id, {String tenantId = 'tenant-1'});
  Future<List<Customer>> getAll({String tenantId = 'tenant-1'});
  Future<int> create({required String name, String? phone, String tenantId = 'tenant-1'});
  Future<void> update(Customer customer, {String tenantId = 'tenant-1'});
  Future<void> delete(int id, {String tenantId = 'tenant-1'});
}
