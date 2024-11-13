import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/portfolio_provider.dart';
import '../providers/user_provider.dart';
import '../utils/number_formatter.dart';
import '../models/user.dart';       // Import User model
import '../models/portfolio.dart';  // Import Portfolio model
import '../models/stock.dart';      // Import Stock model


class BuySellPage extends ConsumerStatefulWidget {
  final String stockSymbol;
  final double currentPrice;
  final bool isBuying;

  BuySellPage({
    required this.stockSymbol,
    required this.currentPrice,
    required this.isBuying,
  });

  @override
  _BuySellPageState createState() => _BuySellPageState();
}

class _BuySellPageState extends ConsumerState<BuySellPage> {
  final _quantityController = TextEditingController();
  double _totalCost = 0;
  String? _errorMessage;

  @override
  void dispose() {
    _quantityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final portfolioAsyncValue = ref.watch(portfolioProvider);
    final userAsyncValue = ref.watch(userProvider);


    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isBuying ? 'Buy Stock' : 'Sell Stock'),
        backgroundColor: widget.isBuying ? Colors.green : Colors.red,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Stock: ${widget.stockSymbol}',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            Text(
              'Current Price: ${NumberFormatter.formatCurrency(widget.currentPrice)}',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 20),
            _buildQuantityInput(),
            SizedBox(height: 20),
            Text(
              'Total: ${NumberFormatter.formatCurrency(_totalCost)}',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            if (_errorMessage != null) ...[
              SizedBox(height: 10),
              Text(
                _errorMessage!,
                style: TextStyle(color: Colors.red, fontSize: 16),
              ),
            ],
            SizedBox(height: 20),
            _buildBuySellButton(userAsyncValue, portfolioAsyncValue),
          ],
        ),
      ),
    );
  }

  Widget _buildQuantityInput() {
    return TextField(
      controller: _quantityController,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        labelText: 'Number of Shares',
        border: OutlineInputBorder(),
      ),
      onChanged: (value) {
        setState(() {
          final quantity = int.tryParse(value) ?? 0;
          _totalCost = quantity * widget.currentPrice;
        });
      },
    );
  }

  Widget _buildBuySellButton(AsyncValue<User?> userAsyncValue, AsyncValue<Portfolio> portfolioAsyncValue) {
  return userAsyncValue.when(
    data: (user) {
      if (user == null) {
        // Display an error or message if user data is not available
        return Text('User data not available.');
      }
      
      if (widget.isBuying) {
        final canProceed = user.availableFunds >= _totalCost && _totalCost > 0;

        return ElevatedButton(
          onPressed: canProceed ? () => _showConfirmationDialog(user) : null,
          child: Text('Buy'),
          style: ElevatedButton.styleFrom(primary: Colors.green),
        );
      } else {
        return portfolioAsyncValue.when(
          data: (portfolio) {
            // Find the stock in the user's portfolio
            final stock = portfolio.stocks.firstWhere(
              (s) => s.symbol == widget.stockSymbol,
              orElse: () => Stock(symbol: widget.stockSymbol, quantity: 0, currentPrice: 0, priceHistory: []),
            );
            final ownedQuantity = stock.quantity;

            // Check if user has enough shares to sell and if quantity is valid
            final canProceed = ownedQuantity >= (int.tryParse(_quantityController.text) ?? 0) && _totalCost > 0;

            return ElevatedButton(
              onPressed: canProceed ? () => _showConfirmationDialog(user, stock) : null,
              child: Text('Sell'),
              style: ElevatedButton.styleFrom(primary: Colors.red),
            );
          },
          loading: () => CircularProgressIndicator(),
          error: (error, stack) => Text('Error loading portfolio: $error'),
        );
      }
    },
    loading: () => CircularProgressIndicator(),
    error: (error, stack) => Text('Error: $error'),
  );
}

  Future<void> _showConfirmationDialog(User user, [Stock? stock]) async {
    final quantity = int.tryParse(_quantityController.text) ?? 0;
    final action = widget.isBuying ? 'Buy' : 'Sell';

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('$action Confirmation'),
        content: Text(
          'Are you sure you want to $action $quantity shares of ${widget.stockSymbol} for a total of ${NumberFormatter.formatCurrency(_totalCost)}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false), // Cancel action
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true), // Confirm action
            child: Text('Confirm'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      if (widget.isBuying) {
        _handleBuy(user);
      } else {
        _handleSell(user, stock!);
      }
    }
  }

  void _handleBuy(User user) async {
    final quantity = int.tryParse(_quantityController.text) ?? 0;
    final totalCost = quantity * widget.currentPrice;
    print("Attempting to buy stock...");
    print("User available funds before purchase: ${user.availableFunds}");
    print("Total cost for ${quantity} shares: $totalCost");

    if (quantity > 0 && user.availableFunds >= totalCost) {
      // Perform the buy action and update portfolio
      await ref.read(portfolioProvider.notifier).buyStock(user.id, widget.stockSymbol, quantity, widget.currentPrice);
      
      // Deduct funds and update the user with new available funds
      final newFunds = user.availableFunds - totalCost;
      print("Updated funds after purchase: $newFunds");
      ref.read(userProvider.notifier).updateFunds(newFunds);
      
      // Reload the user and portfolio to get updated data
      await ref.read(userProvider.notifier).loadUser(user.id, updatedFunds: newFunds);
      await ref.read(portfolioProvider.notifier).loadPortfolio(user.id);

      Navigator.pop(context);  // Go back after transaction
    } else {
      print("Insufficient funds or invalid quantity.");
      setState(() {
        _errorMessage = "Insufficient funds.";
      });
    }
}

  void _handleSell(User user, Stock stock) async {
    final quantity = int.tryParse(_quantityController.text) ?? 0;
    final totalRevenue = quantity * widget.currentPrice;
    print("Attempting to sell stock...");
    print("User available funds before sale: ${user.availableFunds}");
    print("Total revenue for selling $quantity shares: $totalRevenue");

    if (quantity > 0 && quantity <= stock.quantity) {
      // Perform the sell action and update portfolio
      await ref.read(portfolioProvider.notifier).sellStock(user.id, widget.stockSymbol, quantity, widget.currentPrice);
      
      // Add revenue to user funds
      final newFunds = user.availableFunds + totalRevenue;
      print("Updated funds after sale: $newFunds");
      ref.read(userProvider.notifier).updateFunds(newFunds);
      
      // Reload the user and portfolio to get updated data
      await ref.read(userProvider.notifier).loadUser(user.id, updatedFunds: newFunds);
      await ref.read(portfolioProvider.notifier).loadPortfolio(user.id);

      Navigator.pop(context);  // Go back after transaction
    } else {
      print("Insufficient shares or invalid quantity.");
      setState(() {
        _errorMessage = "You do not have enough shares to sell.";
      });
    }
}
}