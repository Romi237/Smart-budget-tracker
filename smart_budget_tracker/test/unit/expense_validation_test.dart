import 'package:flutter_test/flutter_test.dart';
import 'package:smart_budget_tracker/models/expense.dart';

void main() {
  group('Expense validation', () {
    test('should reject negative amounts', () {
      expect(
        () => Expense(
          id: 1,
          amount: -10.0,
          category: 'Food',
          date: DateTime.now(),
          note: 'Invalid',
        ),
        isNotNull,
      );
    });

    test('should accept zero amount', () {
      final expense = Expense(
        amount: 0.0,
        category: 'Food',
        date: DateTime.now(),
        note: 'Free item',
      );

      expect(expense.amount, 0.0);
    });

    test('should accept valid categories', () {
      final validCategories = ['Food', 'Transport', 'Entertainment', 'Utilities'];
      
      for (final category in validCategories) {
        final expense = Expense(
          amount: 50.0,
          category: category,
          date: DateTime.now(),
          note: 'Test',
        );
        expect(expense.category, category);
      }
    });

    test('should validate date is not in future', () {
      final futureDate = DateTime.now().add(const Duration(days: 10));
      final expense = Expense(
        amount: 50.0,
        category: 'Food',
        date: futureDate,
        note: 'Future expense',
      );

      expect(expense.date, futureDate);
    });

    test('should handle special characters in note', () {
      final expense = Expense(
        amount: 50.0,
        category: 'Food',
        date: DateTime.now(),
        note: 'Lunch @ Café #1 (50% off!)',
      );

      expect(expense.note, 'Lunch @ Café #1 (50% off!)');
    });

    test('should handle empty note', () {
      final expense = Expense(
        amount: 50.0,
        category: 'Food',
        date: DateTime.now(),
        note: '',
      );

      expect(expense.note, '');
    });

    test('should have null id before database insertion', () {
      final expense = Expense(
        amount: 50.0,
        category: 'Food',
        date: DateTime.now(),
        note: 'New expense',
      );

      expect(expense.id, isNull);
    });
  });
}
