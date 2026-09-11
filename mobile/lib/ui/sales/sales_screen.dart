import 'dart:async';
import 'package:flutter/material.dart';
import '../../domain/inventory/entities/product.dart';
import '../../domain/inventory/repositories/product_repository.dart';
import '../../domain/sales/entities/transaction.dart';
import '../../domain/sales/repositories/transaction_repository.dart';
import '../../domain/customer/entities/customer.dart';
import '../../domain/customer/repositories/customer_repository.dart';
import '../../domain/customer/repositories/debt_repository.dart';
import '../customer/customer_form_screen.dart';
import 'sales_state.dart';

class SalesScreen extends StatefulWidget {
  final ProductRepository productRepository;
  final TransactionRepository transactionRepository;
  final CustomerRepository customerRepository;
  final DebtRepository debtRepository;

  const SalesScreen({
    super.key,
    required this.productRepository,
    required this.transactionRepository,
    required this.customerRepository,
    required this.debtRepository,
  });

  @override
  State<SalesScreen> createState() => _SalesScreenState();
}

class _SalesScreenState extends State<SalesScreen> {
  SalesState _state = const SalesState(isLoading: true);
  StreamSubscription<List<Product>>? _subscription;

  @override
  void initState() {
    super.initState();
    _subscribeToProducts();
  }

