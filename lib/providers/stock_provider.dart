import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../api/stock_api_service.dart';
import '../models/stock.dart';

final stockProvider = StateNotifierProvider<StockNotifier, AsyncValue<List<Stock>>>((ref) {
  return StockNotifier(ref.read);
});

class StockNotifier extends StateNotifier<AsyncValue<List<Stock>>> {
  final StockApiService _stockApiService = StockApiService();
  final Reader _read;
  Stock? _fullHistoryStock; // Cache for the full history to reduce API calls

  StockNotifier(this._read) : super(const AsyncValue.loading());

  Future<void> searchStock(String symbol, String timeRange) async {
    try {
      state = const AsyncValue.loading();
      print('Searching for stock: $symbol, Time Range: $timeRange');  // Debug output

      // Fetch full history only if it's not cached or if the symbol has changed
      if (_fullHistoryStock == null || _fullHistoryStock!.symbol != symbol) {
        _fullHistoryStock = await _stockApiService.fetchStock(symbol);
        print('Full stock data retrieved: ${_fullHistoryStock!.priceHistory.length} entries');
      }

      // Filter the cached data by the specified time range
      final filteredStock = _fullHistoryStock!.copyWith(
        priceHistory: _fullHistoryStock!.getFilteredHistory(timeRange),
      );

      state = AsyncValue.data([filteredStock]);
    } catch (e) {
      print('Error during stock search: $e');  // Debug output
      state = AsyncValue.error(e);
    }
  }

  void clearStockData() {
    state = const AsyncValue.data([]); // Reset state to an empty list
  }
}