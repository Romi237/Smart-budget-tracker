// lib/screens/unit_test_screen.dart
// In-app unit test runner — displays test results just like a CI dashboard.
// This mirrors the automated tests in /test/budget_service_test.dart

import 'package:flutter/material.dart';
import '../models/transaction.dart';
import '../services/budget_service.dart';
import '../utils/app_theme.dart';

enum TestStatus { pending, passed, failed }

class TestCase {
  final String name;
  final String description;
  final bool Function() run;
  TestStatus status;
  String? errorMessage;

  TestCase({
    required this.name,
    required this.description,
    required this.run,
    this.status = TestStatus.pending,
  });
}

class UnitTestScreen extends StatefulWidget {
  const UnitTestScreen({super.key});

  @override
  State<UnitTestScreen> createState() => _UnitTestScreenState();
}

class _UnitTestScreenState extends State<UnitTestScreen> {
  final _svc = BudgetService();
  bool _running = false;
  late List<TestCase> _tests;

  @override
  void initState() {
    super.initState();
    _tests = _buildTests();
  }

  List<Transaction> get _sampleTransactions => [
        Transaction(
          id: 't1',
          type: TransactionType.income,
          amount: 150000,
          category: 'Salary',
          description: 'Monthly salary',
          date: DateTime(2026, 4, 1),
        ),
        Transaction(
          id: 't2',
          type: TransactionType.expense,
          amount: 12000,
          category: 'Food',
          description: 'Groceries',
          date: DateTime(2026, 4, 2),
        ),
        Transaction(
          id: 't3',
          type: TransactionType.expense,
          amount: 5000,
          category: 'Transport',
          description: 'Taxi',
          date: DateTime(2026, 4, 3),
        ),
        Transaction(
          id: 't4',
          type: TransactionType.expense,
          amount: 25000,
          category: 'Housing',
          description: 'Electricity',
          date: DateTime(2026, 4, 3),
        ),
        Transaction(
          id: 't5',
          type: TransactionType.income,
          amount: 35000,
          category: 'Freelance',
          description: 'Web project',
          date: DateTime(2026, 4, 4),
        ),
      ];

