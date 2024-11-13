class Transaction {
  final String stockSymbol;
  final int quantity;
  final double price;
  final DateTime date;
  final bool isBuy;  // Ensure isBuy is included

  Transaction({
    required this.stockSymbol,
    required this.quantity,
    required this.price,
    required this.date,
    required this.isBuy,
  });

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      stockSymbol: json['symbol'] ?? '',  // Fallback to an empty string if null
      quantity: json['quantity'] ?? 0,     // Fallback to 0 if null
      price: (json['price'] ?? 0.0).toDouble(),  // Fallback to 0.0 if null
      date: DateTime.tryParse(json['date'] ?? '') ?? DateTime.now(),  // Fallback to current date if null or parse error
      isBuy: json['isBuy'] ?? false,       // Fallback to false if null
    );
  }
}