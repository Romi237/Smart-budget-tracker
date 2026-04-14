// lib/utils/formatters.dart
import 'package:intl/intl.dart';
import '../models/transaction.dart';

class Formatters {
  static final _currencyFormat = NumberFormat('#,##0', 'fr_FR');
  static final _dateFormat = DateFormat('dd MMM yyyy');
  static final _shortDateFormat = DateFormat('dd/MM/yy');

  static String currency(double amount) =>
      'XAF ${_currencyFormat.format(amount)}';

  static String date(DateTime date) => _dateFormat.format(date);
  static String shortDate(DateTime date) => _shortDateFormat.format(date);

  static String signedAmount(Transaction tx) {
    final sign = tx.isIncome ? '+' : '-';
    return '$sign ${currency(tx.amount)}';
  }
}

const Map<String, String> categoryEmoji = {
  'Food': '🍽',
  'Transport': '🚌',
  'Housing': '🏠',
  'Health': '💊',
  'Education': '📚',
  'Salary': '💼',
  'Freelance': '💻',
  'Other': '📦',
};

const List<String> expenseCategories = [
  'Food', 'Transport', 'Housing', 'Health', 'Education', 'Other',
];

const List<String> incomeCategories = [
  'Salary', 'Freelance', 'Other',
];
