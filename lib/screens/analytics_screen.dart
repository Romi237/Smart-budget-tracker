// lib/screens/analytics_screen.dart
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/transaction.dart';
import '../models/budget_limit.dart';
import '../services/budget_service.dart';
import '../utils/app_theme.dart';
import '../utils/formatters.dart';

class AnalyticsScreen extends StatelessWidget {
  final List<Transaction> transactions;
  const AnalyticsScreen({super.key, required this.transactions});

  @override
  Widget build(BuildContext context) {
    final svc = BudgetService();
    final now = DateTime.now();
    final monthlyTx =
        svc.transactionsForMonth(transactions, now.year, now.month);
    final byCategory = svc.spendingByCategory(monthlyTx);
    final income = svc.calculateTotalIncome(transactions);
    final expenses = svc.calculateTotalExpenses(transactions);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Pie chart section
          if (byCategory.isNotEmpty) ...[
            const _SectionTitle(title: 'Spending breakdown (this month)'),
            const SizedBox(height: 12),
            _PieChartCard(byCategory: byCategory),
            const SizedBox(height: 20),
          ],

          // Income vs Expense bar
          const _SectionTitle(title: 'Income vs expenses (all time)'),
          const SizedBox(height: 12),
          _IncomeExpenseBar(income: income, expenses: expenses),
          const SizedBox(height: 20),

          // Budget progress
          const _SectionTitle(title: 'Monthly budget limits'),
          const SizedBox(height: 12),
          ...defaultBudgets.map((budget) {
            final spent = byCategory[budget.category] ?? 0;
            final pct = budget.percentUsed(spent).clamp(0.0, 1.0);
            final exceeded = budget.isExceeded(spent);
            final warning = budget.isWarning(spent);
            final color = exceeded
                ? AppTheme.expenseRed
                : warning
                    ? AppTheme.warningAmber
                    : AppTheme.primaryGreen;

            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppTheme.borderColor, width: 0.5),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Text(
                              categoryEmoji[budget.category] ?? '📦',
                              style: const TextStyle(fontSize: 18),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              budget.category,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              Formatters.currency(spent),
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: color,
                              ),
                            ),
                            Text(
                              'of ${Formatters.currency(budget.limit)}',
                              style: const TextStyle(
                                fontSize: 11,
                                color: AppTheme.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: pct,
                        backgroundColor: const Color(0xFFF0F0F0),
                        valueColor: AlwaysStoppedAnimation(color),
                        minHeight: 7,
                      ),
                    ),
                    if (exceeded)
                      Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: Text(
                          '⚠ Budget exceeded by ${Formatters.currency(spent - budget.limit)}',
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppTheme.expenseRed,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) => Text(
        title,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: AppTheme.textSecondary,
          letterSpacing: 0.3,
        ),
      );
}

class _PieChartCard extends StatelessWidget {
  final Map<String, double> byCategory;
  const _PieChartCard({required this.byCategory});

  @override
  Widget build(BuildContext context) {
    final total = byCategory.values.fold(0.0, (a, b) => a + b);
    final colors = [
      AppTheme.primaryGreen,
      AppTheme.expenseRed,
      AppTheme.warningAmber,
      const Color(0xFF378ADD),
      const Color(0xFF7F77DD),
      const Color(0xFF888780),
    ];
    final entries = byCategory.entries.toList();

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.borderColor, width: 0.5),
      ),
      child: Column(
        children: [
          SizedBox(
            height: 200,
            child: PieChart(
              PieChartData(
                sectionsSpace: 2,
                centerSpaceRadius: 50,
                sections: List.generate(entries.length, (i) {
                  final e = entries[i];
                  final pct = (e.value / total * 100).toStringAsFixed(1);
                  return PieChartSectionData(
                    color: colors[i % colors.length],
                    value: e.value,
                    title: '$pct%',
                    radius: 55,
                    titleStyle: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  );
                }),
              ),
            ),
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 12,
            runSpacing: 8,
            children: List.generate(entries.length, (i) {
              final e = entries[i];
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: colors[i % colors.length],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 5),
                  Text(
                    '${categoryEmoji[e.key] ?? ''} ${e.key}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              );
            }),
          ),
        ],
      ),
    );
  }
}

class _IncomeExpenseBar extends StatelessWidget {
  final double income;
  final double expenses;
  const _IncomeExpenseBar({required this.income, required this.expenses});

  @override
  Widget build(BuildContext context) {
    final total = income + expenses;
    final incPct = total == 0 ? 0.5 : income / total;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.borderColor, width: 0.5),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Income',
                        style: TextStyle(
                            fontSize: 12, color: AppTheme.textSecondary)),
                    Text(Formatters.currency(income),
                        style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.primaryGreen)),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text('Expenses',
                        style: TextStyle(
                            fontSize: 12, color: AppTheme.textSecondary)),
                    Text(Formatters.currency(expenses),
                        style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.expenseRed)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: Row(
              children: [
                Expanded(
                  flex: (incPct * 100).round(),
                  child: Container(height: 12, color: AppTheme.primaryGreen),
                ),
                Expanded(
                  flex: ((1 - incPct) * 100).round(),
                  child: Container(height: 12, color: AppTheme.expenseRed),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
