// lib/screens/add_transaction_screen.dart
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/transaction.dart';
import '../services/budget_service.dart';
import '../services/database_service.dart';
import '../services/location_service.dart';
import '../utils/app_theme.dart';
import '../utils/formatters.dart';

class AddTransactionScreen extends StatefulWidget {
  const AddTransactionScreen({super.key});

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _budgetService = BudgetService();

  TransactionType _type = TransactionType.expense;
  String _category = expenseCategories.first;
  DateTime _date = DateTime.now();
  String? _locationLabel;
  double? _latitude;
  double? _longitude;
  bool _fetchingLocation = false;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _fetchLocation();
  }

  @override
  void dispose() {
    _amountCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  Future<void> _fetchLocation() async {
    setState(() => _fetchingLocation = true);
    final pos = await LocationService.getCurrentPosition();
    if (pos != null && mounted) {
      setState(() {
        _latitude = pos.latitude;
        _longitude = pos.longitude;
        _locationLabel = LocationService.formatCoordinates(
          pos.latitude,
          pos.longitude,
        );
        _fetchingLocation = false;
      });
    } else if (mounted) {
      setState(() {
        _locationLabel = 'Location unavailable';
        _fetchingLocation = false;
      });
    }
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.light(primary: AppTheme.primaryGreen),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _date = picked);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final amount = double.tryParse(_amountCtrl.text.trim()) ?? 0;
    final error = _budgetService.validateTransaction(
      amount: amount,
      description: _descCtrl.text,
      date: _date,
      category: _category,
    );

    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error), backgroundColor: AppTheme.expenseRed),
      );
      return;
    }

    setState(() => _saving = true);

    final tx = Transaction(
      id: const Uuid().v4(),
      type: _type,
      amount: amount,
      category: _category,
      description: _descCtrl.text.trim(),
      date: _date,
      locationLabel: _locationLabel,
      latitude: _latitude,
      longitude: _longitude,
    );

    await DatabaseService.insertTransaction(tx);

    if (mounted) {
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final categories =
        _type == TransactionType.expense ? expenseCategories : incomeCategories;

    return Scaffold(
      appBar: AppBar(title: const Text('Add Transaction')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Type toggle
              const Text(
                'Type',
                style: TextStyle(fontSize: 13, color: AppTheme.textSecondary),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  _TypeButton(
                    label: 'Expense',
                    selected: _type == TransactionType.expense,
                    activeColor: AppTheme.expenseRed,
                    activeBg: const Color(0xFFFAECE7),
                    onTap: () => setState(() {
                      _type = TransactionType.expense;
                      _category = expenseCategories.first;
                    }),
                  ),
                  const SizedBox(width: 10),
                  _TypeButton(
                    label: 'Income',
                    selected: _type == TransactionType.income,
                    activeColor: AppTheme.primaryGreen,
                    activeBg: const Color(0xFFE1F5EE),
                    onTap: () => setState(() {
                      _type = TransactionType.income;
                      _category = incomeCategories.first;
                    }),
                  ),
                ],
              ),
              const SizedBox(height: 18),

              // Amount
              TextFormField(
                controller: _amountCtrl,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: 'Amount (XAF)',
                  prefixIcon: Icon(Icons.payments_outlined, size: 20),
                ),
                validator: (v) {
                  final n = double.tryParse(v ?? '');
                  if (n == null || n <= 0) {
                    return 'Enter a valid positive amount';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 14),

              // Description
              TextFormField(
                controller: _descCtrl,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  prefixIcon: Icon(Icons.notes_outlined, size: 20),
                ),
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? 'Description is required'
                    : null,
              ),
              const SizedBox(height: 14),

              // Category
              DropdownButtonFormField<String>(
                initialValue: _category,
                decoration: const InputDecoration(
                  labelText: 'Category',
                  prefixIcon: Icon(Icons.category_outlined, size: 20),
                ),
                items: categories
                    .map((c) => DropdownMenuItem(
                          value: c,
                          child: Row(
                            children: [
                              Text(categoryEmoji[c] ?? '📦'),
                              const SizedBox(width: 8),
                              Text(c),
                            ],
                          ),
                        ))
                    .toList(),
                onChanged: (v) => setState(() => _category = v!),
              ),
              const SizedBox(height: 14),

              // Date picker
              InkWell(
                onTap: _pickDate,
                borderRadius: BorderRadius.circular(10),
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Date',
                    prefixIcon: Icon(Icons.calendar_today_outlined, size: 20),
                  ),
                  child: Text(
                    Formatters.date(_date),
                    style: const TextStyle(fontSize: 14),
                  ),
                ),
              ),
              const SizedBox(height: 14),

              // GPS location (sensor)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFE1F5EE),
                  borderRadius: BorderRadius.circular(10),
                  border:
                      Border.all(color: const Color(0xFF9FE1CB), width: 0.5),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.location_on,
                        color: AppTheme.primaryGreen, size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _fetchingLocation
                          ? const Row(
                              children: [
                                SizedBox(
                                  width: 12,
                                  height: 12,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: AppTheme.primaryGreen,
                                  ),
                                ),
                                SizedBox(width: 8),
                                Text(
                                  'Fetching GPS...',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: AppTheme.primaryGreen,
                                  ),
                                ),
                              ],
                            )
                          : Text(
                              _locationLabel ?? 'GPS not available',
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppTheme.primaryGreen,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                    ),
                    if (!_fetchingLocation)
                      GestureDetector(
                        onTap: _fetchLocation,
                        child: const Icon(
                          Icons.refresh,
                          size: 16,
                          color: AppTheme.primaryGreen,
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 28),

              // Save button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _saving ? null : _save,
                  child: _saving
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text('Save Transaction'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TypeButton extends StatelessWidget {
  final String label;
  final bool selected;
  final Color activeColor;
  final Color activeBg;
  final VoidCallback onTap;

  const _TypeButton({
    required this.label,
    required this.selected,
    required this.activeColor,
    required this.activeBg,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: selected ? activeBg : Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: selected ? activeColor : AppTheme.borderColor,
              width: selected ? 1.5 : 0.5,
            ),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: selected ? activeColor : AppTheme.textSecondary,
            ),
          ),
        ),
      ),
    );
  }
}
