import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../../models/transaction_model.dart';
import '../../models/category_model.dart';
import '../../models/transaction_filter.dart';
import 'seed_data.dart';

class DatabaseService {
  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('my_hisab.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 2,
      onCreate: _createDB,
      onUpgrade: _upgradeDB,
    );
  }

  Future<void> _upgradeDB(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      final columns = [
        'ALTER TABLE transactions ADD COLUMN householdId TEXT DEFAULT "default_household"',
        'ALTER TABLE transactions ADD COLUMN amountMinor INTEGER DEFAULT 0',
        'ALTER TABLE transactions ADD COLUMN currency TEXT DEFAULT "INR"',
        'ALTER TABLE transactions ADD COLUMN createdBy TEXT DEFAULT "user"',
        'ALTER TABLE transactions ADD COLUMN createdByName TEXT DEFAULT "You"',
        'ALTER TABLE transactions ADD COLUMN updatedBy TEXT DEFAULT "user"',
        'ALTER TABLE transactions ADD COLUMN deviceId TEXT DEFAULT "device_local"',
        'ALTER TABLE transactions ADD COLUMN version INTEGER DEFAULT 1',
        'ALTER TABLE transactions ADD COLUMN isDeleted INTEGER DEFAULT 0',
        'ALTER TABLE transactions ADD COLUMN deletedAt TEXT',
        'ALTER TABLE transactions ADD COLUMN deletedBy TEXT',
        'ALTER TABLE transactions ADD COLUMN clientOperationId TEXT',
        'ALTER TABLE transactions ADD COLUMN receiptId TEXT',
        'ALTER TABLE transactions ADD COLUMN receiptUrl TEXT',
        'ALTER TABLE transactions ADD COLUMN localReceiptPath TEXT',
        'ALTER TABLE transactions ADD COLUMN isSynced INTEGER DEFAULT 1',
      ];
      for (final sql in columns) {
        try {
          await db.execute(sql);
        } catch (_) {}
      }
    }
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE categories (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        iconKey TEXT NOT NULL,
        colorHex INTEGER NOT NULL,
        type TEXT NOT NULL,
        isDefault INTEGER NOT NULL DEFAULT 0
      )
    ''');

    await db.execute('''
      CREATE TABLE transactions (
        id TEXT PRIMARY KEY,
        householdId TEXT DEFAULT 'default_household',
        type TEXT NOT NULL,
        amountMinor INTEGER NOT NULL DEFAULT 0,
        amount REAL NOT NULL,
        currency TEXT DEFAULT 'INR',
        categoryId TEXT NOT NULL,
        categoryName TEXT NOT NULL,
        title TEXT NOT NULL,
        description TEXT,
        dateTime TEXT NOT NULL,
        createdAt TEXT NOT NULL,
        updatedAt TEXT NOT NULL,
        createdBy TEXT DEFAULT 'user',
        createdByName TEXT DEFAULT 'You',
        updatedBy TEXT DEFAULT 'user',
        deviceId TEXT DEFAULT 'device_local',
        version INTEGER DEFAULT 1,
        isDeleted INTEGER NOT NULL DEFAULT 0,
        deletedAt TEXT,
        deletedBy TEXT,
        clientOperationId TEXT,
        receiptId TEXT,
        receiptUrl TEXT,
        localReceiptPath TEXT,
        isSynced INTEGER NOT NULL DEFAULT 1,
        isTemplate INTEGER NOT NULL DEFAULT 0,
        FOREIGN KEY (categoryId) REFERENCES categories (id) ON DELETE SET DEFAULT
      )
    ''');

    // Create indices for fast filtering and reporting
    await db.execute('CREATE INDEX idx_tx_datetime ON transactions (dateTime)');
    await db.execute('CREATE INDEX idx_tx_type ON transactions (type)');
    await db.execute('CREATE INDEX idx_tx_category ON transactions (categoryId)');

    // Seed default categories
    final batch = db.batch();
    for (final cat in SeedData.categories) {
      batch.insert('categories', cat.toMap());
    }
    await batch.commit(noResult: true);
  }

  // ==========================================
  // TRANSACTION CRUD
  // ==========================================

  Future<int> insertTransaction(TransactionModel tx) async {
    final db = await database;
    return await db.insert(
      'transactions',
      tx.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<int> updateTransaction(TransactionModel tx) async {
    final db = await database;
    return await db.update(
      'transactions',
      tx.toMap(),
      where: 'id = ?',
      whereArgs: [tx.id],
    );
  }

  Future<int> deleteTransaction(String id) async {
    final db = await database;
    return await db.delete(
      'transactions',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<TransactionModel?> getTransactionById(String id) async {
    final db = await database;
    final maps = await db.query(
      'transactions',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (maps.isNotEmpty) {
      return TransactionModel.fromMap(maps.first);
    }
    return null;
  }

  Future<List<TransactionModel>> getRecentTransactions({int limit = 5}) async {
    final db = await database;
    final maps = await db.query(
      'transactions',
      where: 'isTemplate = 0',
      orderBy: 'dateTime DESC, createdAt DESC',
      limit: limit,
    );
    return maps.map((m) => TransactionModel.fromMap(m)).toList();
  }

  Future<List<TransactionModel>> getAllTransactions({
    TransactionFilter filter = const TransactionFilter(),
  }) async {
    final db = await database;

    final whereClauses = <String>['isTemplate = 0'];
    final whereArgs = <dynamic>[];

    // Filter by Type
    if (filter.type == FilterType.income) {
      whereClauses.add('type = ?');
      whereArgs.add('income');
    } else if (filter.type == FilterType.expense) {
      whereClauses.add('type = ?');
      whereArgs.add('expense');
    }

    // Filter by Category
    if (filter.categoryId != null && filter.categoryId!.isNotEmpty) {
      whereClauses.add('categoryId = ?');
      whereArgs.add(filter.categoryId);
    }

    // Filter by Date Range
    if (filter.dateRange != null) {
      whereClauses.add('dateTime >= ? AND dateTime <= ?');
      whereArgs.add(filter.dateRange!.start.toIso8601String());
      whereArgs.add(filter.dateRange!.end.toIso8601String());
    }

    // Filter by Min Amount
    if (filter.minAmount != null) {
      whereClauses.add('amount >= ?');
      whereArgs.add(filter.minAmount);
    }

    // Filter by Max Amount
    if (filter.maxAmount != null) {
      whereClauses.add('amount <= ?');
      whereArgs.add(filter.maxAmount);
    }

    // Search query
    if (filter.searchQuery.trim().isNotEmpty) {
      final q = '%${filter.searchQuery.trim()}%';
      whereClauses.add('(title LIKE ? OR description LIKE ? OR categoryName LIKE ?)');
      whereArgs.addAll([q, q, q]);
    }

    String orderBy = 'dateTime DESC, createdAt DESC';
    switch (filter.sortBy) {
      case SortOption.newestFirst:
        orderBy = 'dateTime DESC, createdAt DESC';
        break;
      case SortOption.oldestFirst:
        orderBy = 'dateTime ASC, createdAt ASC';
        break;
      case SortOption.highestAmount:
        orderBy = 'amount DESC';
        break;
      case SortOption.lowestAmount:
        orderBy = 'amount ASC';
        break;
    }

    final maps = await db.query(
      'transactions',
      where: whereClauses.join(' AND '),
      whereArgs: whereArgs,
      orderBy: orderBy,
    );

    return maps.map((m) => TransactionModel.fromMap(m)).toList();
  }

  // ==========================================
  // AGGREGATIONS & REPORTS
  // ==========================================

  Future<Map<String, double>> getTotals({DateTimeRange? dateRange}) async {
    final db = await database;
    String whereClause = 'isTemplate = 0';
    List<dynamic> args = [];

    if (dateRange != null) {
      whereClause += ' AND dateTime >= ? AND dateTime <= ?';
      args.addAll([dateRange.start.toIso8601String(), dateRange.end.toIso8601String()]);
    }

    final incomeResult = await db.rawQuery(
      'SELECT SUM(amount) as total FROM transactions WHERE $whereClause AND type = "income"',
      args,
    );
    final expenseResult = await db.rawQuery(
      'SELECT SUM(amount) as total FROM transactions WHERE $whereClause AND type = "expense"',
      args,
    );

    final double totalIncome = (incomeResult.first['total'] as num?)?.toDouble() ?? 0.0;
    final double totalExpense = (expenseResult.first['total'] as num?)?.toDouble() ?? 0.0;

    return {
      'income': totalIncome,
      'expense': totalExpense,
      'net': totalIncome - totalExpense,
    };
  }

  Future<Map<String, double>> getCategoryExpenseDistribution({DateTimeRange? dateRange}) async {
    final db = await database;
    String whereClause = 'isTemplate = 0 AND type = "expense"';
    List<dynamic> args = [];

    if (dateRange != null) {
      whereClause += ' AND dateTime >= ? AND dateTime <= ?';
      args.addAll([dateRange.start.toIso8601String(), dateRange.end.toIso8601String()]);
    }

    final results = await db.rawQuery(
      '''
      SELECT categoryName, SUM(amount) as total 
      FROM transactions 
      WHERE $whereClause 
      GROUP BY categoryName 
      ORDER BY total DESC
      ''',
      args,
    );

    final map = <String, double>{};
    for (final row in results) {
      final name = row['categoryName'] as String;
      final total = (row['total'] as num?)?.toDouble() ?? 0.0;
      map[name] = total;
    }
    return map;
  }

  // ==========================================
  // CATEGORIES CRUD
  // ==========================================

  Future<List<CategoryModel>> getAllCategoriesWithCounts({CategoryType? type}) async {
    final db = await database;
    
    String where = '';
    List<dynamic> args = [];
    if (type != null && type != CategoryType.both) {
      where = 'WHERE c.type = ? OR c.type = "both"';
      args.add(type.name);
    }

    final results = await db.rawQuery('''
      SELECT c.*, COUNT(t.id) as txCount
      FROM categories c
      LEFT JOIN transactions t ON c.id = t.categoryId AND t.isTemplate = 0
      $where
      GROUP BY c.id
      ORDER BY c.name ASC
    ''', args);

    return results.map((m) {
      final count = (m['txCount'] as num?)?.toInt() ?? 0;
      return CategoryModel.fromMap(m, transactionCount: count);
    }).toList();
  }

  Future<int> insertCategory(CategoryModel category) async {
    final db = await database;
    return await db.insert(
      'categories',
      category.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<int> updateCategory(CategoryModel category) async {
    final db = await database;
    return await db.update(
      'categories',
      category.toMap(),
      where: 'id = ?',
      whereArgs: [category.id],
    );
  }

  Future<int> deleteCategory(String id, {String? migrateToCategoryId}) async {
    final db = await database;
    if (migrateToCategoryId != null) {
      final targetCat = await db.query('categories', where: 'id = ?', whereArgs: [migrateToCategoryId]);
      final targetName = targetCat.isNotEmpty ? targetCat.first['name'] as String : 'Other';
      await db.update(
        'transactions',
        {'categoryId': migrateToCategoryId, 'categoryName': targetName},
        where: 'categoryId = ?',
        whereArgs: [id],
      );
    }
    return await db.delete('categories', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> seedInitialData() async {
    try {
      final db = await database;
      final existingTx = await db.query('transactions', limit: 1);
      if (existingTx.isEmpty) {
        final batch = db.batch();
        for (final tx in SeedData.sampleTransactions) {
          batch.insert(
            'transactions',
            tx.toMap(),
            conflictAlgorithm: ConflictAlgorithm.replace,
          );
        }
        await batch.commit(noResult: true);
      }
    } catch (e) {
      debugPrint('seedInitialData notice: $e');
    }
  }

  Future<void> clearAllData() async {
    final db = await database;
    await db.delete('transactions');
    await db.delete('categories');
    // Re-seed categories
    final batch = db.batch();
    for (final cat in SeedData.categories) {
      batch.insert('categories', cat.toMap());
    }
    await batch.commit(noResult: true);
  }
}
