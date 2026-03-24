import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'add_expense_screen.dart';
import 'expense_history_screen.dart';
import '../providers/expense_provider.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Smart Budget Tracker"), elevation: 0),
      body: Consumer<ExpenseProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.errorMessage != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(provider.errorMessage!),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => provider.clearError(),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          final totalExpenses = provider.getTotalExpenses();
          final categoryTotals = provider.getCategoryTotals();

          return RefreshIndicator(
            onRefresh: () => provider.loadExpenses(),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Total Expenses Card
                  Card(
                    elevation: 4,
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      width: double.infinity,
                      child: Column(
                        children: [
                          const Text(
                            'Total Expenses',
                            style: TextStyle(fontSize: 16, color: Colors.grey),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '${totalExpenses.toStringAsFixed(2)} FCFA',
                            style: const TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Category Breakdown
                  if (categoryTotals.isNotEmpty) ...[
                    const Text(
                      'Category Breakdown',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ...categoryTotals.entries.map(
                      (entry) => Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          leading: _getCategoryIcon(entry.key),
                          title: Text(entry.key),
                          trailing: Text(
                            '${entry.value.toStringAsFixed(2)} FCFA',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ),
                  ],

                  const SizedBox(height: 24),

                  // Navigation Buttons
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ExpenseHistoryScreen(),
                          ),
                        );
                      },
                      icon: const Icon(Icons.history),
                      label: const Text('View Expense History'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddExpenseScreen()),
          );
          if (result == true) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Expense added successfully!')),
            );
          }
        },
      ),
    );
  }

  Widget _getCategoryIcon(String category) {
    IconData iconData;
    switch (category.toLowerCase()) {
      case 'food':
        iconData = Icons.restaurant;
        break;
      case 'transport':
        iconData = Icons.directions_car;
        break;
      case 'school':
        iconData = Icons.school;
        break;
      case 'entertainment':
        iconData = Icons.movie;
        break;
      default:
        iconData = Icons.category;
    }
    return Icon(iconData, color: Colors.blue);
  }
}