  void _subscribeToProducts() {
    setState(() {
      _state = _state.copyWith(isLoading: true, clearError: true);
    });

    _subscription?.cancel();
    _subscription = widget.productRepository.watchAll().listen(
      (products) {
        if (!mounted) return;
        setState(() {
          _state = _state.copyWith(
            products: products,
            isLoading: false,
            clearError: true,
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

  void _addToCart(Product product) {
    setState(() {
      _state = _state.addToCart(product);
    });
    _checkAndShowError();
  }

  void _updateQuantity(int productId, int quantity) {
    setState(() {
      _state = _state.updateQuantity(productId, quantity);
    });
    _checkAndShowError();
  }

  void _checkAndShowError() {
    if (_state.errorMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_state.errorMessage!)),
      );
      setState(() {
        _state = _state.copyWith(clearError: true);
      });
    }
  }

  Future<void> _processPayment() async {
    if (_state.cart.isEmpty) return;

    final method = await showDialog<PaymentMethod>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Metode Pembayaran'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: const Text('Tunai'),
                onTap: () => Navigator.pop(context, PaymentMethod.cash),
              ),
              ListTile(
                title: const Text('QRIS'),
                onTap: () => Navigator.pop(context, PaymentMethod.qris),
              ),
              ListTile(
                title: const Text('Kasbon'),
                onTap: () => Navigator.pop(context, PaymentMethod.debt),
              ),
            ],
          ),
        );
      },
    );

    if (method == null) return;

    int? selectedCustomerId;
    if (method == PaymentMethod.debt) {
      selectedCustomerId = await _pickCustomer();
      if (selectedCustomerId == -1) {
        if (!mounted) return;
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CustomerFormScreen(
              customerRepository: widget.customerRepository,
            ),
          ),
        );
        selectedCustomerId = await _pickCustomer();
        if (selectedCustomerId == -1) return; // treat as cancel if they cancel the second dialog
      }
      if (selectedCustomerId == null) return; // cancelled
    }

    setState(() {
      _state = _state.copyWith(isLoading: true);
    });

    try {
      final transaction = Transaction(
        tenantId: 'tenant-1',
        items: _state.cart,
        total: _state.totalAmount,
        paymentMethod: method,
        customerId: selectedCustomerId,
        createdAt: DateTime.now(),
      );

      await widget.transactionRepository.create(transaction);

      bool debtSuccess = true;
      if (method == PaymentMethod.debt && selectedCustomerId != null) {
        try {
          await widget.debtRepository.createDebt(
            customerId: selectedCustomerId,
            amount: transaction.totalAmount,
          );
        } catch (e) {
          debtSuccess = false;
        }
      }

      if (mounted) {
        if (!debtSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Transaksi tersimpan, tapi kasbon gagal dicatat. Cek manual.')),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Transaksi Berhasil!')),
          );
        }
        setState(() {
          _state = _state.clearCart().copyWith(isLoading: false);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
        setState(() {
          _state = _state.copyWith(isLoading: false);
        });
      }
    }
  }

  Future<int?> _pickCustomer() async {
    int streamKey = 0;
    return showDialog<int>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return AlertDialog(
              title: const Text('Pilih Customer'),
              content: SizedBox(
                width: double.maxFinite,
                child: StreamBuilder<List<Customer>>(
                  key: ValueKey(streamKey),
                  stream: widget.customerRepository.watchAll(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (snapshot.hasError) {
                      return Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text('Gagal memuat customer'),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () => setModalState(() => streamKey++),
                            child: const Text('Coba Lagi'),
                          ),
                        ],
                      );
                    }
                    
                    final customers = snapshot.data ?? [];
                    
                    if (customers.isEmpty) {
                      return Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text('Belum ada customer'),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () {
                              Navigator.pop(context, -1);
                            },
                            child: const Text('Tambah Customer'),
                          ),
                        ],
                      );
                    }

                    return ListView.builder(
                      shrinkWrap: true,
                      itemCount: customers.length,
                      itemBuilder: (context, index) {
                        final customer = customers[index];
                        return ListTile(
                          title: Text(customer.name),
                          subtitle: Text(customer.phone ?? '-'),
                          onTap: () => Navigator.pop(context, customer.id),
                        );
                      },
                    );
                  },
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, null),
                  child: const Text('Batal'),
                ),
              ],
            );
          }
        );
      },
    );
  }

  void _showCartSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              padding: const EdgeInsets.all(16),
              height: MediaQuery.of(context).size.height * 0.7,
              child: Column(
                children: [
                  const Text('Keranjang', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const Divider(),
                  Expanded(
                    child: _state.cart.isEmpty
                        ? const Center(child: Text('Keranjang kosong'))
                        : ListView.builder(
                            itemCount: _state.cart.length,
                            itemBuilder: (context, index) {
                              final item = _state.cart[index];
                              return ListTile(
                                title: Text(item.productName),
                                subtitle: Text('Rp ${item.price} x ${item.quantity} = Rp ${item.subtotal}'),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.remove),
                                      onPressed: () {
                                        _updateQuantity(item.productId, item.quantity - 1);
                                        setModalState(() {});
                                      },
                                    ),
                                    Text('${item.quantity}'),
                                    IconButton(
                                      icon: const Icon(Icons.add),
                                      onPressed: () {
                                        _updateQuantity(item.productId, item.quantity + 1);
                                        setModalState(() {});
                                      },
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete, color: Colors.red),
                                      onPressed: () {
                                        setState(() {
                                          _state = _state.removeFromCart(item.productId);
                                        });
                                        setModalState(() {});
                                      },
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                  ),
                  const Divider(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Total:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      Text('Rp ${_state.totalAmount}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _state.cart.isEmpty ? null : () {
                        Navigator.pop(context);
                        _processPayment();
                      },
                      child: const Text('Bayar'),
                    ),
                  ),
                ],
              ),
            );
          }
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Transaksi Kasir'),
        actions: [
          IconButton(
            icon: Badge(
              label: Text('${_state.totalItems}'),
              isLabelVisible: _state.totalItems > 0,
              child: const Icon(Icons.shopping_cart),
            ),
            onPressed: _showCartSheet,
          ),
        ],
      ),
      body: _buildProductList(),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  Widget _buildProductList() {
    if (_state.isLoading && _state.products.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_state.products.isEmpty) {
      return const Center(
        child: Text('Belum ada produk untuk dijual.'),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(8),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.85,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: _state.products.length,
      itemBuilder: (context, index) {
        final product = _state.products[index];
        return Card(
          child: InkWell(
            onTap: () => _addToCart(product),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: 30,
                    child: Text(product.name.isNotEmpty ? product.name[0].toUpperCase() : '?'),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    product.name,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text('Rp ${product.price.toStringAsFixed(0)}'),
                  const SizedBox(height: 4),
                  Text('Stok: ${product.stock}', style: TextStyle(color: product.stock > 0 ? Colors.green : Colors.red)),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Total Pembayaran', style: TextStyle(color: Colors.grey)),
              Text(
                'Rp ${_state.totalAmount.toStringAsFixed(0)}',
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          ElevatedButton(
            onPressed: _state.cart.isEmpty ? null : _showCartSheet,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            ),
            child: const Text('Bayar'),
          ),
        ],
      ),
    );
  }
}
