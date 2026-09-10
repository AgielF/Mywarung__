import 'package:flutter/material.dart';
import 'infrastructure/database/app_database.dart';
import 'infrastructure/repositories/drift_product_repository.dart';
import 'infrastructure/repositories/drift_transaction_repository.dart';
import 'domain/inventory/repositories/product_repository.dart';
import 'domain/sales/repositories/transaction_repository.dart';
import 'ui/home/home_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  
  final db = AppDatabase();
  final productRepository = DriftProductRepository(db);
  final transactionRepository = DriftTransactionRepository(db);

  runApp(POSWarungAIApp(
    productRepository: productRepository,
    transactionRepository: transactionRepository,
  ));
}

class POSWarungAIApp extends StatelessWidget {
  final ProductRepository productRepository;
  final TransactionRepository transactionRepository;

  const POSWarungAIApp({
    super.key,
    required this.productRepository,
    required this.transactionRepository,
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
      ),
      debugShowCheckedModeBanner: false,
    );
  }
}
