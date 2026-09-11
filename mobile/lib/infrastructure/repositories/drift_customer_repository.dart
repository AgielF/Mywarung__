import 'package:drift/drift.dart';
import '../../domain/customer/entities/customer.dart' as domain;
import '../../domain/customer/repositories/customer_repository.dart';
import '../database/app_database.dart' as drift;

class DriftCustomerRepository implements CustomerRepository {
  final drift.AppDatabase _db;

  DriftCustomerRepository(this._db);

  @override
  Stream<List<domain.Customer>> watchAll({String tenantId = 'tenant-1'}) {
    final query = _db.select(_db.customers)
      ..where((tbl) => tbl.tenantId.equals(tenantId))
      ..orderBy([(tbl) => OrderingTerm(expression: tbl.createdAt, mode: OrderingMode.desc)]);
    
    return query.watch().map((customersData) => customersData.map((data) => data.toDomain()).toList());
  }

  @override
  Future<domain.Customer?> getById(int id) async {
    final query = _db.select(_db.customers)..where((tbl) => tbl.id.equals(id));
    final data = await query.getSingleOrNull();
    return data?.toDomain();
  }

  @override
  Future<List<domain.Customer>> getAll({String tenantId = 'tenant-1'}) async {
    final query = _db.select(_db.customers)
      ..where((tbl) => tbl.tenantId.equals(tenantId))
      ..orderBy([(tbl) => OrderingTerm(expression: tbl.createdAt, mode: OrderingMode.desc)]);
    
    final data = await query.get();
    return data.map((d) => d.toDomain()).toList();
  }

  @override
  Future<int> create({required String name, String? phone, String tenantId = 'tenant-1'}) async {
    return await _db.into(_db.customers).insert(
      drift.CustomersCompanion.insert(
        tenantId: tenantId,
        name: name,
        phone: phone == null ? const Value.absent() : Value(phone),
        createdAt: DateTime.now(),
      ),
    );
  }

  @override
  Future<void> update(domain.Customer customer) async {
    await (_db.update(_db.customers)..where((tbl) => tbl.id.equals(customer.id!))).write(
      drift.CustomersCompanion(
        name: Value(customer.name),
        phone: Value(customer.phone),
      ),
    );
  }

  @override
  Future<void> delete(int id) async {
    await _db.transaction(() async {
      // Cek apakah customer punya debt unpaid
      final unpaidDebtsQuery = _db.select(_db.debts)
        ..where((tbl) => tbl.customerId.equals(id))
        ..where((tbl) => tbl.status.equals('unpaid'));
        
      final unpaidDebts = await unpaidDebtsQuery.get();
      
      if (unpaidDebts.isNotEmpty) {
        throw StateError('Customer masih punya kasbon belum lunas');
      }

      // Hapus debt lunas milik customer (kalau ada)
      await (_db.delete(_db.debts)..where((tbl) => tbl.customerId.equals(id))).go();
      
      // Hapus customer
      await (_db.delete(_db.customers)..where((tbl) => tbl.id.equals(id))).go();
    });
  }
}

extension CustomerDataMapper on drift.Customer {
  domain.Customer toDomain() {
    return domain.Customer(
      id: id,
      tenantId: tenantId,
      name: name,
      phone: phone,
      createdAt: createdAt,
    );
  }
}
