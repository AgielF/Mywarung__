import 'package:flutter/material.dart';
import '../../domain/inventory/repositories/product_repository.dart';
import '../inventory/inventory_list_screen.dart';

class HomeScreen extends StatelessWidget {
  final ProductRepository productRepository;

  const HomeScreen({super.key, required this.productRepository});

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
                  onPressed: null,
                  icon: const Icon(Icons.receipt_long),
                  label: const Text('Transaksi\n(Segera hadir)', textAlign: TextAlign.center),
                ),
                ElevatedButton.icon(
                  onPressed: null,
                  icon: const Icon(Icons.account_balance_wallet),
                  label: const Text('Kasbon\n(Segera hadir)', textAlign: TextAlign.center),
                ),
                ElevatedButton.icon(
                  onPressed: null,
                  icon: const Icon(Icons.bar_chart),
                  label: const Text('Laporan\n(Segera hadir)', textAlign: TextAlign.center),
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