  List<TestCase> _buildTests() {
    return [
      TestCase(
        name: 'calculateTotalIncome_returnsCorrectSum',
        description: 'Income should sum only income transactions',
        run: () {
          final result = _svc.calculateTotalIncome(_sampleTransactions);
          return result == 185000.0;
        },
      ),
      TestCase(
        name: 'calculateTotalExpenses_returnsCorrectSum',
        description: 'Expenses should sum only expense transactions',
        run: () {
          final result = _svc.calculateTotalExpenses(_sampleTransactions);
          return result == 42000.0;
        },
      ),
      TestCase(
        name: 'calculateBalance_incomeMinusExpenses',
        description: 'Balance = income - expenses',
        run: () {
          final result = _svc.calculateBalance(_sampleTransactions);
          return result == 143000.0;
        },
      ),
      TestCase(
        name: 'calculateBalance_emptyList_returnsZero',
        description: 'Balance should be 0 when no transactions',
        run: () => _svc.calculateBalance([]) == 0.0,
      ),
      TestCase(
        name: 'filterByType_expense_returnsExpensesOnly',
        description: 'Filter by expense returns only expense records',
        run: () {
          final result =
              _svc.filterByType(_sampleTransactions, TransactionType.expense);
          return result.isNotEmpty && result.every((t) => t.isExpense);
        },
      ),
      TestCase(
        name: 'filterByType_income_returnsIncomesOnly',
        description: 'Filter by income returns only income records',
        run: () {
          final result =
              _svc.filterByType(_sampleTransactions, TransactionType.income);
          return result.isNotEmpty && result.every((t) => t.isIncome);
        },
      ),
      TestCase(
        name: 'filterByCategory_Food_returnsCorrect',
        description: 'Filtering by Food returns only Food transactions',
        run: () {
          final result = _svc.filterByCategory(_sampleTransactions, 'Food');
          return result.length == 1 && result.first.category == 'Food';
        },
      ),
      TestCase(
        name: 'isValidAmount_positive_returnsTrue',
        description: 'Positive amounts should be valid',
        run: () => _svc.isValidAmount(5000) && _svc.isValidAmount(0.01),
      ),
      TestCase(
        name: 'isValidAmount_zero_returnsFalse',
        description: 'Zero amount should be invalid',
        run: () => !_svc.isValidAmount(0),
      ),
      TestCase(
        name: 'isValidAmount_negative_returnsFalse',
        description: 'Negative amounts should be invalid',
        run: () => !_svc.isValidAmount(-100),
      ),
      TestCase(
        name: 'isValidDescription_empty_returnsFalse',
        description: 'Empty description should be invalid',
        run: () =>
            !_svc.isValidDescription('') && !_svc.isValidDescription('   '),
      ),
      TestCase(
        name: 'isValidDescription_nonEmpty_returnsTrue',
        description: 'Non-empty descriptions should be valid',
        run: () =>
            _svc.isValidDescription('Groceries') &&
            _svc.isValidDescription(' Taxi '),
      ),
      TestCase(
        name: 'validateTransaction_valid_returnsNull',
        description: 'Valid transaction data returns no error',
        run: () =>
            _svc.validateTransaction(
              amount: 5000,
              description: 'Lunch',
              date: DateTime(2026, 4, 1),
              category: 'Food',
            ) ==
            null,
      ),
      TestCase(
        name: 'validateTransaction_zeroAmount_returnsError',
        description: 'Zero amount returns an error message',
        run: () =>
            _svc.validateTransaction(
              amount: 0,
              description: 'Lunch',
              date: DateTime(2026, 4, 1),
              category: 'Food',
            ) !=
            null,
      ),
      TestCase(
        name: 'spendingByCategory_groupsCorrectly',
        description: 'Spending map keys match actual expense categories',
        run: () {
          final result = _svc.spendingByCategory(_sampleTransactions);
          return result.containsKey('Food') &&
              result['Food'] == 12000.0 &&
              result.containsKey('Transport') &&
              result['Transport'] == 5000.0;
        },
      ),
      TestCase(
        name: 'isBudgetExceeded_overLimit_returnsTrue',
        description: 'Spending over limit should trigger exceeded flag',
        run: () => _svc.isBudgetExceeded(
            _sampleTransactions, 'Housing', 20000, 2026, 4),
      ),
      TestCase(
        name: 'isBudgetExceeded_underLimit_returnsFalse',
        description: 'Spending under limit should NOT trigger exceeded flag',
        run: () =>
            !_svc.isBudgetExceeded(_sampleTransactions, 'Food', 30000, 2026, 4),
      ),
      TestCase(
        name: 'sortByDateDesc_mostRecentFirst',
        description: 'Sorted list should have most recent transaction first',
        run: () {
          final sorted = _svc.sortByDateDesc(_sampleTransactions);
          return sorted.first.date.isAfter(sorted.last.date) ||
              sorted.first.date == sorted.last.date;
        },
      ),
      TestCase(
        name: 'sortByAmountDesc_highestFirst',
        description: 'Sorted list should have highest amount first',
        run: () {
          final sorted = _svc.sortByAmountDesc(_sampleTransactions);
          return sorted.first.amount >= sorted.last.amount;
        },
      ),
      TestCase(
        name: 'transactionsForMonth_filtersCorrectMonth',
        description: 'Only transactions from April 2026 are returned',
        run: () {
          final result =
              _svc.transactionsForMonth(_sampleTransactions, 2026, 4);
          return result.length == _sampleTransactions.length &&
              result.every((t) => t.date.month == 4 && t.date.year == 2026);
        },
      ),
    ];
  }

  Future<void> _runAll() async {
    setState(() {
      _running = true;
      for (final t in _tests) {
        t.status = TestStatus.pending;
        t.errorMessage = null;
      }
    });

    for (int i = 0; i < _tests.length; i++) {
      await Future.delayed(const Duration(milliseconds: 80));
      try {
        final passed = _tests[i].run();
        setState(() =>
            _tests[i].status = passed ? TestStatus.passed : TestStatus.failed);
      } catch (e) {
        setState(() {
          _tests[i].status = TestStatus.failed;
          _tests[i].errorMessage = e.toString();
        });
      }
    }

    setState(() => _running = false);
  }

