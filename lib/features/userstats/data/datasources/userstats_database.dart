import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

/// SQLite database helper for user statistics
class UserstatsDatabase {
  static const String _databaseName = 'userstats.db';
  static const int _databaseVersion = 5;

  // Table names
  static const String tableGlobals = 'globals';
  static const String tableDiscussionVisits = 'discussion_visits';
  static const String tableDailyUsage = 'daily_usage';
  static const String tableHourlyUsage = 'hourly_usage';

  // Column names for globals table
  static const String columnYear = 'year';
  static const String columnStatType = 'stat_type';
  static const String columnNumber = 'number';

  // Column names for discussion_visits table
  static const String columnDiscussionId = 'discussion_id';
  static const String columnDiscussionName = 'discussion_name';
  static const String columnVisits = 'visits';

  // Column names for daily_usage table
  static const String columnDate = 'date';

  // Column names for hourly_usage table
  static const String columnHour = 'hour';
  static const String columnCount = 'count';

  Database? _database;

  /// Get database instance (lazy initialization)
  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  /// Initialize database
  Future<Database> _initDatabase() async {
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, _databaseName);

    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  /// Create tables on first database creation
  Future<void> _onCreate(Database db, int version) async {
    await _createGlobalsTable(db);
    await _createDiscussionVisitsTable(db);
    await _createDailyUsageTable(db);
    await _createHourlyUsageTable(db);
  }

  /// Handle database migrations
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await _createDiscussionVisitsTable(db);
    }
    if (oldVersion < 3) {
      await _createDailyUsageTable(db);
    }
    if (oldVersion < 4) {
      await _migrateDailyUsageAddYear(db);
    }
    if (oldVersion < 5) {
      await _createHourlyUsageTable(db);
    }
  }

  /// Create globals table
  Future<void> _createGlobalsTable(Database db) async {
    await db.execute('''
      CREATE TABLE $tableGlobals (
        $columnYear INTEGER NOT NULL,
        $columnStatType TEXT NOT NULL,
        $columnNumber INTEGER NOT NULL,
        PRIMARY KEY ($columnYear, $columnStatType)
      )
    ''');
  }

  /// Create discussion_visits table
  Future<void> _createDiscussionVisitsTable(Database db) async {
    await db.execute('''
      CREATE TABLE $tableDiscussionVisits (
        $columnYear INTEGER NOT NULL,
        $columnDiscussionId INTEGER NOT NULL,
        $columnDiscussionName TEXT NOT NULL,
        $columnVisits INTEGER NOT NULL,
        PRIMARY KEY ($columnYear, $columnDiscussionId)
      )
    ''');
  }

  /// Create daily_usage table
  Future<void> _createDailyUsageTable(Database db) async {
    await db.execute('''
      CREATE TABLE $tableDailyUsage (
        $columnYear INTEGER NOT NULL,
        $columnDate TEXT NOT NULL,
        PRIMARY KEY ($columnYear, $columnDate)
      )
    ''');
  }

  /// Create hourly_usage table
  Future<void> _createHourlyUsageTable(Database db) async {
    await db.execute('''
      CREATE TABLE $tableHourlyUsage (
        $columnYear INTEGER NOT NULL,
        $columnHour INTEGER NOT NULL,
        $columnCount INTEGER NOT NULL,
        PRIMARY KEY ($columnYear, $columnHour)
      )
    ''');
  }

  /// Migration: Add year column to daily_usage table
  Future<void> _migrateDailyUsageAddYear(Database db) async {
    // Create new table with year column
    await db.execute('''
      CREATE TABLE ${tableDailyUsage}_new (
        $columnYear INTEGER NOT NULL,
        $columnDate TEXT NOT NULL,
        PRIMARY KEY ($columnYear, $columnDate)
      )
    ''');

    // Copy data from old table, extracting year from date (YYYY-MM-DD)
    await db.execute('''
      INSERT INTO ${tableDailyUsage}_new ($columnYear, $columnDate)
      SELECT CAST(substr($columnDate, 1, 4) AS INTEGER), $columnDate
      FROM $tableDailyUsage
    ''');

    // Drop old table
    await db.execute('DROP TABLE $tableDailyUsage');

    // Rename new table
    await db.execute('ALTER TABLE ${tableDailyUsage}_new RENAME TO $tableDailyUsage');
  }

  /// Close database connection
  Future<void> close() async {
    final db = _database;
    if (db != null) {
      await db.close();
      _database = null;
    }
  }
}