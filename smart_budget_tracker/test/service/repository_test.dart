import 'package:flutter_test/flutter_test.dart';
import 'package:smart_budget_tracker/models/expense.dart';
import 'package:smart_budget_tracker/repositories/expense_repository.dart';

class FakeExpenseRepository extends ExpenseRepository {
  final List<Expense> _storage = [];

  @override
  Future<int> addExpense(Expense expense) async {
    final id = _storage.isEmpty ? 1 : (_storage.last.id ?? 0) + 1;
    _storage.add(Expense(
      id: id,
      amount: expense.amount,
      category: expense.category,
      date: expense.date,
      note: expense.note,
    ));
    return id;
  }

  @override
  Future<List<Expense>> getExpenses() async {
    return List.unmodifiable(_storage);
  }

  @override
  Future<int> deleteExpense(int id) async {
    _storage.removeWhere((expense) => expense.id == id);
    return 1;
  }
}

void main() {
  group('ExpenseRepository fake storage', () {
    late FakeExpenseRepository repository;

    setUp(() {
      repository = FakeExpenseRepository();
    });

    test('should fetch expenses from memory storage', () async {
      final expenses = await repository.getExpenses();

      expect(expenses, isA<List<Expense>>());
      expect(expenses, isEmpty);
    });

    test('should add expense to memory storage', () async {
      final expense = Expense(
        amount: 50.0,
        category: 'Food',
        date: DateTime(2026, 4, 14),
        note: 'Lunch',
      );

      final id = await repository.addExpense(expense);

      expect(id, isA<int>());
      expect(await repository.getExpenses(), hasLength(1));
    });

    test('should delete expense by id', () async {
      final expense = Expense(
        amount: 25.0,
        category: 'Transport',
        date: DateTime(2026, 4, 14),
        note: 'Bus',
      );

      final id = await repository.addExpense(expense);
      final result = await repository.deleteExpense(id);

      expect(result, 1);
      expect(await repository.getExpenses(), isEmpty);
    });

    test('should maintain data consistency after operations', () async {
      final expense1 = Expense(
        amount: 50.0,
        category: 'Food',
        date: DateTime(2026, 4, 14),
        note: 'Lunch',
      );

      final expense2 = Expense(
        amount: 25.0,
        category: 'Transport',
        date: DateTime(2026, 4, 14),
        note: 'Bus',
      );

      await repository.addExpense(expense1);
      await repository.addExpense(expense2);

      final expenses = await repository.getExpenses();

      expect(expenses, hasLength(2));
      expect(expenses.map((e) => e.note), containsAll(['Lunch', 'Bus']));
    });
  });
}
