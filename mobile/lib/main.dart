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
import 'ui/home/home_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  
  final db = AppDatabase();
  final productRepository = DriftProductRepository(db);
  final transactionRepository = DriftTransactionRepository(db);
  final customerRepository = DriftCustomerRepository(db);
  final debtRepository = DriftDebtRepository(db);

  runApp(POSWarungAIApp(
    productRepository: productRepository,
    transactionRepository: transactionRepository,
    customerRepository: customerRepository,
    debtRepository: debtRepository,
  ));
}

class POSWarungAIApp extends StatelessWidget {
  final ProductRepository productRepository;
  final TransactionRepository transactionRepository;
  final CustomerRepository customerRepository;
  final DebtRepository debtRepository;

  const POSWarungAIApp({
    super.key,
    required this.productRepository,
    required this.transactionRepository,
    required this.customerRepository,
    required this.debtRepository,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'POS Warung AI',
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.green,
      ),
      home: HomeScreen(
        productRepository: productRepository,
        transactionRepository: transactionRepository,
        customerRepository: customerRepository,
        debtRepository: debtRepository,
      ),
      debugShowCheckedModeBanner: false,
    );
  }
}
