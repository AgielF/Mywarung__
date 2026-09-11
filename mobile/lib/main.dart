import 'package:flutter/material.dart';
import 'infrastructure/database/app_database.dart';
import 'infrastructure/repositories/drift_product_repository.dart';
import 'infrastructure/repositories/drift_transaction_repository.dart';
import 'infrastructure/repositories/drift_customer_repository.dart';
import 'infrastructure/repositories/drift_debt_repository.dart';
import 'domain/inventory/repositories/product_repository.dart';
import 'domain/sales/repositories/transaction_repository.dart';
import 'domain/customer/repositories/customer_repository.dart';
import 'domain/customer/repositories/debt_repository.dart';
import 'domain/reporting/repositories/reporting_repository.dart';
import 'domain/reporting/repositories/debt_outstanding_repository.dart';
import 'infrastructure/repositories/drift_reporting_repository.dart';
import 'infrastructure/repositories/drift_debt_outstanding_repository.dart';
import 'ui/home/home_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  
  final db = AppDatabase();
  final productRepository = DriftProductRepository(db);
  final transactionRepository = DriftTransactionRepository(db);
  final customerRepository = DriftCustomerRepository(db);
  final debtRepository = DriftDebtRepository(db);
  final reportingRepository = DriftReportingRepository(db);
  final debtOutstandingRepository = DriftDebtOutstandingRepository(db);

  runApp(POSWarungAIApp(
    productRepository: productRepository,
    transactionRepository: transactionRepository,
    customerRepository: customerRepository,
    debtRepository: debtRepository,
    reportingRepository: reportingRepository,
    debtOutstandingRepository: debtOutstandingRepository,
  ));
}

class POSWarungAIApp extends StatelessWidget {
  final ProductRepository productRepository;
  final TransactionRepository transactionRepository;
  final CustomerRepository customerRepository;
  final DebtRepository debtRepository;
  final ReportingRepository reportingRepository;
  final DebtOutstandingRepository debtOutstandingRepository;

  const POSWarungAIApp({
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
    return MaterialApp(
      title: 'MyWarung',
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.green,
      ),
      home: HomeScreen(
        productRepository: productRepository,
        transactionRepository: transactionRepository,
        customerRepository: customerRepository,
        debtRepository: debtRepository,
        reportingRepository: reportingRepository,
        debtOutstandingRepository: debtOutstandingRepository,
      ),
      debugShowCheckedModeBanner: false,
    );
  }
}
