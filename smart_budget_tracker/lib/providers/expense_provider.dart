import 'package:flutter/material.dart';
import '../models/expense.dart';
import '../repositories/expense_repository.dart';
import '../services/error_handler.dart';

class ExpenseProvider extends ChangeNotifier {
  final ExpenseRepository repository;
  final ErrorHandler errorHandler;

  ExpenseProvider({ExpenseRepository? repository, ErrorHandler? errorHandler})
      : repository = repository ?? ExpenseRepository(),
        errorHandler = errorHandler ?? ErrorHandler();

  List<Expense> _expenses = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<Expense> get expenses => _expenses;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> init() async {
    await loadExpenses();
  }

  Future<void> loadExpenses() async {
    _setLoading(true);
    _clearError();

    try {
      _expenses = await repository.getExpenses();
      _sortExpensesByDate();
      notifyListeners();
    } catch (e) {
      _setError('Failed to load expenses: ${errorHandler.handleError(e)}');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> addExpense(Expense expense) async {
    _setLoading(true);
    _clearError();

    try {
      await repository.addExpense(expense);
      await loadExpenses();
    } catch (e) {
      _setError('Failed to add expense: ${errorHandler.handleError(e)}');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> deleteExpense(int id) async {
    _setLoading(true);
    _clearError();

    try {
      await repository.deleteExpense(id);
      await loadExpenses();
    } catch (e) {
      _setError('Failed to delete expense: ${errorHandler.handleError(e)}');
    } finally {
      _setLoading(false);
    }
  }

  void _sortExpensesByDate() {
    _expenses.sort((a, b) => b.date.compareTo(a.date));
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String message) {
    _errorMessage = message;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
  }

  void clearError() {
    _clearError();
    notifyListeners();
  }

  double getTotalExpenses() {
    return _expenses.fold(0, (sum, expense) => sum + expense.amount);
  }

  Map<String, double> getCategoryTotals() {
    Map<String, double> totals = {};
    for (var expense in _expenses) {
      totals.update(
        expense.category,
        (value) => value + expense.amount,
        ifAbsent: () => expense.amount,
      );
    }
    return totals;
  }
}
