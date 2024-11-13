import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../api/transaction_service.dart';
import '../models/transaction.dart';
import 'user_provider.dart'; // Import user provider for dynamic user ID access

final transactionProvider = StateNotifierProvider<TransactionNotifier, AsyncValue<List<Transaction>>>((ref) {
  return TransactionNotifier(ref.read);
});

class TransactionNotifier extends StateNotifier<AsyncValue<List<Transaction>>> {
  final TransactionService _transactionService = TransactionService();
  final Reader _read;

  TransactionNotifier(this._read) : super(const AsyncValue.loading()) {
    _initLoad();
  }

  Future<void> _initLoad() async {
    final userId = _read(userProvider).value?.id ?? 'defaultUser';  // Use dynamic user ID or fallback
    if (userId.isNotEmpty) {
      await loadTransactionHistory(userId);
    } else {
      print("Error: No valid user ID.");
      state = AsyncValue.error("Invalid user ID: Cannot load transaction history.");
    }
  }

  Future<void> loadTransactionHistory(String userId) async {
    if (userId.isEmpty) {
      print("Error: userId cannot be empty.");
      state = AsyncValue.error("Invalid user ID.");
      return;
    }

    try {
      print("Loading transaction history for user: $userId");
      state = const AsyncValue.loading();
      final transactions = await _transactionService.fetchTransactionHistory(userId);
      print("Fetched ${transactions.length} transactions for user: $userId");
      state = AsyncValue.data(transactions);
    } catch (e) {
      print("Error loading transaction history: $e");
      state = AsyncValue.error(e);
    }
  }

  Future<void> recordTransaction(String userId, Transaction transaction) async {
    if (userId.isEmpty) {
      print("Error: userId cannot be empty.");
      state = AsyncValue.error("Invalid user ID.");
      return;
    }

    try {
      print("Recording transaction for user: $userId");
      await _transactionService.recordTransaction(userId, transaction);
      await loadTransactionHistory(userId);  // Reload history after recording
      print("Transaction recorded and history updated for user: $userId");
    } catch (e) {
      print("Error recording transaction: $e");
      state = AsyncValue.error(e);
    }
  }

  
}