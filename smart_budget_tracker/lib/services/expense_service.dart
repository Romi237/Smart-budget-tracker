import '../models/expense.dart';
import '../repositories/expense_repository.dart';
import 'logger.dart';

class ExpenseService {
  final ExpenseRepository repository;
  final Logger logger;

  ExpenseService(this.repository, this.logger);

  Future<void> addExpense(Expense expense) async {
    await repository.addExpense(expense);

    logger.log("Expense added: ${expense.amount}");
  }
}
