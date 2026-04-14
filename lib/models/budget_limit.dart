// lib/models/budget_limit.dart
class BudgetLimit {
  final String category;
  final double limit;

  const BudgetLimit({required this.category, required this.limit});

  double percentUsed(double spent) => spent / limit;
  bool isExceeded(double spent) => spent >= limit;
  bool isWarning(double spent) => percentUsed(spent) >= 0.75 && !isExceeded(spent);
}

// Default monthly budget limits (XAF)
const List<BudgetLimit> defaultBudgets = [
  BudgetLimit(category: 'Food', limit: 30000),
  BudgetLimit(category: 'Transport', limit: 15000),
  BudgetLimit(category: 'Housing', limit: 80000),
  BudgetLimit(category: 'Health', limit: 10000),
  BudgetLimit(category: 'Education', limit: 20000),
];
