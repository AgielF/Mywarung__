import 'package:flutter/material.dart';
import '../../domain/customer/entities/customer.dart';
import '../../domain/customer/entities/debt.dart';
import '../../domain/customer/repositories/debt_repository.dart';

import '../../domain/sales/entities/transaction.dart';
import '../../domain/sales/repositories/transaction_repository.dart';
import '../../domain/customer/repositories/customer_repository.dart';
import 'customer_form_screen.dart';

class DebtListScreen extends StatefulWidget {
  final Customer customer;
  final DebtRepository debtRepository;
  final CustomerRepository customerRepository;
  final TransactionRepository transactionRepository;

  const DebtListScreen({
    super.key,
    required this.customer,
    required this.debtRepository,
    required this.customerRepository,
    required this.transactionRepository,
  });

  @override
  State<DebtListScreen> createState() => _DebtListScreenState();
}

class _DebtListScreenState extends State<DebtListScreen> {
  final _messengerKey = GlobalKey<ScaffoldMessengerState>();
  int _streamKey = 0;
  List<Transaction> _customerTransactions = [];

  @override
  void initState() {
    super.initState();
    _loadTransactions();
  }

  Future<void> _loadTransactions() async {
    final txs = await widget.transactionRepository.getAll();
    if (mounted) {
      setState(() {
        _customerTransactions = txs
            .where(
              (t) =>
                  t.customerId == widget.customer.id &&
                  t.paymentMethod.name == 'debt',
            )
            .toList();
      });
    }
  }

  Map<int, String> _loadDebtDescriptions(List<Debt> debts) {
    Map<int, String> descriptions = {};
    for (final debt in debts) {
      final txMatch = _customerTransactions
          .where((t) => (t.total - debt.amount).abs() < 0.01)
          .toList();
      if (txMatch.isNotEmpty) {
        final tx = txMatch.first;
        if (tx.items.isNotEmpty) {
          final itemNames = tx.items.map((i) => i.productName).join(', ');
          descriptions[debt.id!] =
              'Untuk: ${tx.items.length} item ($itemNames)';
        } else {
          descriptions[debt.id!] =
              'Transaksi ${tx.createdAt.day}/${tx.createdAt.month} ${tx.createdAt.hour}:${tx.createdAt.minute}';
        }
      }
    }
    return descriptions;
  }

