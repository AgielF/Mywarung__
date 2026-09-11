import '../../customer/entities/customer.dart';

class CustomerDebtSummary {
  final Customer customer;
  final double totalDebt;
  final double totalPaid;
  final double remaining;
  final int unpaidCount;

  const CustomerDebtSummary({
    required this.customer,
    required this.totalDebt,
    required this.totalPaid,
    required this.remaining,
    required this.unpaidCount,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
  
    return other is CustomerDebtSummary &&
      other.customer == customer &&
      other.totalDebt == totalDebt &&
      other.totalPaid == totalPaid &&
      other.remaining == remaining &&
      other.unpaidCount == unpaidCount;
  }

  @override
  int get hashCode => 
      customer.hashCode ^ 
      totalDebt.hashCode ^ 
      totalPaid.hashCode ^ 
      remaining.hashCode ^ 
      unpaidCount.hashCode;

  @override
  String toString() {
    return 'CustomerDebtSummary(customer: $customer, totalDebt: $totalDebt, totalPaid: $totalPaid, remaining: $remaining, unpaidCount: $unpaidCount)';
  }
}
