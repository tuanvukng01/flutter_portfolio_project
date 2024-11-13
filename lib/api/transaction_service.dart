import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/transaction.dart';
import '../utils/api_constants.dart';

class TransactionService {
  final String _baseUrl = apiBaseUrl;

  // Fetch transaction history from the backend API
  Future<List<Transaction>> fetchTransactionHistory(String userId) async {
    final url = Uri.parse('$_baseUrl/api/transaction?userId=$userId');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      List<dynamic> jsonList = json.decode(response.body);
      return jsonList.map((data) => Transaction.fromJson(data)).toList();
    } else {
      print('Error fetching transaction history: ${response.statusCode}');
      throw Exception('Failed to load transaction history');
    }
  }

  // Record a new transaction to the backend API
  Future<void> recordTransaction(String userId, Transaction transaction) async {
    final url = Uri.parse('$_baseUrl/api/transaction');
    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        'userId': userId,
        'stockSymbol': transaction.stockSymbol,
        'quantity': transaction.quantity,
        'price': transaction.price,
        'date': transaction.date.toIso8601String(),
        'isBuy': transaction.isBuy,
      }),
    );

    if (response.statusCode != 201) {  // Expecting 201 for successful creation
      print('Error recording transaction: ${response.statusCode}');
      throw Exception('Failed to record transaction');
    } else {
      print('Transaction recorded successfully.');
    }
  }
}