import 'package:flutter/material.dart';
import '../../domain/reporting/entities/daily_report.dart';
import '../../domain/reporting/repositories/reporting_repository.dart';
import '../../domain/sales/entities/transaction.dart';
import '../../domain/sales/repositories/transaction_repository.dart';

class ReportingScreen extends StatefulWidget {
  final ReportingRepository reportingRepository;
  final TransactionRepository transactionRepository;

  const ReportingScreen({
    super.key,
    required this.reportingRepository,
    required this.transactionRepository,
  });

  @override
  State<ReportingScreen> createState() => _ReportingScreenState();
}

class _ReportingScreenState extends State<ReportingScreen> {
  int _streamKey = 0;
  String _selectedFilter = 'Hari Ini';
  DateTime? _customFrom;
  DateTime? _customTo;

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

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  String _formatDay(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  @override
  void dispose() {
    super.dispose();
  }

  Stream<DailyReport> _getReportStream() {
    if (_selectedFilter == 'Hari Ini') {
      return widget.reportingRepository.watchDailyReport(DateTime.now());
    } else if (_selectedFilter == '7 Hari Terakhir') {
      final now = DateTime.now();
      final from = now.subtract(const Duration(days: 6));
      return Stream.fromFuture(
          widget.reportingRepository.getRangeReport(from, now).then(_aggregateReports));
    } else {
      if (_customFrom == null || _customTo == null) {
        return Stream.value(_emptyReport());
      }
      return Stream.fromFuture(
          widget.reportingRepository.getRangeReport(_customFrom!, _customTo!).then(_aggregateReports));
    }
  }

  DailyReport _emptyReport() {
    return DailyReport(
      date: DateTime.now(),
      totalSales: 0,
      transactionCount: 0,
      breakdown: const [
        PaymentMethodBreakdown(method: PaymentMethod.cash, transactionCount: 0, totalAmount: 0),
        PaymentMethodBreakdown(method: PaymentMethod.qris, transactionCount: 0, totalAmount: 0),
        PaymentMethodBreakdown(method: PaymentMethod.debt, transactionCount: 0, totalAmount: 0),
      ],
      transactions: const [],
    );
  }

  DailyReport _aggregateReports(List<DailyReport> reports) {
    if (reports.isEmpty) return _emptyReport();

    double totalSales = 0;
    int transactionCount = 0;
    List<Transaction> transactions = [];
    Map<PaymentMethod, int> counts = {
      PaymentMethod.cash: 0,
      PaymentMethod.qris: 0,
      PaymentMethod.debt: 0,
    };
    Map<PaymentMethod, double> amounts = {
      PaymentMethod.cash: 0.0,
      PaymentMethod.qris: 0.0,
      PaymentMethod.debt: 0.0,
    };

    for (final r in reports) {
      totalSales += r.totalSales;
      transactionCount += r.transactionCount;
      transactions.addAll(r.transactions);
      for (final b in r.breakdown) {
        counts[b.method] = counts[b.method]! + b.transactionCount;
        amounts[b.method] = amounts[b.method]! + b.totalAmount;
      }
    }

    transactions.sort((a, b) => b.createdAt.compareTo(a.createdAt));

    return DailyReport(
      date: DateTime.now(),
      totalSales: totalSales,
      transactionCount: transactionCount,
      breakdown: [
        PaymentMethodBreakdown(
            method: PaymentMethod.cash,
            transactionCount: counts[PaymentMethod.cash]!,
            totalAmount: amounts[PaymentMethod.cash]!),
        PaymentMethodBreakdown(
            method: PaymentMethod.qris,
            transactionCount: counts[PaymentMethod.qris]!,
            totalAmount: amounts[PaymentMethod.qris]!),
        PaymentMethodBreakdown(
            method: PaymentMethod.debt,
            transactionCount: counts[PaymentMethod.debt]!,
            totalAmount: amounts[PaymentMethod.debt]!),
      ],
      transactions: transactions,
    );
  }

  Future<void> _selectCustomDateRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      currentDate: DateTime.now(),
    );

    if (!mounted) return;

