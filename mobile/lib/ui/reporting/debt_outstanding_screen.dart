import 'package:flutter/material.dart';
import '../../domain/customer/repositories/debt_repository.dart';
import '../../domain/reporting/entities/debt_outstanding_report.dart';
import '../../domain/reporting/repositories/debt_outstanding_repository.dart';
import '../customer/debt_list_screen.dart';

class DebtOutstandingScreen extends StatefulWidget {
  final DebtOutstandingRepository debtOutstandingRepository;
  final DebtRepository debtRepository;

  const DebtOutstandingScreen({
    super.key,
    required this.debtOutstandingRepository,
    required this.debtRepository,
  });

  @override
  State<DebtOutstandingScreen> createState() => _DebtOutstandingScreenState();
}

class _DebtOutstandingScreenState extends State<DebtOutstandingScreen> {
  int _streamKey = 0;

  String _formatCurrency(double amount) {
    String res = amount.toInt().toString();
    String formatted = '';
    int count = 0;
    for (int i = res.length - 1; i >= 0; i--) {
      if (count == 3) {
        formatted = '.$formatted';
        count = 0;
      }
      formatted = res[i] + formatted;
      count++;
    }
    return 'Rp $formatted';
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Piutang Kasbon'),
      ),
      body: FutureBuilder<DebtOutstandingReport>(
        key: ValueKey(_streamKey),
        future: widget.debtOutstandingRepository.getOutstandingReport(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Terjadi kesalahan saat memuat data'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      if (!mounted) return;
                      setState(() => _streamKey++);
                    },
                    child: const Text('Coba Lagi'),
                  ),
                ],
              ),
            );
          }

          final report = snapshot.data;
          if (report == null || report.summaries.isEmpty) {
            return const Center(
              child: Text(
                'Belum ada piutang',
                style: TextStyle(color: Colors.grey, fontSize: 16),
              ),
            );
          }

          return CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: _buildSummaryCard(report),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    'Daftar Customer',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
              ),
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final summary = report.summaries[index];
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.blue.shade100,
                        child: Text(
                          summary.customer.name.isNotEmpty
                              ? summary.customer.name[0].toUpperCase()
                              : '?',
                          style: TextStyle(color: Colors.blue.shade900),
                        ),
                      ),
                      title: Text(summary.customer.name),
                      subtitle: Text(
                        summary.customer.phone != null && summary.customer.phone!.isNotEmpty
                            ? summary.customer.phone!
                            : 'Tanpa nomor telepon',
                      ),
                      trailing: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            _formatCurrency(summary.remaining),
                            style: const TextStyle(
                              color: Colors.red,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          Text(
                            '${summary.unpaidCount} kasbon',
                            style: const TextStyle(fontSize: 12, color: Colors.black54),
                          ),
                        ],
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => DebtListScreen(
                              customer: summary.customer,
                              debtRepository: widget.debtRepository,
                            ),
                          ),
                        ).then((_) {
                          if (!mounted) return;
                          setState(() => _streamKey++);
                        });
                      },
                    );
                  },
                  childCount: report.summaries.length,
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSummaryCard(DebtOutstandingReport report) {
    return Card(
      margin: const EdgeInsets.all(16.0),
      color: Colors.red.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text('Total Piutang', style: TextStyle(fontSize: 16, color: Colors.black54)),
            const SizedBox(height: 8),
            Text(
              _formatCurrency(report.totalOutstanding),
              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.red),
            ),
            const Divider(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Column(
                  children: [
                    const Text('Jumlah Customer', style: TextStyle(color: Colors.black54)),
                    Text('${report.customerCount}', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  ],
                ),
                Column(
                  children: [
                    const Text('Jumlah Kasbon', style: TextStyle(color: Colors.black54)),
                    Text('${report.debtCount}', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
