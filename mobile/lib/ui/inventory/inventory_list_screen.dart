import 'dart:async';
import 'package:flutter/material.dart';
import '../../domain/inventory/entities/product.dart';
import '../../domain/inventory/repositories/product_repository.dart';
import 'inventory_form_screen.dart';
import 'inventory_state.dart';

class InventoryListScreen extends StatefulWidget {
  final ProductRepository repository;

  const InventoryListScreen({super.key, required this.repository});

  @override
  State<InventoryListScreen> createState() => _InventoryListScreenState();
}

class _InventoryListScreenState extends State<InventoryListScreen> {
  final _messengerKey = GlobalKey<ScaffoldMessengerState>();
  InventoryState _state = const InventoryState(isLoading: true);
  StreamSubscription<List<Product>>? _subscription;
  bool _showLowStockOnly = false;

  @override
  void initState() {
    super.initState();
    _subscribeToProducts();
  }

  void _subscribeToProducts() {
    setState(() {
      _state = _state.copyWith(isLoading: true, errorMessage: null);
    });

    _subscription?.cancel();
    _subscription = widget.repository.watchAll().listen(
      (products) {
        if (!mounted) return;
        setState(() {
          _state = _state.copyWith(
            products: products,
            isLoading: false,
            errorMessage: null,
          );
        });
      },
      onError: (error) {
        if (!mounted) return;
        setState(() {
          _state = _state.copyWith(
            isLoading: false,
            errorMessage: error.toString(),
          );
        });
      },
    );
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  Future<void> _deleteProduct(Product product) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Hapus Produk'),
          content: Text('Yakin ingin menghapus ${product.name}?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Batal'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Hapus'),
            ),
          ],
        );
      },
    );

    if (confirmed == true && product.id != null) {
      await widget.repository.delete(product.id!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ScaffoldMessenger(
      key: _messengerKey,
      child: Scaffold(
        appBar: AppBar(title: const Text('Produk')),
        body: _buildBody(),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    InventoryFormScreen(repository: widget.repository),
              ),
            );
          },
          child: const Icon(Icons.add),
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_state.isLoading && _state.products.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_state.errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Error: ${_state.errorMessage}'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _subscribeToProducts,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_state.products.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inventory_2, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text('Belum ada produk', style: TextStyle(color: Colors.grey)),
          ],
        ),
      );
    }

    final filteredProducts = _state.products
        .where((p) => !_showLowStockOnly || p.isLowStock)
        .toList();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: SegmentedButton<bool>(
            segments: const [
              ButtonSegment<bool>(value: false, label: Text('Semua')),
              ButtonSegment<bool>(value: true, label: Text('Stok Menipis')),
            ],
            selected: {_showLowStockOnly},
            onSelectionChanged: (Set<bool> newSelection) {
              setState(() {
                _showLowStockOnly = newSelection.first;
              });
            },
          ),
        ),
        Expanded(
          child: filteredProducts.isEmpty
              ? const Center(child: Text('Tidak ada produk yang sesuai'))
              : ListView.builder(
                  itemCount: filteredProducts.length,
                  itemBuilder: (context, index) {
                    final product = filteredProducts[index];
                    final initial = product.name.isNotEmpty
                        ? product.name[0].toUpperCase()
                        : '?';

                    return ListTile(
                      leading: CircleAvatar(child: Text(initial)),
                      title: Text(product.name),
                      subtitle: Row(
                        children: [
                          Text(
                            'Stok: ${product.stock}',
                            style: product.isLowStock
                                ? const TextStyle(color: Colors.red)
                                : null,
                          ),
                          Flexible(
                            child: Text(
                              ' | Rp ${product.price.toStringAsFixed(0)}',
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _deleteProduct(product),
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => InventoryFormScreen(
                              repository: widget.repository,
                              product: product,
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
        ),
      ],
    );
  }
}
