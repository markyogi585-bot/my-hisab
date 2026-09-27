import 'package:flutter/material.dart';
import '../data/local/database_service.dart';
import '../models/transaction_model.dart';
import '../models/transaction_filter.dart';

class TransactionRepository {
  final DatabaseService _db;

  TransactionRepository(this._db);

  Future<void> addTransaction(TransactionModel tx) async {
    await _db.insertTransaction(tx);
  }

  Future<void> updateTransaction(TransactionModel tx) async {
    await _db.updateTransaction(tx);
  }

  Future<void> deleteTransaction(String id) async {
    await _db.deleteTransaction(id);
  }

  Future<TransactionModel?> getTransactionById(String id) async {
    return await _db.getTransactionById(id);
  }

  Future<List<TransactionModel>> getRecentTransactions({int limit = 5}) async {
    return await _db.getRecentTransactions(limit: limit);
  }

  Future<List<TransactionModel>> getTransactions({
    TransactionFilter filter = const TransactionFilter(),
  }) async {
    return await _db.getAllTransactions(filter: filter);
  }

  Future<Map<String, double>> getTotals({DateTimeRange? dateRange}) async {
    return await _db.getTotals(dateRange: dateRange);
  }

  Future<Map<String, double>> getCategoryExpenseDistribution({DateTimeRange? dateRange}) async {
    return await _db.getCategoryExpenseDistribution(dateRange: dateRange);
  }

  Future<void> seedData() async {
    await _db.seedInitialData();
  }

  Future<void> clearAll() async {
    await _db.clearAllData();
  }
}
