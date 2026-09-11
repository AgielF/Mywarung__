import 'customer_debt_summary.dart';

class DebtOutstandingReport {
  final double totalOutstanding;
  final int customerCount;
  final int debtCount;
  final List<CustomerDebtSummary> summaries;

  const DebtOutstandingReport({
    required this.totalOutstanding,
    required this.customerCount,
    required this.debtCount,
    required this.summaries,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
  
    if (other is! DebtOutstandingReport) return false;
    
    if (other.totalOutstanding != totalOutstanding ||
        other.customerCount != customerCount ||
        other.debtCount != debtCount ||
        other.summaries.length != summaries.length) {
      return false;
    }
    
    for (int i = 0; i < summaries.length; i++) {
      if (other.summaries[i] != summaries[i]) return false;
    }
    return true;
  }

  @override
  int get hashCode => 
      totalOutstanding.hashCode ^ 
      customerCount.hashCode ^ 
      debtCount.hashCode ^ 
      summaries.hashCode;

  @override
  String toString() {
    return 'DebtOutstandingReport(totalOutstanding: $totalOutstanding, customerCount: $customerCount, debtCount: $debtCount, summaries: $summaries)';
  }
}
