import 'package:flutter/material.dart';
import '../models/stock.dart';
import '../utils/number_formatter.dart';

class StockDetailPage extends StatelessWidget {
  final Stock stock;

  const StockDetailPage({required this.stock});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${stock.symbol} Details'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Stock: ${stock.symbol}',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            _buildStockDetails(),
            SizedBox(height: 20),
            _buildPriceHistory(),
          ],
        ),
      ),
    );
  }

  Widget _buildStockDetails() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Current Price: ${NumberFormatter.formatCurrency(stock.currentPrice)}'),
        Text('Market Cap: ${NumberFormatter.formatCurrency(stock.marketCap ?? 0)}'),
        Text('Volume: ${NumberFormatter.formatNumber(stock.volume ?? 0)}'),
        Text('P/E Ratio: ${stock.peRatio?.toStringAsFixed(2) ?? 'N/A'}'),
      ],
    );
  }

  Widget _buildPriceHistory() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Price History:',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        // Use the StockChart component here or similar chart widget
        Container(
          height: 200,
          child: Center(
            child: Text('Price History Chart (Placeholder)'),
          ),
        ),
      ],
    );
  }
}