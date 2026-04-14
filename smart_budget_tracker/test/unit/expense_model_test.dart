import 'package:flutter_test/flutter_test.dart';
import 'package:smart_budget_tracker/models/expense.dart';

void main() {
  group('Expense model', () {
    test('converts to map and back correctly', () {
      final expense = Expense(
        id: 5,
        amount: 120.5,
        category: 'Food',
        date: DateTime.parse('2026-04-14T12:00:00'),
        note: 'Lunch with team',
      );

      final map = expense.toMap();

      expect(map['id'], 5);
      expect(map['amount'], 120.5);
      expect(map['category'], 'Food');
      expect(map['note'], 'Lunch with team');
      expect(map['date'], '2026-04-14T12:00:00.000');

      final fromMap = Expense.fromMap(map);

      expect(fromMap.id, expense.id);
      expect(fromMap.amount, expense.amount);
      expect(fromMap.category, expense.category);
      expect(fromMap.note, expense.note);
      expect(fromMap.date, expense.date);
    });

    test('handles missing id and preserves note values', () {
      final expense = Expense(
        amount: 50.0,
        category: 'Transport',
        date: DateTime(2026, 4, 15),
        note: '',
      );

      expect(expense.id, isNull);
      expect(expense.note, '');
      expect(expense.amount, 50.0);
    });
  });
}
