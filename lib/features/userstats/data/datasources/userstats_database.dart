import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

/// SQLite database helper for user statistics
class UserstatsDatabase {
  static const String _databaseName = 'userstats.db';
  static const int _databaseVersion = 1;

  // Table names
  static const String tableGlobals = 'globals';

  // Column names for globals table
  static const String columnYear = 'year';
  static const String columnStatType = 'stat_type';
  static const String columnNumber = 'number';

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
  }

  /// Handle database migrations
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Future migrations go here
    // Example:
    // if (oldVersion < 2) {
    //   await db.execute('ALTER TABLE ...');
    // }
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

  /// Close database connection
  Future<void> close() async {
    final db = _database;
    if (db != null) {
      await db.close();
      _database = null;
    }
  }
}