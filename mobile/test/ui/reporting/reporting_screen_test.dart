import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pos_warung_ai/domain/reporting/entities/daily_report.dart';
import 'package:pos_warung_ai/domain/reporting/entities/sales_trend_point.dart';
import 'package:pos_warung_ai/domain/sales/entities/transaction.dart' as sales_domain;
import 'package:pos_warung_ai/domain/sales/entities/transaction_item.dart' as sales_domain;
import 'package:pos_warung_ai/ui/reporting/reporting_screen.dart';
import 'package:pos_warung_ai/ui/reporting/widgets/sales_bar_chart.dart';
import '../../helpers/fakes.dart';

void main() {
  late FakeReportingRepository reportingRepo;

  setUp(() {
    reportingRepo = FakeReportingRepository();
  });

  Widget createWidget() {
    return MaterialApp(
      home: ReportingScreen(
        reportingRepository: reportingRepo,
      ),
    );
  }

  testWidgets('menampilkan empty state jika belum ada transaksi', (tester) async {
    await tester.pumpWidget(createWidget());
    await tester.pumpAndSettle();

    await tester.drag(find.byType(CustomScrollView), const Offset(0, -1000));
    await tester.pumpAndSettle();
    expect(find.text('Belum ada transaksi'), findsOneWidget);
    expect(find.text('Rp 0'), findsWidgets);
    expect(find.text('0'), findsWidgets); 
  });

  testWidgets('menampilkan list transaksi dan summary jika ada data', (tester) async {
    reportingRepo.fakeDailyReport = DailyReport(
      date: DateTime.now(),
      totalSales: 15000,
      transactionCount: 2,
      breakdown: [
        const PaymentMethodBreakdown(method: sales_domain.PaymentMethod.cash, transactionCount: 1, totalAmount: 5000),
        const PaymentMethodBreakdown(method: sales_domain.PaymentMethod.qris, transactionCount: 1, totalAmount: 10000),
        const PaymentMethodBreakdown(method: sales_domain.PaymentMethod.debt, transactionCount: 0, totalAmount: 0),
      ],
      transactions: [
        sales_domain.Transaction(
          id: 1,
          tenantId: 'tenant-1',
          items: [
            sales_domain.TransactionItem(id: 1, productId: 1, productName: 'Kopi', quantity: 1, price: 5000, subtotal: 5000)
          ],
          total: 5000,
          paymentMethod: sales_domain.PaymentMethod.cash,
          createdAt: DateTime.now(),
        ),
        sales_domain.Transaction(
          id: 2,
          tenantId: 'tenant-1',
          items: [
            sales_domain.TransactionItem(id: 2, productId: 2, productName: 'Teh', quantity: 2, price: 5000, subtotal: 10000)
          ],
          total: 10000,
          paymentMethod: sales_domain.PaymentMethod.qris,
          createdAt: DateTime.now(),
        ),
      ],
    );

    await tester.pumpWidget(createWidget());
    await tester.pumpAndSettle();

    expect(find.text('Rp 15.000'), findsWidgets); 
    expect(find.text('2'), findsWidgets); 
    expect(find.text('Rp 5.000'), findsWidgets);
    expect(find.text('Rp 10.000'), findsWidgets);
    expect(find.text('Belum ada transaksi'), findsNothing);
  });

  testWidgets('filter chip bekerja (ubah ke 7 Hari Terakhir)', (tester) async {
    reportingRepo.fakeRangeReport = [
      DailyReport(
        date: DateTime.now().subtract(const Duration(days: 1)),
        totalSales: 20000,
        transactionCount: 1,
        breakdown: [
          const PaymentMethodBreakdown(method: sales_domain.PaymentMethod.cash, transactionCount: 1, totalAmount: 20000),
          const PaymentMethodBreakdown(method: sales_domain.PaymentMethod.qris, transactionCount: 0, totalAmount: 0),
          const PaymentMethodBreakdown(method: sales_domain.PaymentMethod.debt, transactionCount: 0, totalAmount: 0),
        ],
        transactions: [],
      )
    ];

    await tester.pumpWidget(createWidget());
    await tester.pumpAndSettle();

    await tester.tap(find.text('7 Hari Terakhir'));
    await tester.pumpAndSettle();

    expect(find.text('Rp 20.000'), findsWidgets);
  });

  testWidgets('error state dan tombol Coba Lagi berfungsi', (tester) async {
    reportingRepo.throwError = true;
    
    await tester.pumpWidget(createWidget());
    await tester.pumpAndSettle();

    expect(find.text('Terjadi kesalahan saat memuat laporan'), findsOneWidget);
    expect(find.text('Coba Lagi'), findsOneWidget);

    reportingRepo.throwError = false; 
    
    await tester.tap(find.text('Coba Lagi'));
    await tester.pumpAndSettle();

    await tester.drag(find.byType(CustomScrollView), const Offset(0, -500));
    await tester.pumpAndSettle();
    await tester.drag(find.byType(CustomScrollView), const Offset(0, -500));
    await tester.pumpAndSettle();
    await tester.drag(find.byType(CustomScrollView), const Offset(0, -1000));
    await tester.pumpAndSettle();
    expect(find.text('Belum ada transaksi'), findsOneWidget);
  });

  testWidgets('retry tren (error state -> tap Coba Lagi -> refetch)', (tester) async {
    reportingRepo.throwTrendError = true;
    
    await tester.pumpWidget(createWidget());
    await tester.pumpAndSettle();

    expect(find.text('Gagal memuat tren'), findsOneWidget);
    // Find multiple "Coba Lagi" since report also fails
    expect(find.text('Coba Lagi'), findsWidgets);

    reportingRepo.throwTrendError = false; 
    reportingRepo.fakeTrend = [
      SalesTrendPoint(date: DateTime(2023, 10, 1), totalSales: 15000, transactionCount: 2),
    ];
    
    // Tap specifically on trend retry button
    // The trend retry button is in the _buildTrendSection which is likely above or below report
    await tester.tap(find.text('Coba Lagi').last); 
    await tester.pumpAndSettle();

    expect(find.text('Gagal memuat tren'), findsNothing);
    expect(find.text('15k'), findsOneWidget);
  });

  testWidgets('SalesBarChart render dengan data', (WidgetTester tester) async {
    final trendData = [
      SalesTrendPoint(date: DateTime(2023, 10, 1), totalSales: 15000, transactionCount: 2),
      SalesTrendPoint(date: DateTime(2023, 10, 2), totalSales: 0, transactionCount: 0),
    ];

    await tester.pumpWidget(MaterialApp(
      home: Scaffold(body: SalesBarChart(trendData: trendData)),
    ));

    expect(find.text('15k'), findsOneWidget);
    expect(find.text('01/10'), findsOneWidget);
    expect(find.text('02/10'), findsOneWidget);
    expect(find.byType(Container), findsWidgets); // bars
  });

  testWidgets('SalesBarChart render "Belum ada data penjualan" saat semua 0', (WidgetTester tester) async {
    final trendData = [
      SalesTrendPoint(date: DateTime(2023, 10, 1), totalSales: 0, transactionCount: 0),
      SalesTrendPoint(date: DateTime(2023, 10, 2), totalSales: 0, transactionCount: 0),
    ];

    await tester.pumpWidget(MaterialApp(
      home: Scaffold(body: SalesBarChart(trendData: trendData)),
    ));

    expect(find.text('Belum ada data penjualan'), findsOneWidget);
  });
}
