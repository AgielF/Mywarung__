import 'package:flutter_test/flutter_test.dart';
import 'package:pos_warung_ai/domain/inventory/entities/product.dart';
import 'package:pos_warung_ai/domain/sales/entities/transaction.dart' as domain;
import 'package:pos_warung_ai/domain/sales/entities/transaction_item.dart' as domain;
import 'package:pos_warung_ai/infrastructure/database/app_database.dart' hide Product;
import 'package:pos_warung_ai/infrastructure/repositories/drift_product_repository.dart';
import 'package:pos_warung_ai/infrastructure/repositories/drift_transaction_repository.dart';

void main() {
  late AppDatabase database;
  late DriftProductRepository productRepo;
  late DriftTransactionRepository transactionRepo;

  setUp(() {
    database = AppDatabase.memory();
    productRepo = DriftProductRepository(database);
    transactionRepo = DriftTransactionRepository(database);
  });

  tearDown(() async {
    await database.close();
  });

  Future<int> seedProduct(int stock) async {
    return await productRepo.create(Product(
      tenantId: 'tenant-1',
      name: 'Test Product',
      price: 1000,
      stock: stock,
      createdAt: DateTime.now(),
    ));
  }

  test('create transaction -> stok produk berkurang', () async {
    final productId = await seedProduct(10);

    final transaction = domain.Transaction(
      tenantId: 'tenant-1',
      total: 2000,
      paymentMethod: domain.PaymentMethod.cash,
      createdAt: DateTime.now(),
      items: [
        domain.TransactionItem(
          productId: productId,
          productName: 'Test Product',
          quantity: 2,
          price: 1000,
          subtotal: 2000,
        ),
      ],
    );

    final txId = await transactionRepo.create(transaction);
    expect(txId, isNotNull);

    final updatedProduct = await productRepo.getById(productId);
    expect(updatedProduct!.stock, 8); // 10 - 2
  });

  test('create dengan stok tidak cukup -> throw, stok tidak berubah (rollback)', () async {
    final productId = await seedProduct(5);

    final transaction = domain.Transaction(
      tenantId: 'tenant-1',
      total: 6000,
      paymentMethod: domain.PaymentMethod.cash,
      createdAt: DateTime.now(),
      items: [
        domain.TransactionItem(
          productId: productId,
          productName: 'Test Product',
          quantity: 6, // Requested more than stock
          price: 1000,
          subtotal: 6000,
        ),
      ],
    );

    expect(
      () => transactionRepo.create(transaction),
      throwsException,
    );

    final product = await productRepo.getById(productId);
    expect(product!.stock, 5); // Unchanged

    final transactions = await transactionRepo.getAll();
    expect(transactions, isEmpty);
  });

  test('getById returns transaction dengan items lengkap', () async {
    final productId = await seedProduct(10);

    final transaction = domain.Transaction(
      tenantId: 'tenant-1',
      total: 2000,
      paymentMethod: domain.PaymentMethod.qris,
      createdAt: DateTime.now(),
      items: [
        domain.TransactionItem(
          productId: productId,
          productName: 'Test Product',
          quantity: 2,
          price: 1000,
          subtotal: 2000,
        ),
      ],
    );

    final txId = await transactionRepo.create(transaction);

    final fetchedTx = await transactionRepo.getById(txId);
    expect(fetchedTx, isNotNull);
    expect(fetchedTx!.total, 2000);
    expect(fetchedTx.paymentMethod, domain.PaymentMethod.qris);
    expect(fetchedTx.items.length, 1);
    expect(fetchedTx.items.first.quantity, 2);
  });

  test('getAll filter by date', () async {
    final productId = await seedProduct(10);

    final txId = await transactionRepo.create(domain.Transaction(
      tenantId: 'tenant-1',
      total: 1000,
      paymentMethod: domain.PaymentMethod.cash,
      createdAt: DateTime.now(),
      items: [
        domain.TransactionItem(
          productId: productId,
          productName: 'P1',
          quantity: 1,
          price: 1000,
          subtotal: 1000,
        ),
      ],
    ));

    final now = DateTime.now();
    final fromDate = now.subtract(const Duration(minutes: 5));
    final toDate = now.add(const Duration(minutes: 5));

    final txs = await transactionRepo.getAll(from: fromDate, to: toDate);
    expect(txs.length, 1);
    expect(txs.first.id, txId);

    final futureTxs = await transactionRepo.getAll(from: now.add(const Duration(days: 1)));
    expect(futureTxs, isEmpty);
  });

  test('watchAll stream emits saat create', () async {
    final productId = await seedProduct(10);

    final stream = transactionRepo.watchAll();

    final expectation = expectLater(
      stream,
      emitsInOrder([
        [],
        isA<List<domain.Transaction>>().having((list) => list.length, 'length', 1),
      ]),
    );

    await Future.delayed(Duration.zero);

    await transactionRepo.create(domain.Transaction(
      tenantId: 'tenant-1',
      total: 1000,
      paymentMethod: domain.PaymentMethod.cash,
      createdAt: DateTime.now(),
      items: [
        domain.TransactionItem(
          productId: productId,
          productName: 'P1',
          quantity: 1,
          price: 1000,
          subtotal: 1000,
        ),
      ],
    ));

    await expectation;
  });
}
