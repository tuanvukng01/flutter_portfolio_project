import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/stock.dart';
import '../utils/api_constants.dart';

class StockApiService {
  Future<Stock> fetchStock(String symbol) async {
    try {
      // Make a single call to the backend to retrieve current price and historical data
      final url = Uri.parse('$apiBaseUrl/api/stock?symbol=$symbol');
      final response = await http.get(url);

      print('Stock API URL: $url');
      print('Response Status: ${response.statusCode}');
      print('Response Body: ${response.body}');

      if (response.statusCode != 200) {
        throw Exception('Failed to load stock data');
      }

      // Parse the JSON response
      final data = json.decode(response.body);

      // Extract the current price and price history
      final double currentPrice = (data['currentPrice'] as num).toDouble();
      final List<Map<String, dynamic>> priceHistory = List<Map<String, dynamic>>.from(
        data['priceHistory'].map((entry) => {
          "date": entry['date'] as String,
          "close": (entry['close'] as num).toDouble(),
        })
      );

      // Return a Stock instance with parsed data
      return Stock(
        symbol: symbol,
        currentPrice: currentPrice,
        priceHistory: priceHistory,
      );
    } catch (error) {
      print('Error fetching stock data: $error');
      throw Exception('Failed to load stock data');
    }
  }
}