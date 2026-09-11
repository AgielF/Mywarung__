import '../../sales/entities/transaction.dart';

class PaymentMethodBreakdown {
  final PaymentMethod method;
  final int transactionCount;
  final double totalAmount;

  const PaymentMethodBreakdown({
    required this.method,
    required this.transactionCount,
    required this.totalAmount,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PaymentMethodBreakdown &&
        other.method == method &&
        other.transactionCount == transactionCount &&
        other.totalAmount == totalAmount;
  }

  @override
  int get hashCode => method.hashCode ^ transactionCount.hashCode ^ totalAmount.hashCode;

  @override
  String toString() => 'PaymentMethodBreakdown(method: $method, count: $transactionCount, amount: $totalAmount)';
}

class DailyReport {
  final DateTime date;
  final double totalSales;
  final int transactionCount;
  final List<PaymentMethodBreakdown> breakdown;
  final List<Transaction> transactions;

  const DailyReport({
    required this.date,
    required this.totalSales,
    required this.transactionCount,
    required this.breakdown,
    required this.transactions,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! DailyReport) return false;
    
    if (date != other.date ||
        totalSales != other.totalSales ||
        transactionCount != other.transactionCount ||
        breakdown.length != other.breakdown.length ||
        transactions.length != other.transactions.length) {
      return false;
    }

    for (int i = 0; i < breakdown.length; i++) {
      if (breakdown[i] != other.breakdown[i]) return false;
    }
    
    for (int i = 0; i < transactions.length; i++) {
      if (transactions[i] != other.transactions[i]) return false;
    }

    return true;
  }

  @override
  int get hashCode =>
      date.hashCode ^
      totalSales.hashCode ^
      transactionCount.hashCode ^
      breakdown.hashCode ^
      transactions.hashCode;

  @override
  String toString() {
    return 'DailyReport(date: $date, sales: $totalSales, count: $transactionCount)';
  }
}
