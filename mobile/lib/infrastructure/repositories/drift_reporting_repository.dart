import 'package:drift/drift.dart';
import '../../domain/reporting/entities/daily_report.dart';
import '../../domain/reporting/repositories/reporting_repository.dart';
import '../../domain/sales/entities/transaction.dart' as sales_domain;
import '../../domain/sales/entities/transaction_item.dart' as sales_domain;
import '../database/app_database.dart' as drift;

class DriftReportingRepository implements ReportingRepository {
  final drift.AppDatabase _db;

  DriftReportingRepository(this._db);

  @override
  Future<DailyReport> getDailyReport(DateTime date, {String tenantId = 'tenant-1'}) async {
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59, 999);

    final transactions = await _getTransactions(startOfDay, endOfDay, tenantId);
    return _aggregate(startOfDay, transactions);
  }

  @override
  Stream<DailyReport> watchDailyReport(DateTime date, {String tenantId = 'tenant-1'}) {
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59, 999);

    var query = _db.select(_db.transactions)
      ..where((tbl) => tbl.tenantId.equals(tenantId))
      ..where((tbl) => tbl.createdAt.isBetweenValues(
          startOfDay.millisecondsSinceEpoch, endOfDay.millisecondsSinceEpoch));
          
    return query.watch().asyncMap((_) async {
      final transactions = await _getTransactions(startOfDay, endOfDay, tenantId);
      return _aggregate(startOfDay, transactions);
    });
  }

  @override
  Future<List<DailyReport>> getRangeReport(DateTime from, DateTime to, {String tenantId = 'tenant-1'}) async {
    List<DailyReport> reports = [];
    DateTime current = DateTime(from.year, from.month, from.day);
    final end = DateTime(to.year, to.month, to.day);
    
    while (!current.isAfter(end)) {
      reports.add(await getDailyReport(current, tenantId: tenantId));
      current = current.add(const Duration(days: 1));
    }
    
    return reports;
  }

  Future<List<sales_domain.Transaction>> _getTransactions(DateTime start, DateTime end, String tenantId) async {
    var query = _db.select(_db.transactions)
      ..where((tbl) => tbl.tenantId.equals(tenantId))
      ..where((tbl) => tbl.createdAt.isBetweenValues(
          start.millisecondsSinceEpoch, end.millisecondsSinceEpoch))
      ..orderBy([(tbl) => OrderingTerm(expression: tbl.createdAt, mode: OrderingMode.desc)]);

    final transactionsData = await query.get();
    
    List<sales_domain.Transaction> transactions = [];
    for (final tData in transactionsData) {
      final itemsData = await (_db.select(_db.transactionItems)
        ..where((tbl) => tbl.transactionId.equals(tData.id))).get();
      
      List<sales_domain.TransactionItem> domainItems = [];
      for (final itemData in itemsData) {
        final product = await (_db.select(_db.products)
          ..where((tbl) => tbl.tenantId.equals(tenantId))
          ..where((tbl) => tbl.id.equals(itemData.productId))).getSingleOrNull();
          
        domainItems.add(sales_domain.TransactionItem(
          id: itemData.id,
          productId: itemData.productId,
          productName: product?.name ?? 'Unknown',
          quantity: itemData.quantity,
          price: itemData.price,
          subtotal: itemData.subtotal,
        ));
      }
      transactions.add(tData.toReportingDomain(domainItems));
    }
    return transactions;
  }

  DailyReport _aggregate(DateTime date, List<sales_domain.Transaction> transactions) {
    double totalSales = 0;
    int transactionCount = transactions.length;
    
    Map<sales_domain.PaymentMethod, int> counts = {
      sales_domain.PaymentMethod.cash: 0,
      sales_domain.PaymentMethod.qris: 0,
      sales_domain.PaymentMethod.debt: 0,
    };
    Map<sales_domain.PaymentMethod, double> amounts = {
      sales_domain.PaymentMethod.cash: 0.0,
      sales_domain.PaymentMethod.qris: 0.0,
      sales_domain.PaymentMethod.debt: 0.0,
    };

    for (final t in transactions) {
      totalSales += t.total;
      counts[t.paymentMethod] = counts[t.paymentMethod]! + 1;
      amounts[t.paymentMethod] = amounts[t.paymentMethod]! + t.total;
    }

    List<PaymentMethodBreakdown> breakdown = [
      PaymentMethodBreakdown(
        method: sales_domain.PaymentMethod.cash,
        transactionCount: counts[sales_domain.PaymentMethod.cash]!,
        totalAmount: amounts[sales_domain.PaymentMethod.cash]!,
      ),
      PaymentMethodBreakdown(
        method: sales_domain.PaymentMethod.qris,
        transactionCount: counts[sales_domain.PaymentMethod.qris]!,
        totalAmount: amounts[sales_domain.PaymentMethod.qris]!,
      ),
      PaymentMethodBreakdown(
        method: sales_domain.PaymentMethod.debt,
        transactionCount: counts[sales_domain.PaymentMethod.debt]!,
        totalAmount: amounts[sales_domain.PaymentMethod.debt]!,
      ),
    ];

    return DailyReport(
      date: date,
      totalSales: totalSales,
      transactionCount: transactionCount,
      breakdown: breakdown,
      transactions: transactions,
    );
  }
}

extension ReportingTransactionDataMapper on drift.Transaction {
  sales_domain.Transaction toReportingDomain(List<sales_domain.TransactionItem> items) {
    sales_domain.PaymentMethod mappedPaymentMethod;
    try {
      mappedPaymentMethod = sales_domain.PaymentMethod.values.firstWhere((e) => e.name == paymentMethod);
    } catch (_) {
      mappedPaymentMethod = sales_domain.PaymentMethod.cash;
    }

    return sales_domain.Transaction(
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
