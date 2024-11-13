import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../api/portfolio_service.dart';
import '../models/portfolio.dart';
import 'user_provider.dart'; // Adjusted import path for consistency

final portfolioProvider = StateNotifierProvider<PortfolioNotifier, AsyncValue<Portfolio>>((ref) {
  return PortfolioNotifier(ref.read);
});

class PortfolioNotifier extends StateNotifier<AsyncValue<Portfolio>> {
  final PortfolioService _portfolioService = PortfolioService();
  final Reader _read;

  PortfolioNotifier(this._read) : super(const AsyncValue.loading()) {
    loadPortfolio('user123'); // Automatically load the portfolio
  }

  Future<void> loadPortfolio(String userId) async {
    try {
      state = const AsyncValue.loading();
      final portfolio = await _portfolioService.fetchPortfolio(userId);
      state = AsyncValue.data(portfolio);

      // Update the user’s total value in UserNotifier based on new portfolio data
      _read(userProvider.notifier).loadUser(userId, updatedFunds: portfolio.availableFunds);
    } catch (e) {
      state = AsyncValue.error(e);
    }
  }

  Future<void> buyStock(String userId, String symbol, int quantity, double currentPrice) async {
    try {
      await _portfolioService.buyStock(userId, symbol, quantity, currentPrice);
      await loadPortfolio(userId); // Reload portfolio after buying

      // Update the user’s available funds and total value in UserNotifier
      final portfolio = state.value;
      if (portfolio != null) {
        _read(userProvider.notifier).loadUser(userId, updatedFunds: portfolio.availableFunds);
      }
    } catch (e) {
      state = AsyncValue.error(e);
    }
  }

  Future<void> sellStock(String userId, String symbol, int quantity, double currentPrice) async {
    try {
      await _portfolioService.sellStock(userId, symbol, quantity, currentPrice);
      await loadPortfolio(userId); // Reload portfolio after selling

      // Update the user’s available funds and total value in UserNotifier
      final portfolio = state.value;
      if (portfolio != null) {
        _read(userProvider.notifier).loadUser(userId, updatedFunds: portfolio.availableFunds);
      }
    } catch (e) {
      state = AsyncValue.error(e);
    }
  }

  
}