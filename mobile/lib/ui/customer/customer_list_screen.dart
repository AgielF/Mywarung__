import 'package:flutter/material.dart';
import '../../domain/customer/entities/customer.dart';
import '../../domain/customer/repositories/customer_repository.dart';
import 'customer_form_screen.dart';
import 'debt_list_screen.dart';
import '../../domain/customer/repositories/debt_repository.dart';

class CustomerListScreen extends StatefulWidget {
  final CustomerRepository customerRepository;
  final DebtRepository debtRepository;

  const CustomerListScreen({
    super.key,
    required this.customerRepository,
    required this.debtRepository,
  });

  @override
  State<CustomerListScreen> createState() => _CustomerListScreenState();
}

class _CustomerListScreenState extends State<CustomerListScreen> {
  int _streamKey = 0;

  void _navigateToForm([Customer? customer]) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CustomerFormScreen(
          customerRepository: widget.customerRepository,
          customer: customer,
        ),
      ),
    );
  }

  void _navigateToDebtList(Customer customer) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DebtListScreen(
          customer: customer,
          debtRepository: widget.debtRepository,
        ),
      ),
    );
  }

  void _deleteCustomer(Customer customer) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Customer'),
        content: Text('Yakin ingin menghapus ${customer.name}?'),
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
      ),
    );

    if (confirm == true) {
      if (!mounted) return;
      try {
        await widget.customerRepository.delete(customer.id!);
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Customer berhasil dihapus')),
        );
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal: ${e.toString()}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Customer & Kasbon'),
      ),
      body: StreamBuilder<List<Customer>>(
        key: ValueKey(_streamKey),
        stream: widget.customerRepository.watchAll(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Terjadi kesalahan: ${snapshot.error}'),
                  ElevatedButton(
                    onPressed: () => setState(() => _streamKey++),
                    child: const Text('Coba Lagi'),
                  ),
                ],
              ),
            );
          }

          final customers = snapshot.data;

          if (customers == null || customers.isEmpty) {
            return const Center(
              child: Text('Belum ada customer'),
            );
          }

          return ListView.builder(
            itemCount: customers.length,
            itemBuilder: (context, index) {
              final customer = customers[index];
              return ListTile(
                title: Text(customer.name),
                subtitle: Text(customer.phone ?? '-'),
                onTap: () => _navigateToDebtList(customer),
                onLongPress: () {
                  showModalBottomSheet(
                    context: context,
                    builder: (context) => SafeArea(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ListTile(
                            leading: const Icon(Icons.edit),
                            title: const Text('Edit'),
                            onTap: () {
                              Navigator.pop(context);
                              _navigateToForm(customer);
                            },
                          ),
                          ListTile(
                            leading: const Icon(Icons.delete, color: Colors.red),
                            title: const Text('Hapus', style: TextStyle(color: Colors.red)),
                            onTap: () {
                              Navigator.pop(context);
                              _deleteCustomer(customer);
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToForm,
        child: const Icon(Icons.add),
      ),
    );
  }
}
