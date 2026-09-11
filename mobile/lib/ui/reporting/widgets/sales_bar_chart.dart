import 'package:flutter/material.dart';
import '../../../domain/reporting/entities/sales_trend_point.dart';

class SalesBarChart extends StatelessWidget {
  final List<SalesTrendPoint> trendData;

  const SalesBarChart({
    super.key,
    required this.trendData,
  });

  @override
  Widget build(BuildContext context) {
    if (trendData.isEmpty) {
      return const SizedBox.shrink();
    }

    final maxSales = trendData.fold<double>(0, (max, point) => point.totalSales > max ? point.totalSales : max);

    if (maxSales == 0) {
      return const SizedBox(
        height: 150,
        child: Center(
          child: Text(
            'Belum ada data penjualan',
            style: TextStyle(color: Colors.grey),
          ),
        ),
      );
    }

    return SizedBox(
      height: 200, // 150 for bar + 50 for labels
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: trendData.map((point) {
          double barHeight = 0;
          if (point.totalSales > 0) {
            barHeight = (point.totalSales / maxSales) * 150;
            if (barHeight < 4) barHeight = 4;
          }

          return Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              if (point.totalSales > 0)
                Text(
                  '${(point.totalSales / 1000).toStringAsFixed(0)}k',
                  style: const TextStyle(fontSize: 10, color: Colors.black54),
                ),
              const SizedBox(height: 4),
              Container(
                width: 32,
                height: barHeight,
                decoration: BoxDecoration(
                  color: Colors.green.shade400,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '${point.date.day.toString().padLeft(2, '0')}/${point.date.month.toString().padLeft(2, '0')}',
                style: const TextStyle(fontSize: 10),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }
}
