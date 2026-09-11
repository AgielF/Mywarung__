import 'dart:io';
import 'package:path_provider/path_provider.dart';
import '../../domain/reporting/entities/sales_trend_point.dart';

class CsvExporter {
  static String dailyReportToCsv(List<SalesTrendPoint> trend) {
    final StringBuffer buffer = StringBuffer();
    // Header
    buffer.writeln('Tanggal,Total Penjualan,Jumlah Transaksi');
    
    // Rows
    for (final point in trend) {
      final dateStr = '${point.date.year}-${point.date.month.toString().padLeft(2, '0')}-${point.date.day.toString().padLeft(2, '0')}';
      final totalStr = point.totalSales.toStringAsFixed(0); // Optional: no decimals for currency or use toString()
      final countStr = point.transactionCount.toString();
      
      buffer.writeln('${escapeField(dateStr)},${escapeField(totalStr)},${escapeField(countStr)}');
    }
    
    return buffer.toString();
  }

  static String escapeField(String field) {
    if (field.contains(',') || field.contains('"') || field.contains('\n')) {
      return '"${field.replaceAll('"', '""')}"';
    }
    return field;
  }

  static Future<String> writeToFile(String csv, [String? filename]) async {
    final now = DateTime.now();
    final defaultFilename = 'laporan_penjualan_${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}_${now.hour.toString().padLeft(2, '0')}${now.minute.toString().padLeft(2, '0')}${now.second.toString().padLeft(2, '0')}.csv';
    final name = filename ?? defaultFilename;

    final directory = await getApplicationDocumentsDirectory();
    final path = '${directory.path}/$name';
    final file = File(path);
    
    await file.writeAsString(csv);
    return path;
  }
}
