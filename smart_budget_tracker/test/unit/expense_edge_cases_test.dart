import 'package:flutter_test/flutter_test.dart';
import 'package:smart_budget_tracker/models/expense.dart';

void main() {
  group('Expense edge case tests', () {
    test('should handle very large amounts', () {
      final expense = Expense(
        amount: 999999999.99,
        category: 'Other',
        date: DateTime.now(),
        note: 'Large expense',
      );

      expect(expense.amount, 999999999.99);
    });

    test('should handle decimal precision', () {
      final expense = Expense(
        amount: 123.456789,
        category: 'Food',
        date: DateTime.now(),
        note: 'Decimal test',
      );

      expect(expense.amount, 123.456789);
    });

    test('should handle very old dates', () {
      final oldDate = DateTime(1900, 1, 1);
      final expense = Expense(
        amount: 50.0,
        category: 'Historical',
        date: oldDate,
        note: 'Old expense',
      );

      expect(expense.date, oldDate);
    });

    test('should handle notes with unicode characters', () {
      final expense = Expense(
        amount: 50.0,
        category: 'Food',
        date: DateTime.now(),
        note: '日本語 السلام 中文 العربية',
      );

      expect(expense.note, '日本語 السلام 中文 العربية');
    });

    test('should handle very long note strings', () {
      final longNote = 'Note ' * 1000;
      final expense = Expense(
        amount: 50.0,
        category: 'Food',
        date: DateTime.now(),
        note: longNote,
      );

      expect(expense.note.length, greaterThan(1000));
    });

    test('should serialize and deserialize large amounts', () {
      final original = Expense(
        id: 1,
        amount: 5000.50,
        category: 'Business',
        date: DateTime(2026, 4, 14),
        note: 'Large transaction',
      );

      final map = original.toMap();
      final restored = Expense.fromMap(map);

      expect(restored.amount, original.amount);
      expect(restored.category, original.category);
    });
  });
}