    if (picked != null) {
      setState(() {
        _selectedFilter = 'Custom';
        _customFrom = picked.start;
        _customTo = picked.end;
        _streamKey++;
      });
    }
  }

  void _onFilterChanged(String filter) {
    if (filter == 'Custom') {
      _selectCustomDateRange();
    } else {
      setState(() {
        _selectedFilter = filter;
        _streamKey++;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Laporan Penjualan'),
      ),
      body: Column(
        children: [
          _buildFilters(),
          Expanded(
            child: StreamBuilder<DailyReport>(
              key: ValueKey(_streamKey),
              stream: _getReportStream(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('Terjadi kesalahan saat memuat laporan'),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () => setState(() => _streamKey++),
                          child: const Text('Coba Lagi'),
                        ),
                      ],
                    ),
                  );
                }

                final report = snapshot.data ?? _emptyReport();

                return CustomScrollView(
                  slivers: [
                    SliverToBoxAdapter(child: _buildSummaryCard(report)),
                    SliverToBoxAdapter(child: _buildBreakdown(report)),
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text(
                          'Daftar Transaksi',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                      ),
                    ),
                    _buildTransactionList(report),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilters() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          ChoiceChip(
            label: const Text('Hari Ini'),
            selected: _selectedFilter == 'Hari Ini',
            onSelected: (_) => _onFilterChanged('Hari Ini'),
          ),
          ChoiceChip(
            label: const Text('7 Hari Terakhir'),
            selected: _selectedFilter == '7 Hari Terakhir',
            onSelected: (_) => _onFilterChanged('7 Hari Terakhir'),
          ),
          ChoiceChip(
            label: Text(_selectedFilter == 'Custom' && _customFrom != null && _customTo != null
                ? '${_formatDay(_customFrom!)} - ${_formatDay(_customTo!)}'
                : 'Custom'),
            selected: _selectedFilter == 'Custom',
            onSelected: (_) => _onFilterChanged('Custom'),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(DailyReport report) {
    return Card(
      margin: const EdgeInsets.all(16.0),
      color: Colors.green.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text('Total Penjualan', style: TextStyle(fontSize: 16, color: Colors.black54)),
            const SizedBox(height: 8),
            Text(
              _formatCurrency(report.totalSales),
              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.green),
            ),
            const Divider(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Column(
                  children: [
                    const Text('Jumlah Transaksi', style: TextStyle(color: Colors.black54)),
                    Text('${report.transactionCount}', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBreakdown(DailyReport report) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        children: report.breakdown.map((b) {
          String name = '';
          IconData icon = Icons.money;
          if (b.method == PaymentMethod.cash) {
            name = 'Tunai';
            icon = Icons.payments;
          } else if (b.method == PaymentMethod.qris) {
            name = 'QRIS';
            icon = Icons.qr_code;
          } else if (b.method == PaymentMethod.debt) {
            name = 'Kasbon';
            icon = Icons.book;
          }

          return Expanded(
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  children: [
                    Icon(icon, color: Colors.blue),
                    const SizedBox(height: 8),
                    Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text('${b.transactionCount} trx'),
                    const SizedBox(height: 4),
                    Text(_formatCurrency(b.totalAmount), style: const TextStyle(fontSize: 12)),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildTransactionList(DailyReport report) {
    if (report.transactions.isEmpty) {
      return const SliverToBoxAdapter(
        child: Padding(
          padding: EdgeInsets.all(32.0),
          child: Center(
            child: Text('Belum ada transaksi', style: TextStyle(color: Colors.grey, fontSize: 16)),
          ),
        ),
      );
    }

    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          final t = report.transactions[index];
          String methodStr = t.paymentMethod == PaymentMethod.cash ? 'Tunai' : (t.paymentMethod == PaymentMethod.qris ? 'QRIS' : 'Kasbon');
          return ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.grey.shade200,
              child: Icon(
                t.paymentMethod == PaymentMethod.cash ? Icons.payments : (t.paymentMethod == PaymentMethod.qris ? Icons.qr_code : Icons.book),
                color: Colors.black54,
              ),
            ),
            title: Text(_formatCurrency(t.totalAmount)),
            subtitle: Text('${_formatDate(t.createdAt)} • $methodStr'),
            trailing: Text('${t.totalItems} item'),
          );
        },
        childCount: report.transactions.length,
      ),
    );
  }
}
