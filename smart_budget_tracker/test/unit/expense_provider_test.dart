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
      throw Exception('database failure');
    }
    return List.of(_expenses);
  }

  @override
  Future<int> addExpense(Expense expense) async {
    if (shouldThrow) {
      throw Exception('database failure');
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
      throw Exception('database failure');
    }

    _expenses.removeWhere((expense) => expense.id == id);
    return 1;
  }
}

void main() {
  group('ExpenseProvider', () {
    late FakeExpenseRepository repository;
    late ExpenseProvider provider;

    setUp(() {
      repository = FakeExpenseRepository();
      provider = ExpenseProvider(
        repository: repository,
        errorHandler: ErrorHandler(),
      );
    });

    test('loadExpenses success updates expenses list', () async {
      final expenses = [
        Expense(
          id: 1,
          amount: 100.0,
          category: 'Food',
          date: DateTime.now(),
          note: 'Groceries',
        ),
      ];

      repository = FakeExpenseRepository(expenses);
      provider = ExpenseProvider(repository: repository, errorHandler: ErrorHandler());

      await provider.loadExpenses();

      expect(provider.errorMessage, isNull);
      expect(provider.expenses, expenses);
    });

    test('loadExpenses failure sets errorMessage', () async {
      repository = FakeExpenseRepository()..shouldThrow = true;
      provider = ExpenseProvider(repository: repository, errorHandler: ErrorHandler());

      await provider.loadExpenses();

      expect(provider.expenses, isEmpty);
      expect(provider.errorMessage, isNotNull);
    });

    test('addExpense calls repository and refreshes list', () async {
      final expense = Expense(
        amount: 28.0,
        category: 'Transport',
        date: DateTime.now(),
        note: 'Taxi',
      );

      await provider.addExpense(expense);

      expect(provider.expenses, hasLength(1));
      expect(provider.expenses.first.note, 'Taxi');
    });
  });
}
