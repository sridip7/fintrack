import 'package:flutter/material.dart';
import '../models/transaction.dart';
import '../models/category.dart';
import '../models/activity_log.dart';
import '../services/database_service.dart';

class TransactionProvider extends ChangeNotifier {
  final DatabaseService _dbService;

  List<Transaction> _transactions = [];
  bool _isLoading = false;

  TransactionProvider(this._dbService);

  List<Transaction> get transactions => _transactions;
  bool get isLoading => _isLoading;

  // Metric: Total Income
  double get totalIncome {
    return _transactions
        .where((t) => t.type == TransactionType.income)
        .fold(0.0, (sum, t) => sum + t.amount);
  }

  // Metric: Total Expense
  double get totalExpenses {
    return _transactions
        .where((t) => t.type == TransactionType.expense)
        .fold(0.0, (sum, t) => sum + t.amount);
  }

  // Metric: Net Balance (Income - Expense)
  double get totalBalance => totalIncome - totalExpenses;

  // Metric: Recent Transactions (last 5 or less)
  List<Transaction> get recentTransactions {
    return _transactions.take(5).toList();
  }

  // Metric: Category Expense Breakdown
  Map<TransactionCategory, double> get categoryExpenses {
    final Map<TransactionCategory, double> breakdown = {};
    
    // Initialize map with all categories having 0.0 expenses
    for (var category in TransactionCategory.values) {
      breakdown[category] = 0.0;
    }

    // Populate with actual expense transaction amounts
    for (var transaction in _transactions) {
      if (transaction.type == TransactionType.expense) {
        breakdown[transaction.category] = 
            (breakdown[transaction.category] ?? 0.0) + transaction.amount;
      }
    }

    return breakdown;
  }

  // Load user transactions from database
  Future<void> loadTransactions(String email) async {
    _isLoading = true;
    notifyListeners();

    try {
      _transactions = await _dbService.getTransactions(email);
    } catch (e) {
      _transactions = [];
    }

    _isLoading = false;
    notifyListeners();
  }

  // Add a new transaction
  Future<void> addTransaction(String email, Transaction transaction) async {
    try {
      await _dbService.saveTransaction(email, transaction);
      
      final action = transaction.isEdited ? 'Edited Transaction' : 'Added Transaction';
      final details = '${transaction.isEdited ? 'Updated' : 'Added'} ${transaction.type == TransactionType.income ? 'income' : 'expense'} "${transaction.title}" of \$${transaction.amount} in ${transaction.category.displayName}.';
      await _dbService.logActivity(email, ActivityLog(action: action, details: details));

      // Update local state
      await loadTransactions(email);
    } catch (e) {
      // Handle or log error
    }
  }

  // Delete a transaction
  Future<void> deleteTransaction(String email, String id) async {
    try {
      final tx = _transactions.firstWhere((t) => t.id == id);
      await _dbService.deleteTransaction(email, id);
      await _dbService.logActivity(email, ActivityLog(
        action: 'Deleted Transaction',
        details: 'Deleted transaction "${tx.title}" of \$${tx.amount}.'
      ));
      await loadTransactions(email);
    } catch (e) {
      // Handle or log error
    }
  }

  // Clear transactions state on logout
  void clearTransactions() {
    _transactions = [];
    notifyListeners();
  }
}
