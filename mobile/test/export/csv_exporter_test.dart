import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pos_warung_ai/domain/reporting/entities/sales_trend_point.dart';
import 'package:pos_warung_ai/infrastructure/export/csv_exporter.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
      const MethodChannel('plugins.flutter.io/path_provider'),
      (MethodCall methodCall) async {
        return '.';
      },
    );
  });
  test('dailyReportToCsv dengan 3 SalesTrendPoint -> format baris benar', () {
    final trend = [
      SalesTrendPoint(date: DateTime(2023, 10, 1), totalSales: 15000, transactionCount: 3),
      SalesTrendPoint(date: DateTime(2023, 10, 2), totalSales: 0, transactionCount: 0),
      SalesTrendPoint(date: DateTime(2023, 10, 3), totalSales: 20500, transactionCount: 5),
    ];

    final csv = CsvExporter.dailyReportToCsv(trend);
    final lines = csv.trim().split('\n');
    
    expect(lines.length, 4); // 1 header + 3 rows
    expect(lines[0], 'Tanggal,Total Penjualan,Jumlah Transaksi');
    expect(lines[1], '2023-10-01,15000,3');
    expect(lines[2], '2023-10-02,0,0');
    expect(lines[3], '2023-10-03,20500,5');
  });

  test('escape kalau ada koma di data (edge case)', () {
    expect(CsvExporter.escapeField('Hello'), 'Hello');
    expect(CsvExporter.escapeField('Hello, World'), '"Hello, World"');
    expect(CsvExporter.escapeField('Hello "World"'), '"Hello ""World"""');
    expect(CsvExporter.escapeField('Hello\nWorld'), '"Hello\nWorld"');
  });

  test('CsvExporter.writeToFile returns path berakhiran .csv', () async {
    final path = await CsvExporter.writeToFile('Test,CSV\n1,2');
    expect(path.isNotEmpty, isTrue);
    expect(path.endsWith('.csv'), isTrue);
  });
}
