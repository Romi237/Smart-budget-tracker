// lib/services/database_service.dart
// Cross-platform storage:
//   - Android / iOS / Desktop → SQLite via sqflite
//   - Web (Chrome)            → shared_preferences for persistence

import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:sqflite/sqflite.dart' hide Transaction;
import 'package:sqflite_common_ffi/sqflite_ffi.dart' hide Transaction;
import 'package:path/path.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/transaction.dart';

class DatabaseService {
  static const String _prefsKey = 'smart_budget_transactions';
  // ── Web: in-memory store + shared_preferences ─────────────────────────────
  static final List<Transaction> _memoryStore = [];

  static Future<void> _saveToPrefs() async {
    if (!kIsWeb) return;
    final prefs = await SharedPreferences.getInstance();
    final jsonList = _memoryStore.map((tx) => jsonEncode(tx.toMap())).toList();
    await prefs.setStringList(_prefsKey, jsonList);
  }

  static Future<void> _loadFromPrefs() async {
    if (!kIsWeb) return;
    final prefs = await SharedPreferences.getInstance();
    final jsonList = prefs.getStringList(_prefsKey) ?? [];
    _memoryStore.clear();
    _memoryStore.addAll(jsonList.map((json) =>
        Transaction.fromMap(jsonDecode(json) as Map<String, dynamic>)));
  }

  // ── Native: SQLite ────────────────────────────────────────────────────────
  static Database? _db;
  static const String _tableName = 'transactions';

  static Future<Database> get _database async {
    _db ??= await _initDb();
    return _db!;
  }

  static Future<Database> _initDb() async {
    final dbPath = await databaseFactory.getDatabasesPath();
    final path = join(dbPath, 'budget_tracker.db');
    return databaseFactory.openDatabase(
      path,
      options: OpenDatabaseOptions(
        version: 1,
        onCreate: (db, version) async {
          await db.execute('''
            CREATE TABLE $_tableName (
              id TEXT PRIMARY KEY,
              type TEXT NOT NULL,
              amount REAL NOT NULL,
              category TEXT NOT NULL,
              description TEXT NOT NULL,
              date TEXT NOT NULL,
              locationLabel TEXT,
              latitude REAL,
              longitude REAL
            )
          ''');
        },
      ),
    );
  }

  // ── CRUD — unified API works on both web and native ───────────────────────

  static Future<void> insertTransaction(Transaction tx) async {
    if (kIsWeb) {
      await _loadFromPrefs();
      _memoryStore.removeWhere((t) => t.id == tx.id);
      _memoryStore.add(tx);
      await _saveToPrefs();
      return;
    }
    final db = await _database;
    await db.insert(
      _tableName,
      tx.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  static Future<List<Transaction>> getAllTransactions() async {
    if (kIsWeb) {
      await _loadFromPrefs();
      final sorted = List<Transaction>.from(_memoryStore);
      sorted.sort((a, b) => b.date.compareTo(a.date));
      return sorted;
    }
    final db = await _database;
    final maps = await db.query(_tableName, orderBy: 'date DESC');
    return maps.map((map) => Transaction.fromMap(map)).toList();
  }

  static Future<void> deleteTransaction(String id) async {
    if (kIsWeb) {
      await _loadFromPrefs();
      _memoryStore.removeWhere((t) => t.id == id);
      await _saveToPrefs();
      return;
    }
    final db = await _database;
    await db.delete(_tableName, where: 'id = ?', whereArgs: [id]);
  }

  static Future<void> updateTransaction(Transaction tx) async {
    if (kIsWeb) {
      await _loadFromPrefs();
      final i = _memoryStore.indexWhere((t) => t.id == tx.id);
      if (i != -1) {
        _memoryStore[i] = tx;
      }
      await _saveToPrefs();
      return;
    }
    final db = await _database;
    await db.update(
      _tableName,
      tx.toMap(),
      where: 'id = ?',
      whereArgs: [tx.id],
    );
  }

  static Future<List<Transaction>> getTransactionsByType(
      TransactionType type) async {
    final all = await getAllTransactions();
    return all.where((t) => t.type == type).toList();
  }

  static Future<List<Transaction>> getTransactionsByCategory(
      String category) async {
    final all = await getAllTransactions();
    return all.where((t) => t.category == category).toList();
  }
}
