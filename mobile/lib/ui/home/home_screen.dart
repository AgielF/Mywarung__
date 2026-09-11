import 'package:flutter/material.dart';
import '../../domain/inventory/repositories/product_repository.dart';
import '../../domain/sales/repositories/transaction_repository.dart';
import '../../domain/customer/repositories/customer_repository.dart';
import '../../domain/customer/repositories/debt_repository.dart';
import '../inventory/inventory_list_screen.dart';
import '../sales/sales_screen.dart';
import '../customer/customer_list_screen.dart';
import '../reporting/reporting_screen.dart';
import '../../domain/reporting/repositories/reporting_repository.dart';
import '../reporting/debt_outstanding_screen.dart';
import '../../domain/reporting/repositories/debt_outstanding_repository.dart';

class HomeScreen extends StatelessWidget {
  final ProductRepository productRepository;
  final TransactionRepository transactionRepository;
  final CustomerRepository customerRepository;
  final DebtRepository debtRepository;
  final ReportingRepository reportingRepository;
  final DebtOutstandingRepository debtOutstandingRepository;

  const HomeScreen({
    super.key,
    required this.productRepository,
    required this.transactionRepository,
    required this.customerRepository,
    required this.debtRepository,
    required this.reportingRepository,
    required this.debtOutstandingRepository,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('POS Warung AI'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.storefront,
              size: 80,
              color: Colors.green,
            ),
            const SizedBox(height: 16),
            Text(
              'POS Warung AI',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Offline-First POS untuk Warung Indonesia',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            Wrap(
              spacing: 16,
              runSpacing: 16,
              alignment: WrapAlignment.center,
              children: [
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => InventoryListScreen(
                          repository: productRepository,
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.inventory_2),
                  label: const Text('Produk'),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SalesScreen(
                          productRepository: productRepository,
                          transactionRepository: transactionRepository,
                          customerRepository: customerRepository,
                          debtRepository: debtRepository,
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.receipt_long),
                  label: const Text('Transaksi'),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CustomerListScreen(
                          customerRepository: customerRepository,
                          debtRepository: debtRepository,
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.people),
                  label: const Text('Customer'),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ReportingScreen(
                          reportingRepository: reportingRepository,
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.bar_chart),
                  label: const Text('Laporan', textAlign: TextAlign.center),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DebtOutstandingScreen(
                          debtOutstandingRepository: debtOutstandingRepository,
                          debtRepository: debtRepository,
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.account_balance_wallet),
                  label: const Text('Piutang'),
                ),
              ],
            ),
            const SizedBox(height: 32),
            Text(
              'Versi 0.1.0 — Fase 1 MVP',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
