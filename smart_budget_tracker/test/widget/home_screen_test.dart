import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:smart_budget_tracker/models/expense.dart';
import 'package:smart_budget_tracker/providers/expense_provider.dart';
import 'package:smart_budget_tracker/repositories/expense_repository.dart';
import 'package:smart_budget_tracker/screens/home_screen.dart';

class FakeExpenseRepository extends ExpenseRepository {
  final List<Expense> expenses;

  FakeExpenseRepository(this.expenses);

  @override
  Future<List<Expense>> getExpenses() async => expenses;
}

void main() {
  testWidgets('HomeScreen renders summary and categories', (WidgetTester tester) async {
    final expenses = [
      Expense(
        id: 1,
        amount: 150.0,
        category: 'Food',
        date: DateTime.now(),
        note: 'Dinner',
      ),
    ];

    final provider = ExpenseProvider(
      repository: FakeExpenseRepository(expenses),
    );

    await provider.loadExpenses();

    await tester.pumpWidget(
      ChangeNotifierProvider<ExpenseProvider>.value(
        value: provider,
        child: const MaterialApp(home: HomeScreen()),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Smart Budget Tracker'), findsOneWidget);
    expect(find.text('Total Expenses'), findsOneWidget);
    expect(find.text('150.00 FCFA'), findsWidgets);
    expect(find.text('Food'), findsOneWidget);
  });
}
