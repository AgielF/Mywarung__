import 'package:flutter_test/flutter_test.dart';
import 'package:pos_warung_ai/domain/customer/entities/debt.dart';
import 'package:pos_warung_ai/infrastructure/database/app_database.dart';
import 'package:pos_warung_ai/infrastructure/repositories/drift_customer_repository.dart';
import 'package:pos_warung_ai/infrastructure/repositories/drift_debt_repository.dart';

void main() {
  late AppDatabase database;
  late DriftCustomerRepository customerRepo;
  late DriftDebtRepository debtRepo;
  late int customerId;

  setUp(() async {
    database = AppDatabase.memory();
    customerRepo = DriftCustomerRepository(database);
    debtRepo = DriftDebtRepository(database);

    customerId = await customerRepo.create(name: 'Budi');
  });

  tearDown(() async {
    await database.close();
  });

  group('DriftDebtRepository', () {
    test('createDebt adds debt with paid=0, status=unpaid', () async {
      await debtRepo.createDebt(customerId: customerId, amount: 50000);
      final debts = await debtRepo.getUnpaidByCustomer(customerId);

      expect(debts.length, 1);
      expect(debts.first.amount, 50000);
      expect(debts.first.paid, 0);
      expect(debts.first.status, DebtStatus.unpaid);
    });

    test('payDebt partly updates paid but status remains unpaid', () async {
      await debtRepo.createDebt(customerId: customerId, amount: 50000);
      final debt = (await debtRepo.getUnpaidByCustomer(customerId)).first;

      await debtRepo.payDebt(debtId: debt.id!, payment: 20000);
      
      final updatedDebt = (await debtRepo.getUnpaidByCustomer(customerId)).first;
      expect(updatedDebt.paid, 20000);
      expect(updatedDebt.status, DebtStatus.unpaid);
    });

    test('payDebt fully updates status to paid', () async {
      await debtRepo.createDebt(customerId: customerId, amount: 50000);
      final debt = (await debtRepo.getUnpaidByCustomer(customerId)).first;

      await debtRepo.payDebt(debtId: debt.id!, payment: 50000);
      
      final unpaid = await debtRepo.getUnpaidByCustomer(customerId);
      expect(unpaid.isEmpty, true);
    });

    test('payDebt exceeds amount throws ArgumentError', () async {
      await debtRepo.createDebt(customerId: customerId, amount: 50000);
      final debt = (await debtRepo.getUnpaidByCustomer(customerId)).first;

      expect(
        () => debtRepo.payDebt(debtId: debt.id!, payment: 60000),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('payDebt negative amount throws ArgumentError', () async {
      await debtRepo.createDebt(customerId: customerId, amount: 50000);
      final debt = (await debtRepo.getUnpaidByCustomer(customerId)).first;

      expect(
        () => debtRepo.payDebt(debtId: debt.id!, payment: -10000),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('payDebt unknown debt throws StateError', () async {
      expect(
        () => debtRepo.payDebt(debtId: 999, payment: 10000),
        throwsA(isA<StateError>()),
      );
    });

    test('payDebt dengan tenantId berbeda -> throws StateError', () async {
      await debtRepo.createDebt(customerId: customerId, amount: 50000, tenantId: 'tenant-1');
      final debt = (await debtRepo.getUnpaidByCustomer(customerId)).first;

      expect(
        () => debtRepo.payDebt(debtId: debt.id!, payment: 10000, tenantId: 'tenant-2'),
        throwsA(isA<StateError>()),
      );
    });

    test('delete debt dari tenant berbeda -> tidak menghapus', () async {
      await debtRepo.createDebt(customerId: customerId, amount: 50000, tenantId: 'tenant-1');
      final debt = (await debtRepo.getUnpaidByCustomer(customerId)).first;

      await debtRepo.delete(debt.id!, tenantId: 'tenant-2');
      
      final unpaid = await debtRepo.getUnpaidByCustomer(customerId, tenantId: 'tenant-1');
      expect(unpaid.isNotEmpty, true);
    });
  });
}
