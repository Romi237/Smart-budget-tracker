import 'package:smart_budget_tracker/models/expense.dart';
import 'package:smart_budget_tracker/repositories/expense_repository.dart';

/// Test helper functions and fixtures for Flutter tests
class TestFixtures {
  /// Create a sample expense for testing
  static Expense createSampleExpense({
    int? id,
    double amount = 50.0,
    String category = 'Food',
    DateTime? date,
    String note = 'Test expense',
  }) {
    return Expense(
      id: id,
      amount: amount,
      category: category,
      date: date ?? DateTime(2026, 4, 14),
      note: note,
    );
  }

  /// Create a list of sample expenses
  static List<Expense> createMultipleSampleExpenses(int count) {
    return List.generate(
      count,
      (index) => Expense(
        id: index + 1,
        amount: 10.0 + (index * 5),
        category: ['Food', 'Transport', 'Entertainment', 'Utilities'][index % 4],
        date: DateTime(2026, 4, 14).subtract(Duration(days: index)),
        note: 'Test expense ${index + 1}',
      ),
    );
  }

  /// Create a fake repository for testing
  static FakeExpenseRepository createFakeRepository({
    List<Expense>? initialExpenses,
  }) {
    return FakeExpenseRepository(initialExpenses ?? []);
  }
}

/// Fake repository implementation for unit tests
class FakeExpenseRepository implements ExpenseRepository {
  final List<Expense> expenses;

  FakeExpenseRepository(this.expenses);

  @override
  late final dbHelper = null; // Not used in tests

  @override
  Future<int> addExpense(Expense expense) async {
    final newExpense = Expense(
      id: expenses.isEmpty ? 1 : (expenses.last.id ?? 0) + 1,
      amount: expense.amount,
      category: expense.category,
      date: expense.date,
      note: expense.note,
    );
    expenses.add(newExpense);
    return newExpense.id ?? 1;
  }

  @override
  Future<int> deleteExpense(int id) async {
    expenses.removeWhere((e) => e.id == id);
    return 1;
  }

  @override
  Future<List<Expense>> getExpenses() async => expenses;
}
