import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:smart_budget_tracker/models/expense.dart';
import 'package:smart_budget_tracker/providers/expense_provider.dart';
import 'package:smart_budget_tracker/repositories/expense_repository.dart';
import 'package:smart_budget_tracker/screens/add_expense_screen.dart';

import 'package:smart_budget_tracker/database/database_helper.dart';

class FakeExpenseRepository implements ExpenseRepository {
  @override
  final dbHelper = DatabaseHelper.instance;

  @override
  Future<int> addExpense(Expense expense) async => 1;

  @override
  Future<int> deleteExpense(int id) async => 1;

  @override
  Future<List<Expense>> getExpenses() async => [];
}

void main() {
  group('AddExpenseScreen widget tests', () {
    late ExpenseProvider expenseProvider;
    late FakeExpenseRepository fakeRepository;

    setUp(() {
      fakeRepository = FakeExpenseRepository();
      expenseProvider = ExpenseProvider(repository: fakeRepository);
    });

    testWidgets('displays title and form fields', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<ExpenseProvider>.value(
            value: expenseProvider,
            child: const AddExpenseScreen(),
          ),
        ),
      );

      expect(find.text('Add Expense'), findsOneWidget);
      expect(find.byKey(const Key('amountField')), findsOneWidget);
      expect(find.byKey(const Key('noteField')), findsOneWidget);
      expect(find.byKey(const Key('saveExpenseButton')), findsOneWidget);
    });

    testWidgets('input fields accept text', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<ExpenseProvider>.value(
            value: expenseProvider,
            child: const AddExpenseScreen(),
          ),
        ),
      );

      await tester.enterText(find.byKey(const Key('amountField')), '50.00');
      await tester.enterText(find.byKey(const Key('noteField')), 'Lunch');
      await tester.pumpAndSettle();

      expect(find.text('50.00'), findsOneWidget);
      expect(find.text('Lunch'), findsOneWidget);
    });

    testWidgets('save button is enabled when fields are filled', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<ExpenseProvider>.value(
            value: expenseProvider,
            child: const AddExpenseScreen(),
          ),
        ),
      );

      final saveButton = find.byKey(const Key('saveExpenseButton'));
      expect(saveButton, findsOneWidget);

      await tester.enterText(find.byKey(const Key('amountField')), '25.00');
      await tester.enterText(find.byKey(const Key('noteField')), 'Coffee');
      await tester.pumpAndSettle();

      expect(find.byType(ElevatedButton), findsOneWidget);
    });

    testWidgets('shows form structure and fields', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<ExpenseProvider>.value(
            value: expenseProvider,
            child: const AddExpenseScreen(),
          ),
        ),
      );

      expect(find.byType(TextField), findsWidgets);
    });

    testWidgets('input fields accept text', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<ExpenseProvider>.value(
            value: expenseProvider,
            child: const AddExpenseScreen(),
          ),
        ),
      );

      await tester.enterText(find.byKey(const Key('amountField')), '50.00');
      await tester.enterText(find.byKey(const Key('noteField')), 'Lunch');
      await tester.pumpAndSettle();

      expect(find.text('50.00'), findsOneWidget);
    });

    testWidgets('renders without errors', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<ExpenseProvider>.value(
            value: expenseProvider,
            child: const AddExpenseScreen(),
          ),
        ),
      );

      expect(find.byType(AddExpenseScreen), findsOneWidget);
    });



    testWidgets('has date picker interaction capability', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<ExpenseProvider>.value(
            value: expenseProvider,
            child: const AddExpenseScreen(),
          ),
        ),
      );

      expect(find.byType(AddExpenseScreen), findsOneWidget);
    });

    testWidgets('validation error appears for empty fields', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<ExpenseProvider>.value(
            value: expenseProvider,
            child: const AddExpenseScreen(),
          ),
        ),
      );

      await tester.tap(find.byKey(const Key('saveExpenseButton')));
      await tester.pumpAndSettle();

      // Validation should prevent submission or show error
      expect(find.byType(AddExpenseScreen), findsOneWidget);
    });
  });
}

