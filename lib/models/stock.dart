class Stock {
  final String symbol;
  final double currentPrice;
  final double? marketCap;
  final double? volume;
  final double? peRatio;
  final List<Map<String, dynamic>> priceHistory;  // Stores date and close price
  int quantity;

  Stock({
    required this.symbol,
    required this.currentPrice,
    this.marketCap,
    this.volume,
    this.peRatio,
    required this.priceHistory,
    this.quantity = 0,
  });

  // Factory constructor for creating Stock from JSON data
  factory Stock.fromJson(Map<String, dynamic> json) {
    return Stock(
      symbol: json['symbol'],
      currentPrice: (json['price'] ?? 0.0).toDouble(),
      marketCap: (json['marketCap'] ?? 0.0)?.toDouble(),
      volume: (json['volume'] ?? 0.0)?.toDouble(),
      peRatio: (json['peRatio'] ?? 0.0)?.toDouble(),
      priceHistory: List<Map<String, dynamic>>.from(json['priceHistory']),
      quantity: json['quantity'] ?? 0,
    );
  }

  // Updated copyWith to accept priceHistory as a parameter
  Stock copyWith({int? quantity, List<Map<String, dynamic>>? priceHistory}) {
    return Stock(
      symbol: symbol,
      currentPrice: currentPrice,
      marketCap: marketCap,
      volume: volume,
      peRatio: peRatio,
      priceHistory: priceHistory ?? this.priceHistory,
      quantity: quantity ?? this.quantity,
    );
  }

  // Method to get filtered price history based on the time range
  List<Map<String, dynamic>> getFilteredHistory(String timeRange) {
    DateTime cutoffDate;
    switch (timeRange) {
      case '1D':
        cutoffDate = DateTime.now().subtract(Duration(days: 1));
        break;
      case '1W':
        cutoffDate = DateTime.now().subtract(Duration(days: 7));
        break;
      case '1M':
        cutoffDate = DateTime.now().subtract(Duration(days: 30));
        break;
      case '3M':
        cutoffDate = DateTime.now().subtract(Duration(days: 90));
        break;
      case '6M':
        cutoffDate = DateTime.now().subtract(Duration(days: 180));
        break;
      case '1Y':
      default:
        return priceHistory;  // Return full history for 1 year
    }
    
    // Return only entries after the cutoff date
    return priceHistory.where((entry) {
      final date = DateTime.parse(entry['date']);
      return date.isAfter(cutoffDate);
    }).toList();
  }
}