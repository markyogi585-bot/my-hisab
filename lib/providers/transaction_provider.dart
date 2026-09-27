import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/transaction_model.dart';
import 'database_provider.dart';
import 'filter_provider.dart';
import 'category_provider.dart';

class TransactionListNotifier extends StateNotifier<AsyncValue<List<TransactionModel>>> {
  final Ref _ref;

  TransactionListNotifier(this._ref) : super(const AsyncValue.loading()) {
    loadTransactions();
  }

  Future<void> loadTransactions() async {
    state = const AsyncValue.loading();
    try {
      final repo = _ref.read(transactionRepositoryProvider);
      final filter = _ref.read(transactionFilterProvider);
      final transactions = await repo.getTransactions(filter: filter);
      state = AsyncValue.data(transactions);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> addTransaction(TransactionModel tx) async {
    final repo = _ref.read(transactionRepositoryProvider);
    await repo.addTransaction(tx);
    await _ref.read(categoryListProvider.notifier).loadCategories();
    await loadTransactions();
    _ref.invalidate(recentTransactionsProvider);
  }

  Future<void> updateTransaction(TransactionModel tx) async {
    final repo = _ref.read(transactionRepositoryProvider);
    await repo.updateTransaction(tx);
    await _ref.read(categoryListProvider.notifier).loadCategories();
    await loadTransactions();
    _ref.invalidate(recentTransactionsProvider);
  }

  Future<void> deleteTransaction(String id) async {
    final repo = _ref.read(transactionRepositoryProvider);
    await repo.deleteTransaction(id);
    await _ref.read(categoryListProvider.notifier).loadCategories();
    await loadTransactions();
    _ref.invalidate(recentTransactionsProvider);
  }

  Future<void> reloadAll() async {
    await loadTransactions();
    _ref.invalidate(recentTransactionsProvider);
  }
}

final transactionListProvider =
    StateNotifierProvider<TransactionListNotifier, AsyncValue<List<TransactionModel>>>((ref) {
  // Watch filter so whenever filter changes, list automatically refreshes
  ref.watch(transactionFilterProvider);
  return TransactionListNotifier(ref);
});

final recentTransactionsProvider = FutureProvider<List<TransactionModel>>((ref) async {
  final repo = ref.watch(transactionRepositoryProvider);
  return await repo.getRecentTransactions(limit: 5);
});
