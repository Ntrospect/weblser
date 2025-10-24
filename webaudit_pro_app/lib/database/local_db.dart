import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'dart:convert';

class LocalDatabase {
  static const String dbName = 'websler_pro.db';
  static const int dbVersion = 1;

  static final LocalDatabase _instance = LocalDatabase._internal();
  factory LocalDatabase() => _instance;
  LocalDatabase._internal();

  static Database? _database;

  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final databasePath = await getDatabasesPath();
    final path = join(databasePath, dbName);

    return await openDatabase(
      path,
      version: dbVersion,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // Create local tables that mirror Supabase

    // 1. Local Users
    await db.execute('''
      CREATE TABLE users (
        id TEXT PRIMARY KEY,
        email TEXT NOT NULL,
        full_name TEXT,
        company_name TEXT,
        company_details TEXT,
        avatar_url TEXT,
        created_at TEXT,
        updated_at TEXT,
        synced INTEGER DEFAULT 0
      )
    ''');

    // 2. Local Website Summaries
    await db.execute('''
      CREATE TABLE website_summaries (
        id TEXT PRIMARY KEY,
        user_id TEXT NOT NULL,
        url TEXT NOT NULL,
        website_name TEXT NOT NULL,
        summary TEXT NOT NULL,
        created_at TEXT,
        updated_at TEXT,
        synced INTEGER DEFAULT 0,
        FOREIGN KEY (user_id) REFERENCES users(id)
      )
    ''');

    // 3. Local Audit Results
    await db.execute('''
      CREATE TABLE audit_results (
        id TEXT PRIMARY KEY,
        user_id TEXT NOT NULL,
        website_name TEXT NOT NULL,
        url TEXT NOT NULL,
        overall_score REAL NOT NULL,
        scores TEXT NOT NULL,
        key_strengths TEXT NOT NULL,
        critical_issues TEXT NOT NULL,
        created_at TEXT,
        updated_at TEXT,
        synced INTEGER DEFAULT 0,
        FOREIGN KEY (user_id) REFERENCES users(id)
      )
    ''');

    // 4. Local Recommendations
    await db.execute('''
      CREATE TABLE recommendations (
        id TEXT PRIMARY KEY,
        audit_id TEXT NOT NULL,
        user_id TEXT NOT NULL,
        criterion TEXT NOT NULL,
        recommendation TEXT NOT NULL,
        priority TEXT NOT NULL,
        impact_score REAL NOT NULL,
        created_at TEXT,
        synced INTEGER DEFAULT 0,
        FOREIGN KEY (audit_id) REFERENCES audit_results(id),
        FOREIGN KEY (user_id) REFERENCES users(id)
      )
    ''');

    // 5. Sync Queue (tracks what needs syncing)
    await db.execute('''
      CREATE TABLE sync_queue (
        id TEXT PRIMARY KEY,
        table_name TEXT NOT NULL,
        record_id TEXT NOT NULL,
        operation TEXT NOT NULL,
        data TEXT NOT NULL,
        created_at TEXT,
        retry_count INTEGER DEFAULT 0,
        last_error TEXT
      )
    ''');

    // 6. Offline Metadata (track sync state)
    await db.execute('''
      CREATE TABLE offline_metadata (
        key TEXT PRIMARY KEY,
        value TEXT,
        updated_at TEXT
      )
    ''');

    print('✅ Local SQLite database initialized');
  }

  // ============================================
  // QUERY METHODS
  // ============================================

  // Save audit result locally
  Future<void> saveAuditLocal(Map<String, dynamic> auditData) async {
    final db = await database;
    await db.insert(
      'audit_results',
      {
        ...auditData,
        'created_at': auditData['created_at'] ?? DateTime.now().toIso8601String(),
        'synced': 0,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Save summary locally
  Future<void> saveSummaryLocal(Map<String, dynamic> summaryData) async {
    final db = await database;
    await db.insert(
      'website_summaries',
      {
        ...summaryData,
        'created_at': summaryData['created_at'] ?? DateTime.now().toIso8601String(),
        'synced': 0,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Get all user's audits from local DB
  Future<List<Map<String, dynamic>>> getAuditsLocal(String userId) async {
    final db = await database;
    return await db.query(
      'audit_results',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'created_at DESC',
    ) as List<Map<String, dynamic>>;
  }

  // Get all user's summaries from local DB
  Future<List<Map<String, dynamic>>> getSummariesLocal(String userId) async {
    final db = await database;
    return await db.query(
      'website_summaries',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'created_at DESC',
    ) as List<Map<String, dynamic>>;
  }

  // Get unsynced records (need to upload to Supabase)
  Future<List<Map<String, dynamic>>> getUnsyncedRecords(String tableName) async {
    final db = await database;
    return await db.query(
      tableName,
      where: 'synced = ?',
      whereArgs: [0],
    ) as List<Map<String, dynamic>>;
  }

  // Mark as synced after successful upload
  Future<void> markSynced(String tableName, String recordId) async {
    final db = await database;
    await db.update(
      tableName,
      {
        'synced': 1,
        'updated_at': DateTime.now().toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [recordId],
    );
  }

  // Add to sync queue (for retry logic)
  Future<void> addToSyncQueue(
    String tableName,
    String recordId,
    String operation,
    Map<String, dynamic> data,
  ) async {
    final db = await database;
    await db.insert(
      'sync_queue',
      {
        'id': DateTime.now().millisecondsSinceEpoch.toString(),
        'table_name': tableName,
        'record_id': recordId,
        'operation': operation,
        'data': jsonEncode(data),
        'created_at': DateTime.now().toIso8601String(),
        'retry_count': 0,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Get all pending sync items
  Future<List<Map<String, dynamic>>> getSyncQueue() async {
    final db = await database;
    return await db.query(
      'sync_queue',
      orderBy: 'created_at ASC',
    ) as List<Map<String, dynamic>>;
  }

  // Remove from sync queue after successful sync
  Future<void> removeSyncQueueItem(String queueId) async {
    final db = await database;
    await db.delete('sync_queue', where: 'id = ?', whereArgs: [queueId]);
  }

  // Increment retry count for sync item
  Future<void> incrementRetryCount(String queueId, String? errorMessage) async {
    final db = await database;
    await db.rawUpdate(
      'UPDATE sync_queue SET retry_count = retry_count + 1, last_error = ? WHERE id = ?',
      [errorMessage, queueId],
    );
  }

  // Save user profile locally
  Future<void> saveUserLocal(Map<String, dynamic> userData) async {
    final db = await database;
    await db.insert(
      'users',
      {
        ...userData,
        'created_at': userData['created_at'] ?? DateTime.now().toIso8601String(),
        'synced': 1, // Mark as synced since it came from auth
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Get user profile
  Future<Map<String, dynamic>?> getUserLocal(String userId) async {
    final db = await database;
    final results = await db.query(
      'users',
      where: 'id = ?',
      whereArgs: [userId],
    );
    return results.isNotEmpty ? results.first as Map<String, dynamic> : null;
  }

  // Clear all local data (logout)
  Future<void> clearAllData() async {
    final db = await database;
    await db.delete('audit_results');
    await db.delete('website_summaries');
    await db.delete('recommendations');
    await db.delete('sync_queue');
    await db.delete('users');
    print('✅ All local data cleared');
  }

  // Close database
  Future<void> close() async {
    final db = await database;
    await db.close();
  }
}