  void _deleteCustomer() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Customer'),
        content: Text('Yakin ingin menghapus ${widget.customer.name}?'),
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
        await widget.customerRepository.delete(widget.customer.id!);
        if (!mounted) return;
        _messengerKey.currentState
          ?..hideCurrentSnackBar()
          ..showSnackBar(
            const SnackBar(content: Text('Customer berhasil dihapus')),
          );
        Navigator.pop(context);
      } catch (e) {
        if (!mounted) return;
        final msg = e
            .toString()
            .replaceAll('Bad state: ', '')
            .replaceAll('Exception: ', '');
        _messengerKey.currentState
          ?..hideCurrentSnackBar()
          ..showSnackBar(SnackBar(content: Text('Gagal: $msg')));
      }
    }
  }

  void _payDebt(Debt debt) async {
    final controller = TextEditingController(
      text: debt.remainingAmount.toStringAsFixed(0),
    );
    final formKey = GlobalKey<FormState>();

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Bayar Kasbon'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Sisa tagihan: Rp ${debt.remainingAmount}'),
              const SizedBox(height: 16),
              TextFormField(
                controller: controller,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: const InputDecoration(
                  labelText: 'Jumlah Bayar',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Harus diisi';
                  final amount = double.tryParse(value);
                  if (amount == null || amount <= 0) {
                    return 'Jumlah tidak valid';
                  }
                  if (amount > debt.remainingAmount) {
                    return 'Melebihi sisa tagihan';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                Navigator.pop(context, true);
              }
            },
            child: const Text('Bayar'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      if (!mounted) {
        controller.dispose();
        return;
      }
      try {
        final payment = double.parse(controller.text);
        await widget.debtRepository.payDebt(debtId: debt.id!, payment: payment);
        if (mounted) {
          _messengerKey.currentState
            ?..hideCurrentSnackBar()
            ..showSnackBar(
              const SnackBar(content: Text('Pembayaran berhasil dicatat')),
            );
        }
      } catch (e) {
        if (mounted) {
          final msg = e
              .toString()
              .replaceAll('Bad state: ', '')
              .replaceAll('Exception: ', '');
          _messengerKey.currentState
            ?..hideCurrentSnackBar()
            ..showSnackBar(SnackBar(content: Text('Gagal: $msg')));
        }
      }
    }
    controller.dispose();
  }

  void _addDebt() async {
    final controller = TextEditingController();
    final formKey = GlobalKey<FormState>();

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Tambah Kasbon'),
        content: Form(
          key: formKey,
          child: TextFormField(
            controller: controller,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(
              labelText: 'Jumlah Kasbon',
              border: OutlineInputBorder(),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) return 'Harus diisi';
              final amount = double.tryParse(value);
              if (amount == null || amount <= 0) return 'Jumlah tidak valid';
              return null;
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                Navigator.pop(context, true);
              }
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      if (!mounted) {
        controller.dispose();
        return;
      }
      try {
        final amount = double.parse(controller.text);
        await widget.debtRepository.createDebt(
          customerId: widget.customer.id!,
          amount: amount,
        );
        if (mounted) {
          _messengerKey.currentState
            ?..hideCurrentSnackBar()
            ..showSnackBar(
              const SnackBar(content: Text('Kasbon berhasil ditambahkan')),
            );
        }
      } catch (e) {
        if (mounted) {
          final msg = e
              .toString()
              .replaceAll('Bad state: ', '')
              .replaceAll('Exception: ', '');
          _messengerKey.currentState
            ?..hideCurrentSnackBar()
            ..showSnackBar(SnackBar(content: Text('Gagal: $msg')));
        }
      }
    }
    controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaffoldMessenger(
      key: _messengerKey,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Kasbon: ${widget.customer.name}'),
          actions: [
            PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'edit') {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CustomerFormScreen(
                        customerRepository: widget.customerRepository,
                        customer: widget.customer,
                      ),
                    ),
                  );
                } else if (value == 'delete') {
                  _deleteCustomer();
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'edit',
                  child: Text('Edit Customer'),
                ),
                const PopupMenuItem(
                  value: 'delete',
                  child: Text(
                    'Hapus Customer',
                    style: TextStyle(color: Colors.red),
                  ),
                ),
              ],
            ),
          ],
        ),
        body: StreamBuilder<List<Debt>>(
          key: ValueKey(_streamKey),
          stream: widget.debtRepository.watchByCustomer(widget.customer.id!),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Error: ${snapshot.error}'),
                    ElevatedButton(
                      onPressed: () => setState(() => _streamKey++),
                      child: const Text('Coba Lagi'),
                    ),
                  ],
                ),
              );
            }

            final debts = snapshot.data ?? [];
            final descriptions = _loadDebtDescriptions(debts);

            final totalKasbon = debts.fold(
              0.0,
              (sum, debt) => sum + debt.amount,
            );
            final totalDibayar = debts.fold(
              0.0,
              (sum, debt) => sum + debt.paid,
            );
            final sisa = debts.fold(
              0.0,
              (sum, debt) => sum + debt.remainingAmount,
            );

            return Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(16.0),
                  color: Colors.blue.shade50,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildSummaryItem('Total Kasbon', totalKasbon),
                      _buildSummaryItem('Dibayar', totalDibayar),
                      _buildSummaryItem('Sisa', sisa, isHighlight: true),
                    ],
                  ),
                ),
                Expanded(
                  child: debts.isEmpty
                      ? const Center(child: Text('Belum ada riwayat kasbon'))
                      : ListView.builder(
                          itemCount: debts.length,
                          itemBuilder: (context, index) {
                            final debt = debts[index];
                            final desc = descriptions[debt.id];
                            return ListTile(
                              title: Text('Rp ${debt.amount}'),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Sisa: Rp ${debt.remainingAmount} • ${debt.status.name}',
                                  ),
                                  if (desc != null) ...[
                                    const SizedBox(height: 4),
                                    Text(
                                      desc,
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                              trailing: !debt.isPaid
                                  ? ElevatedButton(
                                      onPressed: () => _payDebt(debt),
                                      child: const Text('Bayar'),
                                    )
                                  : const Icon(
                                      Icons.check_circle,
                                      color: Colors.green,
                                    ),
                            );
                          },
                        ),
                ),
              ],
            );
          },
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: _addDebt,
          label: const Text('+ Kasbon Baru'),
          icon: const Icon(Icons.add),
        ),
      ),
    );
  }

  Widget _buildSummaryItem(
    String label,
    double value, {
    bool isHighlight = false,
  }) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        const SizedBox(height: 4),
        Text(
          'Rp ${value.toStringAsFixed(0)}',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: isHighlight ? Colors.red : Colors.black87,
          ),
        ),
      ],
    );
  }
}
