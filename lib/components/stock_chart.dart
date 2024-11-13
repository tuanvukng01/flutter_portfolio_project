import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class StockChart extends StatelessWidget {
  final List<Map<String, dynamic>> priceHistory;
  final String timeRange;

  const StockChart({
    required this.priceHistory,
    required this.timeRange,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 250,
      child: LineChart(
        LineChartData(
          lineBarsData: [
            LineChartBarData(
              spots: _generateSpots(),
              isCurved: timeRange != '1D',
              colors: [Colors.blue],
              dotData: FlDotData(show: false),
              belowBarData: BarAreaData(
                show: true,
                colors: [Colors.blue.withOpacity(0.2)],
              ),
            ),
          ],
          titlesData: FlTitlesData(
            leftTitles: SideTitles(
              showTitles: true,
              reservedSize: 60, // Increase space for left labels
              margin: 10,
              interval: _calculateLeftInterval(),
              getTitles: (value) => "\$${value.toStringAsFixed(2)}",
              getTextStyles: (context, value) => TextStyle(
                color: Colors.grey[700],
                fontSize: 12,
              ),
            ),
            topTitles: SideTitles(showTitles: false),
            rightTitles: SideTitles(showTitles: false),
            bottomTitles: SideTitles(
              showTitles: true,
              reservedSize: 20,
              margin: 10,
              interval: _getInterval(),
              getTitles: (value) {
                final index = value.toInt();
                if (index >= 0 && index < priceHistory.length) {
                  final date = DateTime.parse(priceHistory[index]["date"]);
                  return "${date.month}/${date.day}";
                }
                return '';
              },
              getTextStyles: (context, value) => TextStyle(
                color: Colors.grey[700],
                fontSize: 12,
              ),
            ),
          ),
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: _calculateLeftInterval(),
            getDrawingHorizontalLine: (value) => FlLine(
              color: Colors.grey.withOpacity(0.3),
              strokeWidth: 1,
            ),
          ),
          borderData: FlBorderData(
            show: true,
            border: Border(
              top: BorderSide.none,
              right: BorderSide.none,
              left: BorderSide(color: Colors.grey[300]!),
              bottom: BorderSide(color: Colors.grey[300]!),
            ),
          ),
          lineTouchData: LineTouchData(enabled: true),
        ),
      ),
    );
  }

  List<FlSpot> _generateSpots() {
    final List<FlSpot> spots = [];
    int interval = _getInterval().toInt();
    for (int i = 0; i < priceHistory.length; i += interval) {
      final price = priceHistory[i]["close"] as double;
      spots.add(FlSpot(i.toDouble(), price));
    }
    return spots;
  }

  double _getInterval() {
    switch (timeRange) {
      case '1W':
        return 1;
      case '1M':
        return 3;
      case '3M':
        return 7;
      case '6M':
        return 14;
      case '1Y':
        return 30;
      default:
        return 1;
    }
  }

  double _calculateLeftInterval() {
    final maxPrice = priceHistory.map((e) => e["close"] as double).reduce((a, b) => a > b ? a : b);
    final minPrice = priceHistory.map((e) => e["close"] as double).reduce((a, b) => a < b ? a : b);
    final range = maxPrice - minPrice;
    return (range / 5).ceilToDouble(); // Use ceiling to avoid overlap
  }
}