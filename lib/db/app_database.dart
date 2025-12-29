import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../models/transaction.dart';

class AppDatabase {
  // Singleton instance so only one database is open in the app
  static final AppDatabase instance = AppDatabase._internal();
  AppDatabase._internal();

  Database? _db;

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDB('agrifintrack.db');
    return _db!;
  }

  Future<Database> _initDB(String filePath) async {
    // Get folder for app databases, then join with file name
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    // Open database, create table if not exists
    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE transactions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        date TEXT NOT NULL,
        type TEXT NOT NULL,
        category TEXT NOT NULL,
        crop TEXT NOT NULL,
        amount INTEGER NOT NULL
      )
    ''');
  }

  Future<int> insertTransaction(AgriTransaction tx) async {
    final db = await database;
    // SQLite will auto-increment id
    return await db.insert('transactions', tx.toMap());
  }

  Future<List<AgriTransaction>> getAllTransactions() async {
    final db = await database;
    final result = await db.query('transactions', orderBy: 'date DESC');
    return result.map((e) => AgriTransaction.fromMap(e)).toList();
  }

  Future<void> deleteAllTransactions() async {
    final db = await database;
    await db.delete('transactions');
  }
}
