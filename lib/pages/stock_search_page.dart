import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/stock_provider.dart';
import '../models/stock.dart';
import '../components/stock_chart.dart';
import '../utils/number_formatter.dart';
import 'buy_sell_page.dart';

// Define the providers at the top level
final symbolProvider = StateProvider<String?>((ref) => null);
final timeRangeProvider = StateProvider<String>((ref) => '1W');

class StockSearchPage extends ConsumerStatefulWidget {
  @override
  _StockSearchPageState createState() => _StockSearchPageState();
}

class _StockSearchPageState extends ConsumerState<StockSearchPage> {
  final _symbolController = TextEditingController();

  @override
  void dispose() {
    _symbolController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final stockAsyncValue = ref.watch(stockProvider);
    final currentSymbol = ref.watch(symbolProvider); // Access the symbol value
    final selectedTimeRange = ref.watch(timeRangeProvider); // Access the time range value

    // Keep the symbol in the controller when re-entering the screen
    _symbolController.text = currentSymbol ?? '';

    return Scaffold(
      appBar: AppBar(
        title: Text('Search for Stocks'),
        backgroundColor: Colors.blueAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildSymbolInput(),
            SizedBox(height: 20),
            _buildTimeRangeSelector(),
            SizedBox(height: 20),
            stockAsyncValue.when(
              data: (stocks) {
                if (stocks.isEmpty) {
                  return Text('No data available for the entered symbol.');
                }
                final stock = stocks.first;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildStockDetails(stock),
                    SizedBox(height: 20),
                    _buildStockChart(stock),
                    SizedBox(height: 20),
                    _buildBuySellButtons(stock),
                  ],
                );
              },
              loading: () => Center(child: CircularProgressIndicator()),
              error: (error, stack) => Text('Error fetching stock data: $error'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSymbolInput() {
    return TextField(
      controller: _symbolController,
      decoration: InputDecoration(
        labelText: 'Enter Stock Symbol',
        border: OutlineInputBorder(),
        suffixIcon: IconButton(
          icon: Icon(Icons.search),
          onPressed: _onSearch,
        ),
      ),
      onSubmitted: (_) => _onSearch(),
    );
  }

  Widget _buildTimeRangeSelector() {
    return DropdownButton<String>(
      value: ref.watch(timeRangeProvider),
      items: _timeRanges.keys.map((timeRange) {
        return DropdownMenuItem<String>(
          value: timeRange,
          child: Text(timeRange),
        );
      }).toList(),
      onChanged: (value) {
        if (value != null) {
          ref.read(timeRangeProvider.notifier).state = value; // Update time range value
          // Update the graph if symbol exists
          if (ref.read(symbolProvider) != null) {
            _onSearch();
          }
        }
      },
      hint: Text('Select Time Range'),
    );
  }

  void _onSearch() {
    final symbol = _symbolController.text.trim().toUpperCase();
    if (symbol.isNotEmpty) {
      ref.read(symbolProvider.notifier).state = symbol; // Update symbol value
      ref.read(stockProvider.notifier).clearStockData(); // Clear previous stock data
      ref.read(stockProvider.notifier).searchStock(symbol, ref.read(timeRangeProvider));
    }
  }

  Widget _buildStockDetails(Stock stock) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Stock: ${stock.symbol}',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        Text(
          'Current Price: ${NumberFormatter.formatCurrency(stock.currentPrice)}',
          style: TextStyle(fontSize: 18),
        ),
      ],
    );
  }

  Widget _buildStockChart(Stock stock) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Price History - ${ref.watch(timeRangeProvider)}',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 10),
        StockChart(
          priceHistory: stock.priceHistory,
          timeRange: ref.watch(timeRangeProvider),
        ),
      ],
    );
  }

  Widget _buildBuySellButtons(Stock stock) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => BuySellPage(
                  stockSymbol: stock.symbol,
                  currentPrice: stock.currentPrice,
                  isBuying: true,
                ),
              ),
            );
          },
          child: Text('Buy'),
          style: ElevatedButton.styleFrom(primary: Colors.green),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => BuySellPage(
                  stockSymbol: stock.symbol,
                  currentPrice: stock.currentPrice,
                  isBuying: false,
                ),
              ),
            );
          },
          child: Text('Sell'),
          style: ElevatedButton.styleFrom(primary: Colors.red),
        ),
      ],
    );
  }

  final Map<String, String> _timeRanges = {
    '1W': '1W',
    '1M': '1M',
    '3M': '3M',
    '6M': '6M',
    '1Y': '1Y',
  };
}