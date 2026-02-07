import 'package:fyx/features/userstats/data/datasources/userstats_database.dart';
import 'package:fyx/features/userstats/data/models/global_stat_model.dart';
import 'package:fyx/features/userstats/domain/entities/global_stat.dart';
import 'package:fyx/features/userstats/domain/repositories/userstats_repository.dart';

/// Implementation of UserstatsRepository using SQLite
class UserstatsRepositoryImpl implements UserstatsRepository {
  final UserstatsDatabase _database;

  UserstatsRepositoryImpl(this._database);

  @override
  Future<List<GlobalStat>> getAllGlobalStats() async {
    final db = await _database.database;
    final maps = await db.query(UserstatsDatabase.tableGlobals);
    return maps.map((map) => GlobalStatModel.fromMap(map).toEntity()).toList();
  }

  @override
  Future<List<GlobalStat>> getGlobalStatsByYear(int year) async {
    final db = await _database.database;
    final maps = await db.query(
      UserstatsDatabase.tableGlobals,
      where: '${UserstatsDatabase.columnYear} = ?',
      whereArgs: [year],
    );
    return maps.map((map) => GlobalStatModel.fromMap(map).toEntity()).toList();
  }

  @override
  Future<GlobalStat?> getGlobalStat(int year, String statType) async {
    final db = await _database.database;
    final maps = await db.query(
      UserstatsDatabase.tableGlobals,
      where: '${UserstatsDatabase.columnYear} = ? AND ${UserstatsDatabase.columnStatType} = ?',
      whereArgs: [year, statType],
    );
    if (maps.isEmpty) return null;
    return GlobalStatModel.fromMap(maps.first).toEntity();
  }

  @override
  Future<void> upsertGlobalStat(GlobalStat stat) async {
    final db = await _database.database;
    await db.rawInsert('''
      INSERT INTO ${UserstatsDatabase.tableGlobals}
        (${UserstatsDatabase.columnYear}, ${UserstatsDatabase.columnStatType}, ${UserstatsDatabase.columnNumber})
      VALUES (?, ?, ?)
      ON CONFLICT(${UserstatsDatabase.columnYear}, ${UserstatsDatabase.columnStatType})
      DO UPDATE SET ${UserstatsDatabase.columnNumber} = ${UserstatsDatabase.columnNumber} + excluded.${UserstatsDatabase.columnNumber}
    ''', [stat.year, stat.statType, stat.number]);
  }

  @override
  Future<void> deleteGlobalStat(int year, String statType) async {
    final db = await _database.database;
    await db.delete(
      UserstatsDatabase.tableGlobals,
      where: '${UserstatsDatabase.columnYear} = ? AND ${UserstatsDatabase.columnStatType} = ?',
      whereArgs: [year, statType],
    );
  }

  @override
  Future<void> clearAllGlobalStats() async {
    final db = await _database.database;
    await db.delete(UserstatsDatabase.tableGlobals);
  }
}