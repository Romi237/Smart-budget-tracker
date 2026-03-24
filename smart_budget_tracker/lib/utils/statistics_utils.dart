import '../models/expense.dart';

class StatisticsUtils {
  static Map<String, double> categoryTotals(List<Expense> expenses) {
    Map<String, double> totals = {};

    for (var expense in expenses) {
      totals.update(
        expense.category,
        (value) => value + expense.amount,
        ifAbsent: () => expense.amount,
      );
    }

    return totals;
  }
}
