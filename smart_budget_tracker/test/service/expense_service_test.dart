import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:smart_budget_tracker/models/expense.dart';
import 'package:smart_budget_tracker/repositories/expense_repository.dart';
import 'package:smart_budget_tracker/services/expense_service.dart';
import 'package:smart_budget_tracker/services/logger.dart';

class MockExpenseRepository extends Mock implements ExpenseRepository {}
class MockLogger extends Mock implements Logger {}

void main() {
  late MockExpenseRepository mockRepository;
  late MockLogger mockLogger;
  late ExpenseService service;

  setUp(() {
    mockRepository = MockExpenseRepository();
    mockLogger = MockLogger();
    service = ExpenseService(mockRepository, mockLogger);
  });

  test('addExpense calls repository and logger', () async {
    final expense = Expense(
      amount: 42.0,
      category: 'Health',
      date: DateTime.now(),
      note: 'Doctor visit',
    );

    when(mockRepository.addExpense(expense)).thenAnswer((_) async => 1);

    await service.addExpense(expense);

    verify(mockRepository.addExpense(expense)).called(1);
    verify(mockLogger.log('Expense added: ${expense.amount}')).called(1);
  });
}
