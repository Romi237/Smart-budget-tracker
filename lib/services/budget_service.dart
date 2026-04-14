// lib/services/budget_service.dart
// Core business logic for the budget tracker.
// This is the class that unit tests exercise directly.

import '../models/transaction.dart';

class BudgetService {
  // ── Balance Calculations ──────────────────────────────────────────────────

  /// Returns total income from a list of transactions.
  double calculateTotalIncome(List<Transaction> transactions) {
    return transactions
        .where((t) => t.isIncome)
        .fold(0.0, (sum, t) => sum + t.amount);
  }

  /// Returns total expenses from a list of transactions.
  double calculateTotalExpenses(List<Transaction> transactions) {
    return transactions
        .where((t) => t.isExpense)
        .fold(0.0, (sum, t) => sum + t.amount);
  }

  /// Returns current balance (income - expenses).
  double calculateBalance(List<Transaction> transactions) {
    return calculateTotalIncome(transactions) -
        calculateTotalExpenses(transactions);
  }

  // ── Filtering ─────────────────────────────────────────────────────────────

  /// Filters transactions by type.
  List<Transaction> filterByType(
    List<Transaction> transactions,
    TransactionType type,
  ) {
    return transactions.where((t) => t.type == type).toList();
  }

  /// Filters transactions by category.
  List<Transaction> filterByCategory(
    List<Transaction> transactions,
    String category,
  ) {
    return transactions
        .where((t) => t.category.toLowerCase() == category.toLowerCase())
        .toList();
  }

  // ── Analytics ─────────────────────────────────────────────────────────────

  /// Returns a map of category -> total spent (expenses only).
  Map<String, double> spendingByCategory(List<Transaction> transactions) {
    final Map<String, double> result = {};
    for (final t in transactions.where((t) => t.isExpense)) {
      result[t.category] = (result[t.category] ?? 0) + t.amount;
    }
    return result;
  }

  /// Returns spending for a specific month.
  List<Transaction> transactionsForMonth(
    List<Transaction> transactions,
    int year,
    int month,
  ) {
    return transactions
        .where((t) => t.date.year == year && t.date.month == month)
        .toList();
  }

  // ── Validation ────────────────────────────────────────────────────────────

  /// Returns true if the amount is a valid positive number.
  bool isValidAmount(double amount) => amount > 0 && amount.isFinite;

  /// Returns true if the description is non-empty.
  bool isValidDescription(String description) => description.trim().isNotEmpty;

  /// Returns true if the date is not in the future.
  bool isValidDate(DateTime date) =>
      !date.isAfter(DateTime.now().add(const Duration(days: 1)));

  /// Returns null if valid, or an error message string.
  String? validateTransaction({
    required double amount,
    required String description,
    required DateTime date,
    required String category,
  }) {
    if (!isValidAmount(amount)) return 'Amount must be a positive number.';
    if (!isValidDescription(description)) return 'Description cannot be empty.';
    if (category.trim().isEmpty) return 'Category is required.';
    return null; // null = valid
  }

  // ── Budget Checking ───────────────────────────────────────────────────────

  /// Returns the percentage (0.0–1.0+) of budget used for a category.
  double budgetUsagePercent(
    List<Transaction> transactions,
    String category,
    double budgetLimit,
    int year,
    int month,
  ) {
    if (budgetLimit <= 0) return 0;
    final monthlyTx = transactionsForMonth(transactions, year, month);
    final spent = spendingByCategory(monthlyTx)[category] ?? 0;
    return spent / budgetLimit;
  }

  /// Returns true if spending in a category exceeds the budget limit.
  bool isBudgetExceeded(
    List<Transaction> transactions,
    String category,
    double budgetLimit,
    int year,
    int month,
  ) {
    return budgetUsagePercent(
          transactions, category, budgetLimit, year, month) >=
        1.0;
  }

  // ── Sorting ───────────────────────────────────────────────────────────────

  /// Sorts transactions by date, most recent first.
  List<Transaction> sortByDateDesc(List<Transaction> transactions) {
    final sorted = List<Transaction>.from(transactions);
    sorted.sort((a, b) => b.date.compareTo(a.date));
    return sorted;
  }

  /// Sorts transactions by amount, highest first.
  List<Transaction> sortByAmountDesc(List<Transaction> transactions) {
    final sorted = List<Transaction>.from(transactions);
    sorted.sort((a, b) => b.amount.compareTo(a.amount));
    return sorted;
  }
}
