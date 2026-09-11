import 'package:drift/drift.dart';
import '../../domain/reporting/entities/daily_report.dart';
import '../../domain/reporting/entities/sales_trend_point.dart';
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

  @override
  Future<List<SalesTrendPoint>> getSalesTrend({int days = 7, String tenantId = 'tenant-1'}) async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final start = today.subtract(Duration(days: days - 1));

    final List<SalesTrendPoint> trend = [];
    DateTime current = start;

    while (!current.isAfter(today)) {
      final report = await getDailyReport(current, tenantId: tenantId);
      trend.add(SalesTrendPoint(
        date: current,
        totalSales: report.totalSales,
        transactionCount: report.transactionCount,
      ));
      current = current.add(const Duration(days: 1));
    }

    return trend;
  }

  Future<List<sales_domain.Transaction>> _getTransactions(DateTime start, DateTime end, String tenantId) async {
    var query = _db.select(_db.transactions)
      ..where((tbl) => tbl.tenantId.equals(tenantId))
      ..where((tbl) => tbl.createdAt.isBetweenValues(
          start.millisecondsSinceEpoch, end.millisecondsSinceEpoch))
      ..orderBy([(tbl) => OrderingTerm(expression: tbl.createdAt, mode: OrderingMode.desc)]);

    final transactionsData = await query.get();
    if (transactionsData.isEmpty) return [];

    final transactionIds = transactionsData.map((t) => t.id).toList();

    final itemsData = await (_db.select(_db.transactionItems)
      ..where((tbl) => tbl.transactionId.isIn(transactionIds))).get();

    final itemsByTransaction = <int, List<drift.TransactionItem>>{};
    final productIds = <int>{};
    for (final item in itemsData) {
      itemsByTransaction.putIfAbsent(item.transactionId, () => []).add(item);
      productIds.add(item.productId);
    }

    final productNames = <int, String>{};
    if (productIds.isNotEmpty) {
      final productsData = await (_db.select(_db.products)
        ..where((tbl) => tbl.tenantId.equals(tenantId))
        ..where((tbl) => tbl.id.isIn(productIds))).get();
      for (final p in productsData) {
        productNames[p.id] = p.name;
      }
    }
    
    List<sales_domain.Transaction> transactions = [];
    for (final tData in transactionsData) {
      final tItemsData = itemsByTransaction[tData.id] ?? [];
      
      List<sales_domain.TransactionItem> domainItems = [];
      for (final itemData in tItemsData) {
        final productName = productNames[itemData.productId] ?? 'Unknown';
          
        domainItems.add(sales_domain.TransactionItem(
          id: itemData.id,
          productId: itemData.productId,
          productName: productName,
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
