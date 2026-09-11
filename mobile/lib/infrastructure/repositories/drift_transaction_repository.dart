import 'package:drift/drift.dart';
import '../../domain/sales/entities/transaction.dart' as domain;
import '../../domain/sales/entities/transaction_item.dart' as domain;
import '../../domain/sales/repositories/transaction_repository.dart';
import '../database/app_database.dart' as drift;

class DriftTransactionRepository implements TransactionRepository {
  final drift.AppDatabase _db;

  DriftTransactionRepository(this._db);

  @override
  Future<int> create(domain.Transaction transaction) async {
    return await _db.transaction(() async {
      final transactionCompanion = drift.TransactionsCompanion.insert(
        tenantId: transaction.tenantId,
        total: transaction.total,
        paymentMethod: transaction.paymentMethod.name,
        customerId: transaction.customerId == null ? const Value.absent() : Value(transaction.customerId!),
        createdAt: DateTime.now(),
        isSynced: const Value(false),
      );

      final transactionId = await _db.into(_db.transactions).insert(transactionCompanion);

      for (final item in transaction.items) {
        final productQuery = _db.select(_db.products)..where((tbl) => tbl.id.equals(item.productId));
        final product = await productQuery.getSingleOrNull();

        if (product == null) {
          throw Exception('Produk dengan ID ${item.productId} tidak ditemukan.');
        }

        if (product.stock < item.quantity) {
          throw Exception('Stok tidak cukup untuk produk ${product.name}. Tersisa: ${product.stock}, Diminta: ${item.quantity}.');
        }

        final newStock = product.stock - item.quantity;
        await (_db.update(_db.products)..where((tbl) => tbl.id.equals(product.id)))
            .write(drift.ProductsCompanion(stock: Value(newStock), updatedAt: Value(DateTime.now())));

        final itemCompanion = drift.TransactionItemsCompanion.insert(
          transactionId: transactionId,
          productId: item.productId,
          quantity: item.quantity,
          price: item.price,
          subtotal: item.subtotal,
        );
        await _db.into(_db.transactionItems).insert(itemCompanion);
      }

      if (transaction.paymentMethod == domain.PaymentMethod.debt) {
        if (transaction.customerId == null) {
          throw Exception('Customer wajib dipilih untuk pembayaran kasbon.');
        }
        await _db.into(_db.debts).insert(drift.DebtsCompanion.insert(
          tenantId: transaction.tenantId,
          customerId: transaction.customerId!,
          amount: transaction.total,
          paid: const Value(0),
          status: 'unpaid',
          createdAt: DateTime.now(),
        ));
      }

      return transactionId;
    });
  }

  @override
  Future<domain.Transaction?> getById(int id) async {
    final transactionQuery = _db.select(_db.transactions)..where((tbl) => tbl.id.equals(id));
    final transactionData = await transactionQuery.getSingleOrNull();

    if (transactionData == null) return null;

    final itemsQuery = _db.select(_db.transactionItems)..where((tbl) => tbl.transactionId.equals(id));
    final itemsData = await itemsQuery.get();

    List<domain.TransactionItem> domainItems = [];
    for(final itemData in itemsData) {
      final product = await (_db.select(_db.products)..where((tbl) => tbl.id.equals(itemData.productId))).getSingleOrNull();
      domainItems.add(domain.TransactionItem(
        id: itemData.id,
        productId: itemData.productId,
        productName: product?.name ?? 'Unknown',
        quantity: itemData.quantity,
        price: itemData.price,
        subtotal: itemData.subtotal,
      ));
    }

    return transactionData.toDomain(domainItems);
  }

  @override
  Future<List<domain.Transaction>> getAll({DateTime? from, DateTime? to}) async {
    var query = _db.select(_db.transactions);
    
    if (from != null) {
      query = query..where((tbl) => tbl.createdAt.isBiggerOrEqualValue(from.millisecondsSinceEpoch));
    }
    if (to != null) {
      query = query..where((tbl) => tbl.createdAt.isSmallerOrEqualValue(to.millisecondsSinceEpoch));
    }

    query.orderBy([(tbl) => OrderingTerm(expression: tbl.createdAt, mode: OrderingMode.desc)]);

    final transactionsData = await query.get();
    
    List<domain.Transaction> transactions = [];
    for (final tData in transactionsData) {
      final itemsData = await (_db.select(_db.transactionItems)..where((tbl) => tbl.transactionId.equals(tData.id))).get();
      List<domain.TransactionItem> domainItems = [];
      for(final itemData in itemsData) {
        final product = await (_db.select(_db.products)..where((tbl) => tbl.id.equals(itemData.productId))).getSingleOrNull();
        domainItems.add(domain.TransactionItem(
          id: itemData.id,
          productId: itemData.productId,
          productName: product?.name ?? 'Unknown',
          quantity: itemData.quantity,
          price: itemData.price,
          subtotal: itemData.subtotal,
        ));
      }
      transactions.add(tData.toDomain(domainItems));
    }
    return transactions;
  }

  @override
  Stream<List<domain.Transaction>> watchAll({DateTime? from, DateTime? to}) {
    var query = _db.select(_db.transactions);
    
    if (from != null) {
      query = query..where((tbl) => tbl.createdAt.isBiggerOrEqualValue(from.millisecondsSinceEpoch));
    }
    if (to != null) {
      query = query..where((tbl) => tbl.createdAt.isSmallerOrEqualValue(to.millisecondsSinceEpoch));
    }

    query.orderBy([(tbl) => OrderingTerm(expression: tbl.createdAt, mode: OrderingMode.desc)]);

    return query.watch().asyncMap((transactionsData) async {
      List<domain.Transaction> transactions = [];
      for (final tData in transactionsData) {
        final itemsData = await (_db.select(_db.transactionItems)..where((tbl) => tbl.transactionId.equals(tData.id))).get();
        List<domain.TransactionItem> domainItems = [];
        for(final itemData in itemsData) {
          final product = await (_db.select(_db.products)..where((tbl) => tbl.id.equals(itemData.productId))).getSingleOrNull();
          domainItems.add(domain.TransactionItem(
            id: itemData.id,
            productId: itemData.productId,
            productName: product?.name ?? 'Unknown',
            quantity: itemData.quantity,
            price: itemData.price,
            subtotal: itemData.subtotal,
          ));
        }
        transactions.add(tData.toDomain(domainItems));
      }
      return transactions;
    });
  }
}

extension TransactionDataMapper on drift.Transaction {
  domain.Transaction toDomain(List<domain.TransactionItem> items) {
    domain.PaymentMethod mappedPaymentMethod;
    try {
      mappedPaymentMethod = domain.PaymentMethod.values.firstWhere((e) => e.name == paymentMethod);
    } catch (_) {
      mappedPaymentMethod = domain.PaymentMethod.cash;
    }

    return domain.Transaction(
      id: id,
      tenantId: tenantId,
      items: items,
      total: total,
      paymentMethod: mappedPaymentMethod,
      customerId: customerId,
      createdAt: createdAt,
      isSynced: isSynced,
    );
  }
}
