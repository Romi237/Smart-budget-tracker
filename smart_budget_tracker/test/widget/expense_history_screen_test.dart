import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:smart_budget_tracker/models/expense.dart';
import 'package:smart_budget_tracker/providers/expense_provider.dart';
import 'package:smart_budget_tracker/repositories/expense_repository.dart';
import 'package:smart_budget_tracker/screens/expense_history_screen.dart';

class FakeExpenseRepository extends ExpenseRepository {
  final List<Expense> _expenses;

  FakeExpenseRepository([List<Expense>? initialExpenses])
      : _expenses = List.of(initialExpenses ?? []);

  @override
  Future<List<Expense>> getExpenses() async => List.unmodifiable(_expenses);

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

void main() {
  testWidgets('ExpenseHistoryScreen shows expenses and deletes an item', (WidgetTester tester) async {
    final expenses = [
      Expense(
        id: 1,
        amount: 90.0,
        category: 'Transport',
        date: DateTime.now(),
        note: 'Bus fare',
      ),
    ];

    final fakeRepo = FakeExpenseRepository(expenses);
    final provider = ExpenseProvider(repository: fakeRepo);
    await provider.loadExpenses();

    await tester.pumpWidget(
      ChangeNotifierProvider<ExpenseProvider>.value(
        value: provider,
        child: const MaterialApp(home: ExpenseHistoryScreen()),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Expense History'), findsOneWidget);
    expect(find.text('Bus fare'), findsOneWidget);
    expect(find.text('Transport'), findsOneWidget);
  }
  });
}
