import 'package:flutter/foundation.dart';

@immutable
class SalesTrendPoint {
  final DateTime date;
  final double totalSales;
  final int transactionCount;

  const SalesTrendPoint({
    required this.date,
    required this.totalSales,
    required this.transactionCount,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
  
    return other is SalesTrendPoint &&
      other.date == date &&
      other.totalSales == totalSales &&
      other.transactionCount == transactionCount;
  }

  @override
  int get hashCode => date.hashCode ^ totalSales.hashCode ^ transactionCount.hashCode;

  @override
  String toString() => 'SalesTrendPoint(date: $date, totalSales: $totalSales, transactionCount: $transactionCount)';
}
