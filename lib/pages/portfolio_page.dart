import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/portfolio_provider.dart';
import '../providers/user_provider.dart';
import '../utils/number_formatter.dart';

class PortfolioPage extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final portfolioAsyncValue = ref.watch(portfolioProvider);
    final userAsyncValue = ref.watch(userProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('My Portfolio'),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () {
              ref.read(portfolioProvider.notifier).loadPortfolio('user123');
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            userAsyncValue.when(
              data: (user) {
                if (user == null) {
                  // Handle the case where user is null (e.g., display a message or default values)
                  return _buildHeaderWithIndicators(
                    context,
                    availableFunds: 0.0, // Default value when user is null
                    portfolioTotal: 0.0, // Default portfolio total
                  );
                }

                return portfolioAsyncValue.when(
                  data: (portfolio) => _buildHeaderWithIndicators(
                    context,
                    availableFunds: user.availableFunds, // Null check for availableFunds
                    portfolioTotal: portfolio.totalValue,
                  ),
                  loading: () => CircularProgressIndicator(),
                  error: (e, stack) => Text('Error loading portfolio value: $e'),
                );
              },
              loading: () => CircularProgressIndicator(),
              error: (error, stack) => Text('Error loading user data: $error'),
            ),
            SizedBox(height: 20),
            portfolioAsyncValue.when(
              data: (portfolio) {
                return Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Your Stocks',
                        style: Theme.of(context).textTheme.headline6,
                      ),
                      SizedBox(height: 10),
                      Expanded(
                        child: ListView.builder(
                          itemCount: portfolio.stocks.length,
                          itemBuilder: (context, index) {
                            final stock = portfolio.stocks[index];
                            return _buildStockCard(stock);
                          },
                        ),
                      ),
                    ],
                  ),
                );
              },
              loading: () => Center(child: CircularProgressIndicator()),
              error: (error, stack) => Text('Error loading portfolio: $error'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderWithIndicators(
    BuildContext context, {
    required double availableFunds,
    required double portfolioTotal,
  }) {
    final stockValue = portfolioTotal - availableFunds;
    final fundsProportion = availableFunds / portfolioTotal;
    final stocksProportion = stockValue / portfolioTotal;

    return Center(
      child: Container(
        constraints: BoxConstraints(maxWidth: 600), // Control max width for central alignment
        child: Card(
          elevation: 3,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          color: Theme.of(context).primaryColorLight.withOpacity(0.9),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 12.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                // Available Funds component
                Expanded(
                  child: _buildStatCard(
                    label: 'Available Funds',
                    value: availableFunds,
                  ),
                ),
                // Total Portfolio Value component
                Expanded(
                  child: _buildStatCard(
                    label: 'Portfolio Value',
                    value: portfolioTotal,
                  ),
                ),
                // Circular indicator for Funds
                Expanded(
                  child: _buildCircularIndicator(
                    proportion: fundsProportion,
                    color: Colors.blue,
                    label: 'Funds',
                    size: 70, // Increased size
                  ),
                ),
                // Circular indicator for Stocks
                Expanded(
                  child: _buildCircularIndicator(
                    proportion: stocksProportion,
                    color: Colors.green,
                    label: 'Stocks',
                    size: 70, // Increased size
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Helper widget for compact stat cards
  Widget _buildStatCard({required String label, required double value}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.min, // Compact height
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 16, color: Colors.grey[700]),
        ),
        SizedBox(height: 4),
        Text(
          NumberFormatter.formatCurrency(value),
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
        ),
      ],
    );
  }

  // Build a circular proportion indicator
  Widget _buildCircularIndicator({
    required double proportion,
    required Color color,
    required String label,
    double size = 50, // Make size adjustable
  }) {
    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              width: size,
              height: size,
              child: CircularProgressIndicator(
                value: proportion,
                strokeWidth: 6,
                color: color,
              ),
            ),
            Text(
              '${(proportion * 100).toStringAsFixed(1)}%',
              style: TextStyle(fontSize: size / 5), // Adjust font size based on size
            ),
          ],
        ),
        SizedBox(height: 4),
        Text(label, style: TextStyle(fontSize: 14)),
      ],
    );
  }

  Widget _buildStockCard(stock) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  stock.symbol,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Text(
                  'Shares: ${stock.quantity}',
                  style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                ),
              ],
            ),
            SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Current Price: ${NumberFormatter.formatCurrency(stock.currentPrice)}',
                  style: TextStyle(fontSize: 16),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'Price History',
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    ),
                    Text(
                      stock.priceHistory.take(5).map((entry) {
                        final date = DateTime.parse(entry['date']);
                        final formattedDate = "${date.month}/${date.day}";
                        final price = NumberFormatter.formatCurrency(entry['close']);
                        return "$formattedDate: $price";
                      }).join(", "),
                      style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}