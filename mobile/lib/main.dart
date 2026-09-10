import 'package:flutter/material.dart';
import 'infrastructure/database/app_database.dart';
import 'infrastructure/repositories/drift_product_repository.dart';
import 'domain/inventory/repositories/product_repository.dart';
import 'ui/home/home_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  
  final db = AppDatabase();
  final productRepository = DriftProductRepository(db);

  runApp(POSWarungAIApp(productRepository: productRepository));
}

class POSWarungAIApp extends StatelessWidget {
  final ProductRepository productRepository;

  const POSWarungAIApp({super.key, required this.productRepository});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'POS Warung AI',
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.green,
      ),
      home: HomeScreen(productRepository: productRepository),
      debugShowCheckedModeBanner: false,
    );
  }
}
