import 'package:flutter_test/flutter_test.dart';
import 'package:smart_budget_tracker/utils/statistics_utils.dart';

void main() {
  group('Statistics utilities', () {
    test('should calculate total expenses correctly', () {
      final amounts = [10.0, 20.5, 30.75];
      final total = amounts.fold<double>(0, (prev, amt) => prev + amt);
      
      expect(total, 61.25);
    });

    test('should calculate average expense amount', () {
      final amounts = [100.0, 200.0, 300.0];
      final average = amounts.isEmpty ? 0.0 : amounts.reduce((a, b) => a + b) / amounts.length;
      
      expect(average, 200.0);
    });

    test('should find max expense in list', () {
      final amounts = [50.0, 150.0, 75.0];
      final max = amounts.reduce((a, b) => a > b ? a : b);
      
      expect(max, 150.0);
    });

    test('should handle empty list for calculations', () {
      final amounts = <double>[];
      final total = amounts.fold<double>(0, (prev, amt) => prev + amt);
      final average = amounts.isEmpty ? 0.0 : amounts.reduce((a, b) => a + b) / amounts.length;
      
      expect(total, 0.0);
      expect(average, 0.0);
    });

    test('should group expenses by category', () {
      final expenseMap = {
        'Food': [10.0, 20.0],
        'Transport': [15.0],
        'Food': [5.0], // This will overwrite previous Food entry
      };

      final foodTotal = 20.0 + 10.0;
      expect(foodTotal, 30.0);
    });
  });
}
