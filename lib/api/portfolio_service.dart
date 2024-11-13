import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/portfolio.dart';
import '../models/stock.dart';
import '../utils/api_constants.dart';

class PortfolioService {
  Portfolio? _portfolio;

  Future<Portfolio> fetchPortfolio(String userId) async {
    final url = Uri.parse('$apiBaseUrl/api/portfolio?userId=$userId');
    print('Fetching portfolio from: $url');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      
      // Extract portfolio details from the API response structure
      final portfolioData = data['portfolio'];
      
      // Map stocks in the portfolio to Stock model objects
      final List<Stock> stocks = (portfolioData['stocks'] as List)
          .map((stockData) => Stock(
                symbol: stockData['symbol'],
                quantity: stockData['quantity'],
                currentPrice: stockData['currentPrice'].toDouble(),
                priceHistory: List<Map<String, dynamic>>.from(stockData['priceHistory']),
              ))
          .toList();

      // Create a Portfolio instance from parsed data
      return Portfolio(
        stocks: stocks,
        availableFunds: portfolioData['availableFunds'].toDouble(),
        totalValue: portfolioData['totalValue'].toDouble(),
      );
    } else {
      throw Exception('Failed to load portfolio');
    }
  }

  Future<void> buyStock(String userId, String symbol, int quantity, double currentPrice) async {
    final url = Uri.parse('$apiBaseUrl/api/portfolio');
    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: json.encode({
        "userId": userId,
        "action": "buy",
        "symbol": symbol,
        "quantity": quantity,
        "currentPrice": currentPrice,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to buy stock');
    }
  }

  Future<void> sellStock(String userId, String symbol, int quantity, double currentPrice) async {
    final url = Uri.parse('$apiBaseUrl/api/portfolio');
    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: json.encode({
        "userId": userId,
        "action": "sell",
        "symbol": symbol,
        "quantity": quantity,
        "currentPrice": currentPrice,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to sell stock');
    }
  }
}