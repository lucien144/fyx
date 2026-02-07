import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

/// SQLite database helper for user statistics
class UserstatsDatabase {
  static const String _databaseName = 'userstats.db';
  static const int _databaseVersion = 2;

  // Table names
  static const String tableGlobals = 'globals';
  static const String tableDiscussionVisits = 'discussion_visits';

  // Column names for globals table
  static const String columnYear = 'year';
  static const String columnStatType = 'stat_type';
  static const String columnNumber = 'number';

  // Column names for discussion_visits table
  static const String columnDiscussionId = 'discussion_id';
  static const String columnDiscussionName = 'discussion_name';
  static const String columnVisits = 'visits';

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
  }

  /// Handle database migrations
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await _createDiscussionVisitsTable(db);
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

  /// Close database connection
  Future<void> close() async {
    final db = _database;
    if (db != null) {
      await db.close();
      _database = null;
    }
  }
}