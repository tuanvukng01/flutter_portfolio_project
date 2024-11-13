import 'stock.dart';

class Portfolio {
  final List<Stock> stocks;
  final double availableFunds;
  final double totalValue;

  Portfolio({
    required this.stocks,
    required this.availableFunds,
    required this.totalValue,
  });

  double calculateTotalValue() {
    final totalValue = stocks.fold(0.0, (sum, stock) => sum + (stock.currentPrice * stock.quantity));
    print("Calculated Portfolio Total Value: $totalValue");  // Log the calculated value
    return totalValue;
  }

  // Method to create a copy of the portfolio with modified properties
  Portfolio copyWith({
    List<Stock>? stocks,
    double? availableFunds,
    double? totalValue,
  }) {
    return Portfolio(
      stocks: stocks ?? this.stocks,
      availableFunds: availableFunds ?? this.availableFunds,
      totalValue: totalValue ?? this.totalValue,
    );
  }

  factory Portfolio.fromJson(Map<String, dynamic> json) {
    return Portfolio(
      stocks: List<Stock>.from(json['stocks']?.map((stock) => Stock.fromJson(stock)) ?? []),
      availableFunds: (json['availableFunds'] ?? 0.0).toDouble(),
      totalValue: (json['totalValue'] ?? 0.0).toDouble(),
    );
  }
}