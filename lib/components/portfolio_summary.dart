import 'package:flutter/material.dart';
import '../utils/number_formatter.dart';

class PortfolioSummary extends StatelessWidget {
  final double availableFunds;
  final double totalValue;

  const PortfolioSummary({
    required this.availableFunds,
    required this.totalValue,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Available Funds: ${NumberFormatter.formatCurrency(availableFunds)}',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        Text(
          'Total Portfolio Value: ${NumberFormatter.formatCurrency(totalValue)}',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}