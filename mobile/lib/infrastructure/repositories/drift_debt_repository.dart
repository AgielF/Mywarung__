import 'package:drift/drift.dart';
import '../../domain/customer/entities/debt.dart' as domain;
import '../../domain/customer/repositories/debt_repository.dart';
import '../database/app_database.dart' as drift;

class DriftDebtRepository implements DebtRepository {
  final drift.AppDatabase _db;

  DriftDebtRepository(this._db);

  @override
  Stream<List<domain.Debt>> watchAll({String tenantId = 'tenant-1'}) {
    final query = _db.select(_db.debts)
      ..where((tbl) => tbl.tenantId.equals(tenantId))
      ..orderBy([(tbl) => OrderingTerm(expression: tbl.createdAt, mode: OrderingMode.desc)]);
    
    return query.watch().map((debtsData) => debtsData.map((data) => data.toDomain()).toList());
  }

  @override
  Stream<List<domain.Debt>> watchByCustomer(int customerId, {String tenantId = 'tenant-1'}) {
    final query = _db.select(_db.debts)
      ..where((tbl) => tbl.tenantId.equals(tenantId))
      ..where((tbl) => tbl.customerId.equals(customerId))
      ..orderBy([(tbl) => OrderingTerm(expression: tbl.createdAt, mode: OrderingMode.desc)]);
    
    return query.watch().map((debtsData) => debtsData.map((data) => data.toDomain()).toList());
  }

  @override
  Future<List<domain.Debt>> getUnpaidByCustomer(int customerId, {String tenantId = 'tenant-1'}) async {
    final query = _db.select(_db.debts)
      ..where((tbl) => tbl.tenantId.equals(tenantId))
      ..where((tbl) => tbl.customerId.equals(customerId))
      ..where((tbl) => tbl.status.equals('unpaid'))
      ..orderBy([(tbl) => OrderingTerm(expression: tbl.createdAt, mode: OrderingMode.desc)]);
    
    final debtsData = await query.get();
    return debtsData.map((data) => data.toDomain()).toList();
  }

  @override
  Future<int> createDebt({required int customerId, required double amount, String tenantId = 'tenant-1'}) async {
    return await _db.into(_db.debts).insert(
      drift.DebtsCompanion.insert(
        tenantId: tenantId,
        customerId: customerId,
        amount: amount,
        paid: const Value(0),
        status: 'unpaid',
        createdAt: DateTime.now(),
      ),
    );
  }

  @override
  Future<void> payDebt({required int debtId, required double payment, String tenantId = 'tenant-1'}) async {
    await _db.transaction(() async {
      final query = _db.select(_db.debts)
        ..where((tbl) => tbl.id.equals(debtId))
        ..where((tbl) => tbl.tenantId.equals(tenantId));
      final debtData = await query.getSingleOrNull();

      if (debtData == null) {
        throw StateError('Debt tidak ditemukan');
      }

      if (payment <= 0) {
        throw ArgumentError('Pembayaran harus lebih dari 0');
      }

      final newPaid = debtData.paid + payment;
      if (newPaid > debtData.amount) {
        throw ArgumentError('Pembayaran melebihi sisa kasbon');
      }

      final newStatus = newPaid >= debtData.amount ? 'paid' : 'unpaid';

      await (_db.update(_db.debts)
        ..where((tbl) => tbl.id.equals(debtId))
        ..where((tbl) => tbl.tenantId.equals(tenantId))
      ).write(
        drift.DebtsCompanion(
          paid: Value(newPaid),
          status: Value(newStatus),
          updatedAt: Value(DateTime.now()),
        ),
      );
    });
  }

  @override
  Future<void> delete(int id, {String tenantId = 'tenant-1'}) async {
    await (_db.delete(_db.debts)
      ..where((tbl) => tbl.id.equals(id))
      ..where((tbl) => tbl.tenantId.equals(tenantId))
    ).go();
  }
}

extension DebtDataMapper on drift.Debt {
  domain.Debt toDomain() {
    return domain.Debt(
      id: id,
      tenantId: tenantId,
      customerId: customerId,
      amount: amount,
      paid: paid,
      status: domain.DebtStatus.fromString(status),
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
