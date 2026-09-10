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
  InventoryState _state = const InventoryState(isLoading: true);
  StreamSubscription<List<Product>>? _subscription;

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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Produk'),
      ),
      body: _buildBody(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => InventoryFormScreen(
                repository: widget.repository,
              ),
            ),
          );
        },
        child: const Icon(Icons.add),
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

    return ListView.builder(
      itemCount: _state.products.length,
      itemBuilder: (context, index) {
        final product = _state.products[index];
        final initial = product.name.isNotEmpty ? product.name[0].toUpperCase() : '?';

        return ListTile(
          leading: CircleAvatar(child: Text(initial)),
          title: Text(product.name),
          subtitle: Text('Stok: ${product.stock} | Rp ${product.price.toStringAsFixed(0)}'),
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
    );
  }
}