  int get _passed => _tests.where((t) => t.status == TestStatus.passed).length;
  int get _failed => _tests.where((t) => t.status == TestStatus.failed).length;
  int get _pending =>
      _tests.where((t) => t.status == TestStatus.pending).length;
  double get _coverage => _tests.isEmpty ? 0 : _passed / _tests.length * 100;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppTheme.borderColor, width: 0.5),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'BudgetService — Unit Test Suite',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 4),
                Text(
                  '${_tests.length} test cases · budget_service_test.dart',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppTheme.textSecondary,
                    fontFamily: 'monospace',
                  ),
                ),
                const SizedBox(height: 14),

                // Stats row
                if (_pending < _tests.length) ...[
                  Row(
                    children: [
                      _StatChip(
                          label: '$_passed passed',
                          color: AppTheme.primaryGreen),
                      const SizedBox(width: 8),
                      _StatChip(
                          label: '$_failed failed', color: AppTheme.expenseRed),
                      const SizedBox(width: 8),
                      _StatChip(
                        label: 'Coverage ${_coverage.toStringAsFixed(0)}%',
                        color: AppTheme.warningAmber,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: _coverage / 100,
                      backgroundColor: const Color(0xFFF0F0F0),
                      valueColor: AlwaysStoppedAnimation(
                        _coverage == 100
                            ? AppTheme.primaryGreen
                            : AppTheme.warningAmber,
                      ),
                      minHeight: 6,
                    ),
                  ),
                  const SizedBox(height: 14),
                ],

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _running ? null : _runAll,
                    icon: _running
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.white),
                          )
                        : const Icon(Icons.play_arrow_rounded, size: 18),
                    label:
                        Text(_running ? 'Running tests...' : 'Run all tests'),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // Test list
          ..._tests.map((test) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: test.status == TestStatus.passed
                          ? const Color(0xFF9FE1CB)
                          : test.status == TestStatus.failed
                              ? const Color(0xFFF5C4B3)
                              : AppTheme.borderColor,
                      width: 0.5,
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Status icon
                      Padding(
                        padding: const EdgeInsets.only(top: 1),
                        child: Icon(
                          test.status == TestStatus.passed
                              ? Icons.check_circle_rounded
                              : test.status == TestStatus.failed
                                  ? Icons.cancel_rounded
                                  : Icons.radio_button_unchecked,
                          size: 16,
                          color: test.status == TestStatus.passed
                              ? AppTheme.primaryGreen
                              : test.status == TestStatus.failed
                                  ? AppTheme.expenseRed
                                  : AppTheme.textSecondary,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${test.name}()',
                              style: const TextStyle(
                                fontSize: 12,
                                fontFamily: 'monospace',
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              test.description,
                              style: const TextStyle(
                                fontSize: 11,
                                color: AppTheme.textSecondary,
                              ),
                            ),
                            if (test.errorMessage != null) ...[
                              const SizedBox(height: 4),
                              Text(
                                test.errorMessage!,
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: AppTheme.expenseRed,
                                  fontFamily: 'monospace',
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      _StatusLabel(status: test.status),
                    ],
                  ),
                ),
              )),
        ],
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final String label;
  final Color color;
  const _StatChip({required this.label, required this.color});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
              fontSize: 11, fontWeight: FontWeight.w600, color: color),
        ),
      );
}

class _StatusLabel extends StatelessWidget {
  final TestStatus status;
  const _StatusLabel({required this.status});

  @override
  Widget build(BuildContext context) {
    final color = status == TestStatus.passed
        ? AppTheme.primaryGreen
        : status == TestStatus.failed
            ? AppTheme.expenseRed
            : AppTheme.textSecondary;
    final label = status == TestStatus.passed
        ? 'PASS'
        : status == TestStatus.failed
            ? 'FAIL'
            : '—';
    return Text(
      label,
      style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: color),
    );
  }
}
