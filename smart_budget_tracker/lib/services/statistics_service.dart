import '../models/expense.dart';

class StatisticsService {
  double calculateTotal(
    List<Expense> expenses,
    double Function(Expense) selector,
  ) {
    double total = 0;

    for (var expense in expenses) {
      total += selector(expense);
    }

    return total;
  }
}
