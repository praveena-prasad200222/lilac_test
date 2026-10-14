
import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';

import '../models/transaction_item.dart';

class ExpenseDatabase {
  ExpenseDatabase._();

  static final ExpenseDatabase instance = ExpenseDatabase._();

  Database? _db;
  Future<Database>? _openingDatabase;

  Future<Database> get database async {
    if (_db != null) {
      return _db!;
    }

    // Prevent multiple database openings at the same time.
    if (_openingDatabase != null) {
      return _openingDatabase!;
    }

    _openingDatabase = _openDatabase();

    try {
      _db = await _openingDatabase!;
      return _db!;
    } catch (_) {
      _openingDatabase = null;
      rethrow;
    }
  }

  Future<Database> _openDatabase() async {
    final DatabaseFactory factory;
    final String path;

    if (kIsWeb) {
      // SQLite factory for Flutter Web without a web worker.
      factory = databaseFactoryFfiWebNoWebWorker;
      path = 'expenzia.db';
    } else {
      // SQLite factory for Android, iOS, Windows, and other
      // supported native platforms.
      factory = databaseFactory;
      path = join(
        await getDatabasesPath(),
        'expenzia.db',
      );
    }

    return factory.openDatabase(
      path,
      options: OpenDatabaseOptions(
        version: 1,
        onCreate: (Database db, int version) async {
          await db.execute('''
            CREATE TABLE transactions (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              title TEXT NOT NULL,
              amount REAL NOT NULL CHECK(amount > 0),
              category TEXT NOT NULL,
              date TEXT NOT NULL,
              description TEXT NOT NULL DEFAULT '',
              type TEXT NOT NULL DEFAULT 'expense',
              frequency TEXT NOT NULL DEFAULT 'Monthly'
            )
          ''');
        },
      ),
    );
  }

  Future<List<TransactionItem>> getAll({String? type}) async {
    final db = await database;

    final rows = await db.query(
      'transactions',
      where: type == null ? null : 'type = ?',
      whereArgs: type == null ? null : [type],
      orderBy: 'date DESC, id DESC',
    );

    return rows.map(TransactionItem.fromMap).toList();
  }

  Future<int> insert(TransactionItem item) async {
    final db = await database;
    final data = Map<String, Object?>.from(item.toMap())
      ..remove('id');

    return db.insert('transactions', data);
  }

  Future<int> update(TransactionItem item) async {
    if (item.id == null) {
      throw ArgumentError(
        'Transaction id is required for update',
      );
    }

    final db = await database;
    final data = Map<String, Object?>.from(item.toMap())
      ..remove('id');

    return db.update(
      'transactions',
      data,
      where: 'id = ?',
      whereArgs: [item.id],
    );
  }

  Future<int> delete(int id) async {
    final db = await database;

    return db.delete(
      'transactions',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> clearAll() async {
    final db = await database;
    await db.delete('transactions');
  }
}
