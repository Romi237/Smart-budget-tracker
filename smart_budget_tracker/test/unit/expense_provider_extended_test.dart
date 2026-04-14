import 'package:flutter_test/flutter_test.dart';
import 'package:smart_budget_tracker/models/expense.dart';
import 'package:smart_budget_tracker/providers/expense_provider.dart';
import 'package:smart_budget_tracker/repositories/expense_repository.dart';
import 'package:smart_budget_tracker/services/error_handler.dart';

class FakeExpenseRepository extends ExpenseRepository {
  final List<Expense> _expenses;
  bool shouldThrow = false;

  FakeExpenseRepository([List<Expense>? initialExpenses])
      : _expenses = List.of(initialExpenses ?? []);

  @override
  Future<List<Expense>> getExpenses() async {
    if (shouldThrow) {
      throw Exception('Network error');
    }
    return List.of(_expenses);
  }

  @override
  Future<int> addExpense(Expense expense) async {
    if (shouldThrow) {
      throw Exception('Network error');
    }
    final id = _expenses.isEmpty ? 1 : (_expenses.last.id ?? 0) + 1;
    _expenses.add(Expense(
      id: id,
      amount: expense.amount,
      category: expense.category,
      date: expense.date,
      note: expense.note,
    ));
    return id;
  }

  @override
  Future<int> deleteExpense(int id) async {
    if (shouldThrow) {
      throw Exception('Network error');
    }
    _expenses.removeWhere((expense) => expense.id == id);
    return 1;
  }
}

class SlowExpenseRepository extends FakeExpenseRepository {
  SlowExpenseRepository([List<Expense>? initialExpenses]) : super(initialExpenses);

  @override
  Future<List<Expense>> getExpenses() async {
    await Future.delayed(const Duration(milliseconds: 100));
    return super.getExpenses();
  }
}

void main() {
  group('ExpenseProvider State Management', () {
    late FakeExpenseRepository repository;
    late ErrorHandler errorHandler;
    late ExpenseProvider provider;

    setUp(() {
      repository = FakeExpenseRepository();
      errorHandler = ErrorHandler();
      provider = ExpenseProvider(repository: repository, errorHandler: errorHandler);
    });

    test('initial state should be empty', () {
      expect(provider.expenses, []);
      expect(provider.isLoading, false);
      expect(provider.errorMessage, isNull);
    });

    test('loadExpenses should update expenses list', () async {
      final mockExpenses = [
        Expense(
          id: 1,
          amount: 50.0,
          category: 'Food',
          date: DateTime(2026, 4, 14),
          note: 'Lunch',
        ),
      ];

      repository = FakeExpenseRepository(mockExpenses);
      provider = ExpenseProvider(repository: repository, errorHandler: errorHandler);

      await provider.loadExpenses();

      expect(provider.expenses, mockExpenses);
      expect(provider.isLoading, false);
    });

    test('loadExpenses should handle errors', () async {
      repository.shouldThrow = true;
      provider = ExpenseProvider(repository: repository, errorHandler: errorHandler);

      await provider.loadExpenses();

      expect(provider.errorMessage, isNotNull);
      expect(provider.isLoading, false);
    });

    test('addExpense should call repository and reload', () async {
      final expense = Expense(
        amount: 75.0,
        category: 'Transport',
        date: DateTime(2026, 4, 14),
        note: 'Taxi',
      );

      await provider.addExpense(expense);

      expect(provider.expenses.length, 1);
      expect(provider.expenses.first.note, 'Taxi');
    });

    test('deleteExpense should remove from repository', () async {
      final expense = Expense(
        id: 1,
        amount: 25.0,
        category: 'Transport',
        date: DateTime(2026, 4, 14),
        note: 'Taxi',
      );

      repository = FakeExpenseRepository([expense]);
      provider = ExpenseProvider(repository: repository, errorHandler: errorHandler);

      await provider.deleteExpense(1);

      expect(provider.expenses, isEmpty);
    });

    test('expenses should be sorted by date descending', () async {
      final mockExpenses = [
        Expense(
          id: 1,
          amount: 10.0,
          category: 'Food',
          date: DateTime(2026, 4, 10),
          note: 'Old expense',
        ),
        Expense(
          id: 2,
          amount: 20.0,
          category: 'Food',
          date: DateTime(2026, 4, 15),
          note: 'New expense',
        ),
      ];

      repository = FakeExpenseRepository(mockExpenses);
      provider = ExpenseProvider(repository: repository, errorHandler: errorHandler);

      await provider.loadExpenses();

      expect(provider.expenses.first.date, DateTime(2026, 4, 15));
      expect(provider.expenses.last.date, DateTime(2026, 4, 10));
    });

    test('isLoading should be true during operation', () async {
      final slowRepository = SlowExpenseRepository();
      provider = ExpenseProvider(repository: slowRepository, errorHandler: errorHandler);

      final future = provider.loadExpenses();

      expect(provider.isLoading, true);

      await future;

      expect(provider.isLoading, false);
    });
  });
}
