import '../../domain/customer/entities/customer.dart' as customer_domain;
import '../../domain/reporting/entities/customer_debt_summary.dart';
import '../../domain/reporting/entities/debt_outstanding_report.dart';
import '../../domain/reporting/repositories/debt_outstanding_repository.dart';
import '../database/app_database.dart';

class DriftDebtOutstandingRepository implements DebtOutstandingRepository {
  final AppDatabase _db;

  DriftDebtOutstandingRepository(this._db);

  @override
  Future<DebtOutstandingReport> getOutstandingReport({String tenantId = 'tenant-1'}) async {
    // 1. Ambil semua debts yang belum lunas
    final debtsQuery = _db.select(_db.debts)
      ..where((tbl) => tbl.tenantId.equals(tenantId))
      ..where((tbl) => tbl.status.equals('unpaid'));
    
    final debts = await debtsQuery.get();

    if (debts.isEmpty) {
      return const DebtOutstandingReport(
        totalOutstanding: 0,
        customerCount: 0,
        debtCount: 0,
        summaries: [],
      );
    }

    // 2. Kumpulkan customerId unik
    final Set<int> customerIds = {};
    for (final debt in debts) {
      customerIds.add(debt.customerId);
    }

    // 3. Ambil semua customers yang terkait dengan batch query
    final customersQuery = _db.select(_db.customers)
      ..where((tbl) => tbl.tenantId.equals(tenantId))
      ..where((tbl) => tbl.id.isIn(customerIds));
      
    final customersResult = await customersQuery.get();
    
    // Map customer data
    final Map<int, customer_domain.Customer> customerMap = {};
    for (final row in customersResult) {
      customerMap[row.id] = customer_domain.Customer(
        id: row.id,
        tenantId: row.tenantId,
        name: row.name,
        phone: row.phone,
        createdAt: row.createdAt,
      );
    }

    // 4. Kelompokkan debts by customer dan hitung agregasi
    double totalOutstandingAll = 0;
    int totalDebtCount = 0;

    final Map<int, List<Debt>> debtsByCustomer = {};
    for (final debt in debts) {
      if (!debtsByCustomer.containsKey(debt.customerId)) {
        debtsByCustomer[debt.customerId] = [];
      }
      debtsByCustomer[debt.customerId]!.add(debt);
    }

    final List<CustomerDebtSummary> summaries = [];

    for (final customerId in debtsByCustomer.keys) {
      final customer = customerMap[customerId];
      if (customer == null) continue; // Safety check in case customer is deleted but debt exists

      final customerDebts = debtsByCustomer[customerId]!;
      
      double customerTotalDebt = 0;
      double customerTotalPaid = 0;
      double customerRemaining = 0;
      int customerUnpaidCount = 0;

      for (final debt in customerDebts) {
        final remaining = debt.amount - debt.paid;
        customerTotalDebt += debt.amount;
        customerTotalPaid += debt.paid;
        customerRemaining += remaining;
        customerUnpaidCount++;
        
        totalOutstandingAll += remaining;
        totalDebtCount++;
      }

      summaries.add(CustomerDebtSummary(
        customer: customer,
        totalDebt: customerTotalDebt,
        totalPaid: customerTotalPaid,
        remaining: customerRemaining,
        unpaidCount: customerUnpaidCount,
      ));
    }

    // Urutkan desc by remaining
    summaries.sort((a, b) => b.remaining.compareTo(a.remaining));

    return DebtOutstandingReport(
      totalOutstanding: totalOutstandingAll,
      customerCount: summaries.length,
      debtCount: totalDebtCount,
      summaries: summaries,
    );
  }
}
