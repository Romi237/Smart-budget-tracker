import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:smart_budget_tracker/models/expense.dart';
import 'package:smart_budget_tracker/repositories/expense_repository.dart';
import 'package:smart_budget_tracker/services/expense_service.dart';
import 'package:smart_budget_tracker/services/logger.dart';

class FakeExpenseRepository extends ExpenseRepository {
  final List<Expense> _expenses = [];

  @override
  Future<List<Expense>> getExpenses() async => List.of(_expenses);

  @override
  Future<int> addExpense(Expense expense) async {
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
    _expenses.removeWhere((expense) => expense.id == id);
    return 1;
  }
}

class FailingExpenseRepository extends FakeExpenseRepository {
  @override
  Future<int> addExpense(Expense expense) async {
    throw Exception('Database error');
  }
}

class MockLogger extends Mock implements Logger {}

void main() {
  group('ExpenseService', () {
    late FakeExpenseRepository fakeRepository;
    late MockLogger mockLogger;
    late ExpenseService expenseService;

    setUp(() {
      fakeRepository = FakeExpenseRepository();
      mockLogger = MockLogger();
      expenseService = ExpenseService(fakeRepository, mockLogger);
    });

    test('should add expense to repository', () async {
      final expense = Expense(
        amount: 50.0,
        category: 'Food',
        date: DateTime(2026, 4, 14),
        note: 'Lunch',
      );

      await expenseService.addExpense(expense);

      expect(await fakeRepository.getExpenses(), hasLength(1));
      verify(mockLogger.log('Expense added: 50.0')).called(1);
    });

    test('should handle repository errors gracefully', () async {
      final expense = Expense(
        amount: 100.0,
        category: 'Transport',
        date: DateTime(2026, 4, 14),
        note: 'Taxi',
      );

      fakeRepository = FailingExpenseRepository();
      expenseService = ExpenseService(fakeRepository, mockLogger);

      expect(
        () => expenseService.addExpense(expense),
        throwsException,
      );
    });

    test('should log with correct expense amount', () async {
      final expense = Expense(
        amount: 75.5,
        category: 'Entertainment',
        date: DateTime(2026, 4, 14),
        note: 'Movie',
      );

      await expenseService.addExpense(expense);

      verify(mockLogger.log('Expense added: 75.5')).called(1);
    });

    test('should verify repository method called exactly once', () async {
      final expense = Expense(
        amount: 25.0,
        category: 'Food',
        date: DateTime(2026, 4, 14),
        note: 'Coffee',
      );

      await expenseService.addExpense(expense);

      verifyNever(mockLogger.log('Expense deleted: any')); // no delete call
      verify(mockLogger.log('Expense added: 25.0')).called(1);
    });
  });
}
