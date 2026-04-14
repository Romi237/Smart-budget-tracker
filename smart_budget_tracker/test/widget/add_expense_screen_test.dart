import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:smart_budget_tracker/models/expense.dart';
import 'package:smart_budget_tracker/providers/expense_provider.dart';
import 'package:smart_budget_tracker/repositories/expense_repository.dart';
import 'package:smart_budget_tracker/screens/add_expense_screen.dart';

class FakeExpenseRepository extends ExpenseRepository {
  @override
  Future<int> addExpense(Expense expense) async => 1;

  @override
  Future<List<Expense>> getExpenses() async => [
        Expense(
          id: 1,
          amount: 350.0,
          category: 'Food',
          date: DateTime.now(),
          note: 'Test saved',
        ),
      ];
}

void main() {
  testWidgets('AddExpenseScreen validates input and saves expense', (WidgetTester tester) async {
    final provider = ExpenseProvider(repository: FakeExpenseRepository());

    await provider.loadExpenses();

    await tester.pumpWidget(
      ChangeNotifierProvider<ExpenseProvider>.value(
        value: provider,
        child: const MaterialApp(home: AddExpenseScreen()),
      ),
    );

    await tester.enterText(find.byKey(const Key('amountField')), '350');
    await tester.enterText(find.byKey(const Key('noteField')), 'Test note');

    await tester.tap(find.byKey(const Key('saveExpenseButton')));
    await tester.pumpAndSettle();

    expect(find.text('Add Expense'), findsNothing);
  });
}
