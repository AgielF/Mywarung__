import 'package:flutter_test/flutter_test.dart';
import 'package:pos_warung_ai/infrastructure/database/app_database.dart';
import 'package:pos_warung_ai/infrastructure/repositories/drift_customer_repository.dart';
import 'package:pos_warung_ai/infrastructure/repositories/drift_debt_repository.dart';

void main() {
  late AppDatabase database;
  late DriftCustomerRepository customerRepo;
  late DriftDebtRepository debtRepo;

  setUp(() {
    database = AppDatabase.memory();
    customerRepo = DriftCustomerRepository(database);
    debtRepo = DriftDebtRepository(database);
  });

  tearDown(() async {
    await database.close();
  });

  group('DriftCustomerRepository', () {
    test('create adds a new customer', () async {
      final id = await customerRepo.create(name: 'Budi', phone: '08123456789');
      final customer = await customerRepo.getById(id);

      expect(customer, isNotNull);
      expect(customer!.name, 'Budi');
      expect(customer.phone, '08123456789');
    });

    test('getAll returns all customers', () async {
      await customerRepo.create(name: 'Budi');
      await customerRepo.create(name: 'Ani');

      final customers = await customerRepo.getAll();
      expect(customers.length, 2);
    });

    test('update modifies existing customer', () async {
      final id = await customerRepo.create(name: 'Budi');
      var customer = (await customerRepo.getById(id))!;

      customer = customer.copyWith(name: 'Budi Santoso');
      await customerRepo.update(customer);

      final updated = await customerRepo.getById(id);
      expect(updated!.name, 'Budi Santoso');
    });

    test('delete removes customer if no unpaid debt', () async {
      final id = await customerRepo.create(name: 'Budi');
      
      // Kasbon lalu lunas
      await debtRepo.createDebt(customerId: id, amount: 50000);
      final debts = await debtRepo.getUnpaidByCustomer(id);
      await debtRepo.payDebt(debtId: debts.first.id!, payment: 50000);

      await customerRepo.delete(id);
      final customer = await customerRepo.getById(id);
      expect(customer, isNull);
    });

    test('delete throws StateError if customer has unpaid debt', () async {
      final id = await customerRepo.create(name: 'Budi');
      
      await debtRepo.createDebt(customerId: id, amount: 50000);

      expect(
        () => customerRepo.delete(id),
        throwsA(isA<StateError>()),
      );
    });

    test('getById dengan tenantId berbeda -> return null', () async {
      final id = await customerRepo.create(name: 'Budi', tenantId: 'tenant-1');
      
      final customer = await customerRepo.getById(id, tenantId: 'tenant-2');
      expect(customer, isNull);
    });

    test('delete customer dari tenant berbeda -> tidak menghapus', () async {
      final id = await customerRepo.create(name: 'Budi', tenantId: 'tenant-1');
      
      await customerRepo.delete(id, tenantId: 'tenant-2');
      
      final customer = await customerRepo.getById(id, tenantId: 'tenant-1');
      expect(customer, isNotNull);
    });
  });
}
