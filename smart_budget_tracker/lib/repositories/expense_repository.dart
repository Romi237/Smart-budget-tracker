import '../database/database_helper.dart';
import '../models/expense.dart';

class ExpenseRepository {
  final dbHelper = DatabaseHelper.instance;

  Future<int> addExpense(Expense expense) async {
    final db = await dbHelper.database;

    return db.insert('expenses', expense.toMap());
  }

  Future<List<Expense>> getExpenses() async {
    final db = await dbHelper.database;

    final maps = await db.query('expenses');

    return maps.map((e) => Expense.fromMap(e)).toList();
  }

  Future<int> deleteExpense(int id) async {
    final db = await dbHelper.database;

    return db.delete('expenses', where: 'id = ?', whereArgs: [id]);
  }
}
