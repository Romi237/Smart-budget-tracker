
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_budget_tracker/models/transaction.dart';
import 'package:smart_budget_tracker/services/budget_service.dart';

void main() {
  late BudgetService svc;
  late List<Transaction> transactions;

  // ── Setup ────────────────────────────────────────────────────────────────

  setUp(() {
    svc = BudgetService();
    transactions = [
      Transaction(
        id: 't1', type: TransactionType.income, amount: 150000,
        category: 'Salary', description: 'Monthly salary',
        date: DateTime(2026, 4, 1),
      ),
      Transaction(
        id: 't2', type: TransactionType.expense, amount: 12000,
        category: 'Food', description: 'Groceries',
        date: DateTime(2026, 4, 2),
      ),
      Transaction(
        id: 't3', type: TransactionType.expense, amount: 5000,
        category: 'Transport', description: 'Taxi',
        date: DateTime(2026, 4, 3),
      ),
      Transaction(
        id: 't4', type: TransactionType.expense, amount: 25000,
        category: 'Housing', description: 'Electricity',
        date: DateTime(2026, 4, 3),
      ),
      Transaction(
        id: 't5', type: TransactionType.income, amount: 35000,
        category: 'Freelance', description: 'Web project',
        date: DateTime(2026, 4, 4),
      ),
    ];
  });

  // ── Income / Expense Calculation ─────────────────────────────────────────

  group('calculateTotalIncome', () {
    test('returns correct sum of income transactions', () {
      expect(svc.calculateTotalIncome(transactions), 185000.0);
    });

    test('returns 0 when list is empty', () {
      expect(svc.calculateTotalIncome([]), 0.0);
    });

    test('returns 0 when there are no income transactions', () {
      final expenseOnly = transactions.where((t) => t.isExpense).toList();
      expect(svc.calculateTotalIncome(expenseOnly), 0.0);
    });
  });

  group('calculateTotalExpenses', () {
    test('returns correct sum of expense transactions', () {
      expect(svc.calculateTotalExpenses(transactions), 42000.0);
    });

    test('returns 0 when list is empty', () {
      expect(svc.calculateTotalExpenses([]), 0.0);
    });
  });

  group('calculateBalance', () {
    test('returns income minus expenses', () {
      expect(svc.calculateBalance(transactions), 143000.0);
    });

    test('returns 0 for empty list', () {
      expect(svc.calculateBalance([]), 0.0);
    });

    test('returns negative when expenses exceed income', () {
      final tx = [
        Transaction(id: 'a', type: TransactionType.income, amount: 1000,
            category: 'Salary', description: 'x', date: DateTime(2026, 1, 1)),
        Transaction(id: 'b', type: TransactionType.expense, amount: 5000,
            category: 'Food', description: 'x', date: DateTime(2026, 1, 2)),
      ];
      expect(svc.calculateBalance(tx), -4000.0);
    });
  });

  // ── Filtering ─────────────────────────────────────────────────────────────

  group('filterByType', () {
    test('returns only expense transactions', () {
      final result = svc.filterByType(transactions, TransactionType.expense);
      expect(result.every((t) => t.isExpense), isTrue);
      expect(result.length, 3);
    });

    test('returns only income transactions', () {
      final result = svc.filterByType(transactions, TransactionType.income);
      expect(result.every((t) => t.isIncome), isTrue);
      expect(result.length, 2);
    });

    test('returns empty list when no matches', () {
      final incomeOnly = transactions.where((t) => t.isIncome).toList();
      final result = svc.filterByType(incomeOnly, TransactionType.expense);
      expect(result, isEmpty);
    });
  });

  group('filterByCategory', () {
    test('returns only Food transactions', () {
      final result = svc.filterByCategory(transactions, 'Food');
      expect(result.length, 1);
      expect(result.first.category, 'Food');
    });

    test('is case-insensitive', () {
      final result = svc.filterByCategory(transactions, 'food');
      expect(result.length, 1);
    });

    test('returns empty when category not found', () {
      final result = svc.filterByCategory(transactions, 'NonExistent');
      expect(result, isEmpty);
    });
  });

  // ── Validation ────────────────────────────────────────────────────────────

  group('isValidAmount', () {
    test('positive amount is valid', () {
      expect(svc.isValidAmount(5000), isTrue);
      expect(svc.isValidAmount(0.01), isTrue);
    });

    test('zero is invalid', () {
      expect(svc.isValidAmount(0), isFalse);
    });

    test('negative amount is invalid', () {
      expect(svc.isValidAmount(-100), isFalse);
    });
  });

  group('isValidDescription', () {
    test('non-empty string is valid', () {
      expect(svc.isValidDescription('Groceries'), isTrue);
    });

    test('empty string is invalid', () {
      expect(svc.isValidDescription(''), isFalse);
    });

    test('whitespace-only string is invalid', () {
      expect(svc.isValidDescription('   '), isFalse);
    });
  });

  group('validateTransaction', () {
    test('valid data returns null (no error)', () {
      final error = svc.validateTransaction(
        amount: 5000,
        description: 'Lunch',
        date: DateTime(2026, 4, 1),
        category: 'Food',
      );
      expect(error, isNull);
    });

    test('zero amount returns error message', () {
      final error = svc.validateTransaction(
        amount: 0,
        description: 'Lunch',
        date: DateTime(2026, 4, 1),
        category: 'Food',
      );
      expect(error, isNotNull);
    });

    test('empty description returns error message', () {
      final error = svc.validateTransaction(
        amount: 1000,
        description: '',
        date: DateTime(2026, 4, 1),
        category: 'Food',
      );
      expect(error, isNotNull);
    });

    test('empty category returns error message', () {
      final error = svc.validateTransaction(
        amount: 1000,
        description: 'Test',
        date: DateTime(2026, 4, 1),
        category: '',
      );
      expect(error, isNotNull);
    });
  });

  // ── Analytics ─────────────────────────────────────────────────────────────

  group('spendingByCategory', () {
    test('groups expenses by category correctly', () {
      final result = svc.spendingByCategory(transactions);
      expect(result['Food'], 12000.0);
      expect(result['Transport'], 5000.0);
      expect(result['Housing'], 25000.0);
    });

    test('does not include income in spending map', () {
      final result = svc.spendingByCategory(transactions);
      expect(result.containsKey('Salary'), isFalse);
      expect(result.containsKey('Freelance'), isFalse);
    });
  });

  group('isBudgetExceeded', () {
    test('returns true when spending exceeds limit', () {
      final exceeded = svc.isBudgetExceeded(transactions, 'Housing', 20000, 2026, 4);
      expect(exceeded, isTrue);
    });

    test('returns false when spending is under limit', () {
      final exceeded = svc.isBudgetExceeded(transactions, 'Food', 30000, 2026, 4);
      expect(exceeded, isFalse);
    });

    test('returns false for a category with no spending', () {
      final exceeded = svc.isBudgetExceeded(transactions, 'Health', 10000, 2026, 4);
      expect(exceeded, isFalse);
    });
  });

  // ── Sorting ───────────────────────────────────────────────────────────────

  group('sortByDateDesc', () {
    test('most recent transaction is first', () {
      final sorted = svc.sortByDateDesc(transactions);
      expect(sorted.first.date.isAfter(sorted.last.date), isTrue);
    });
  });

  group('sortByAmountDesc', () {
    test('highest amount transaction is first', () {
      final sorted = svc.sortByAmountDesc(transactions);
      expect(sorted.first.amount >= sorted.last.amount, isTrue);
    });
  });

  group('transactionsForMonth', () {
    test('returns only transactions in specified month', () {
      final result = svc.transactionsForMonth(transactions, 2026, 4);
      expect(result.length, transactions.length);
    });

    test('returns empty for a month with no transactions', () {
      final result = svc.transactionsForMonth(transactions, 2025, 1);
      expect(result, isEmpty);
    });
  });
}
