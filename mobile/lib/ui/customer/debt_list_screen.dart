import 'package:flutter/material.dart';
import '../../domain/customer/entities/customer.dart';
import '../../domain/customer/entities/debt.dart';
import '../../domain/customer/repositories/debt_repository.dart';

class DebtListScreen extends StatefulWidget {
  final Customer customer;
  final DebtRepository debtRepository;

  const DebtListScreen({
    super.key,
    required this.customer,
    required this.debtRepository,
  });

  @override
  State<DebtListScreen> createState() => _DebtListScreenState();
}

class _DebtListScreenState extends State<DebtListScreen> {
  int _streamKey = 0;

  void _payDebt(Debt debt) async {
    final controller = TextEditingController(text: debt.remainingAmount.toStringAsFixed(0));
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
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: 'Jumlah Bayar',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Harus diisi';
                  final amount = double.tryParse(value);
                  if (amount == null || amount <= 0) return 'Jumlah tidak valid';
                  if (amount > debt.remainingAmount) return 'Melebihi sisa tagihan';
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
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Pembayaran berhasil dicatat')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Gagal: ${e.toString()}')),
          );
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
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Kasbon berhasil ditambahkan')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Gagal: ${e.toString()}')),
          );
        }
      }
    }
    controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Kasbon: ${widget.customer.name}'),
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

          final totalKasbon = debts.fold(0.0, (sum, debt) => sum + debt.amount);
          final totalDibayar = debts.fold(0.0, (sum, debt) => sum + debt.paid);
          final sisa = debts.fold(0.0, (sum, debt) => sum + debt.remainingAmount);

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
                          return ListTile(
                            title: Text('Rp ${debt.amount}'),
                            subtitle: Text(
                                'Sisa: Rp ${debt.remainingAmount} • ${debt.status.name}'),
                            trailing: !debt.isPaid
                                ? ElevatedButton(
                                    onPressed: () => _payDebt(debt),
                                    child: const Text('Bayar'),
                                  )
                                : const Icon(Icons.check_circle, color: Colors.green),
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
    );
  }

  Widget _buildSummaryItem(String label, double value, {bool isHighlight = false}) {
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
