import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:smart_budget_tracker/models/expense.dart';
import 'package:smart_budget_tracker/repositories/expense_repository.dart';

class MockExpenseRepositoryPerformance extends Mock implements ExpenseRepository {}

void main() {
  group('Performance and stress tests', () {
    test('should handle bulk expense creation', () async {
      final expenses = <Expense>[];

      for (int i = 0; i < 1000; i++) {
        expenses.add(
          Expense(
            id: i,
            amount: 10.0 + (i % 100),
            category: ['Food', 'Transport', 'Entertainment', 'Utilities'][i % 4],
            date: DateTime(2026, 4, 14).subtract(Duration(days: i % 365)),
            note: 'Expense $i',
          ),
        );
      }

      expect(expenses.length, 1000);
    });

    test('should efficiently sort large expense lists', () {
      final expenses = <Expense>[];

      for (int i = 0; i < 500; i++) {
        expenses.add(
          Expense(
            id: i,
            amount: (i * 1.5).toDouble(),
            category: 'Mixed',
            date: DateTime(2026, 4, 14).subtract(Duration(days: i)),
            note: 'Expense $i',
          ),
        );
      }

      final stopwatch = Stopwatch()..start();
      expenses.sort((a, b) => b.date.compareTo(a.date));
      stopwatch.stop();

      expect(stopwatch.elapsedMilliseconds, lessThan(1000));
    });

    test('should handle concurrent serialization', () async {
      final expense = Expense(
        id: 1,
        amount: 100.0,
        category: 'Test',
        date: DateTime.now(),
        note: 'Concurrent test',
      );

      final futures = <Future<Map<String, dynamic>>>[];

      for (int i = 0; i < 100; i++) {
        futures.add(Future.value(expense.toMap()));
      }

      final results = await Future.wait(futures);

      expect(results.length, 100);
      for (final result in results) {
        expect(result['amount'], 100.0);
      }
    });

    test('should batch process expenses', () {
      final expenses = <Expense>[];

      for (int i = 0; i < 250; i++) {
        expenses.add(
          Expense(
            id: i,
            amount: 5.0 + (i % 50),
            category: 'Batch',
            date: DateTime.now(),
            note: 'Batch item $i',
          ),
        );
      }

      const batchSize = 50;
      final batches = <List<Expense>>[];

      for (int i = 0; i < expenses.length; i += batchSize) {
        batches.add(
          expenses.sublist(i, (i + batchSize).clamp(0, expenses.length)),
        );
      }

      expect(batches.length, 5);
    });
  });
}
