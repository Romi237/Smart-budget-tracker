// lib/screens/home_screen.dart
import 'package:flutter/material.dart';
import '../models/transaction.dart';
import '../services/budget_service.dart';
import '../services/database_service.dart';
import '../services/sensor_service.dart';
import '../utils/app_theme.dart';
import '../utils/formatters.dart';
import '../widgets/metric_card.dart';
import '../widgets/transaction_card.dart';
import 'add_transaction_screen.dart';
import 'analytics_screen.dart';
import 'unit_test_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  List<Transaction> _transactions = [];
  final _budgetService = BudgetService();
  bool _isLoading = true;
  String _filterType = 'all';
  String _filterCategory = 'all';

  @override
  void initState() {
    super.initState();
    _loadTransactions();

    // Accelerometer sensor: shake to refresh
    SensorService.startListening(onShake: () {
      _loadTransactions();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Shaken! Refreshing transactions...'),
            duration: Duration(seconds: 1),
            backgroundColor: AppTheme.primaryGreen,
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    SensorService.stopListening();
    super.dispose();
  }

  Future<void> _loadTransactions() async {
    setState(() => _isLoading = true);
    final list = await DatabaseService.getAllTransactions();
    setState(() {
      _transactions = list;
      _isLoading = false;
    });
  }

  Future<void> _deleteTransaction(String id) async {
    await DatabaseService.deleteTransaction(id);
    _loadTransactions();
  }

  List<Transaction> get _filtered {
    return _transactions.where((t) {
      if (_filterType != 'all' && t.type.name != _filterType) return false;
      if (_filterCategory != 'all' && t.category != _filterCategory) {
        return false;
      }
      return true;
    }).toList();
  }

  double get _income => _budgetService.calculateTotalIncome(_transactions);
  double get _expenses => _budgetService.calculateTotalExpenses(_transactions);
  double get _balance => _budgetService.calculateBalance(_transactions);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('BudgetTracker'),
            Row(
              children: [
                Container(
                  width: 7,
                  height: 7,
                  decoration: const BoxDecoration(
                    color: AppTheme.primaryGreen,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 5),
                const Text(
                  'GPS + Accelerometer active',
                  style: TextStyle(
                    fontSize: 11,
                    color: AppTheme.primaryGreen,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: _loadTransactions,
          ),
        ],
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          _buildTransactionsTab(),
          AnalyticsScreen(transactions: _transactions),
          const UnitTestScreen(),
        ],
      ),
      floatingActionButton: _selectedIndex == 0
          ? FloatingActionButton.extended(
              onPressed: () async {
                final result = await Navigator.push<bool>(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const AddTransactionScreen(),
                  ),
                );
                if (result == true) _loadTransactions();
              },
              backgroundColor: AppTheme.primaryGreen,
              foregroundColor: Colors.white,
              icon: const Icon(Icons.add),
              label: const Text('Add Transaction'),
            )
          : null,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (i) => setState(() => _selectedIndex = i),
        backgroundColor: Colors.white,
        indicatorColor: const Color(0xFFE1F5EE),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.receipt_long_outlined),
            selectedIcon:
                Icon(Icons.receipt_long, color: AppTheme.primaryGreen),
            label: 'Transactions',
          ),
          NavigationDestination(
            icon: Icon(Icons.bar_chart_outlined),
            selectedIcon: Icon(Icons.bar_chart, color: AppTheme.primaryGreen),
            label: 'Analytics',
          ),
          NavigationDestination(
            icon: Icon(Icons.science_outlined),
            selectedIcon: Icon(Icons.science, color: AppTheme.primaryGreen),
            label: 'Unit Tests',
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionsTab() {
    return RefreshIndicator(
      onRefresh: _loadTransactions,
      color: AppTheme.primaryGreen,
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: Column(
                children: [
                  // Metric cards
                  Row(
                    children: [
                      Expanded(
                        child: MetricCard(
                          label: 'Income',
                          amount: _income,
                          valueColor: AppTheme.primaryGreen,
                          icon: Icons.arrow_downward_rounded,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: MetricCard(
                          label: 'Expenses',
                          amount: _expenses,
                          valueColor: AppTheme.expenseRed,
                          icon: Icons.arrow_upward_rounded,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  MetricCard(
                    label: 'Balance',
                    amount: _balance.abs(),
                    valueColor: _balance >= 0
                        ? AppTheme.primaryGreen
                        : AppTheme.expenseRed,
                    icon: Icons.account_balance_wallet_outlined,
                  ),
                  const SizedBox(height: 16),

                  // Filters
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          initialValue: _filterType,
                          decoration: const InputDecoration(labelText: 'Type'),
                          items: const [
                            DropdownMenuItem(
                                value: 'all', child: Text('All types')),
                            DropdownMenuItem(
                                value: 'income', child: Text('Income')),
                            DropdownMenuItem(
                                value: 'expense', child: Text('Expenses')),
                          ],
                          onChanged: (v) => setState(() => _filterType = v!),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          initialValue: _filterCategory,
                          decoration:
                              const InputDecoration(labelText: 'Category'),
                          items: [
                            const DropdownMenuItem(
                                value: 'all', child: Text('All')),
                            ...<dynamic>{
                              ...expenseCategories,
                              ...incomeCategories
                            }.map((c) => DropdownMenuItem(
                                value: c, child: Text(c as String))),
                          ],
                          onChanged: (v) =>
                              setState(() => _filterCategory = v!),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
          if (_isLoading)
            const SliverFillRemaining(
              child: Center(
                child: CircularProgressIndicator(color: AppTheme.primaryGreen),
              ),
            )
          else if (_filtered.isEmpty)
            SliverFillRemaining(
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('📊', style: TextStyle(fontSize: 48)),
                    const SizedBox(height: 12),
                    Text(
                      _transactions.isEmpty
                          ? 'No transactions yet.\nTap + to add your first one.'
                          : 'No results for this filter.',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, i) => TransactionCard(
                    transaction: _filtered[i],
                    onDelete: () => _deleteTransaction(_filtered[i].id),
                  ),
                  childCount: _filtered.length,
                ),
              ),
            ),
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }
}
