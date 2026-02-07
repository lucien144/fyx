import 'package:fyx/features/userstats/data/datasources/userstats_database.dart';
import 'package:fyx/features/userstats/data/models/discussion_visit_model.dart';
import 'package:fyx/features/userstats/data/models/global_stat_model.dart';
import 'package:fyx/features/userstats/domain/entities/discussion_visit.dart';
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

  // ==================== Discussion Visits ====================

  @override
  Future<List<DiscussionVisit>> getAllDiscussionVisits() async {
    final db = await _database.database;
    final maps = await db.query(UserstatsDatabase.tableDiscussionVisits);
    return maps.map((map) => DiscussionVisitModel.fromMap(map).toEntity()).toList();
  }

  @override
  Future<List<DiscussionVisit>> getDiscussionVisitsByYear(int year) async {
    final db = await _database.database;
    final maps = await db.query(
      UserstatsDatabase.tableDiscussionVisits,
      where: '${UserstatsDatabase.columnYear} = ?',
      whereArgs: [year],
      orderBy: '${UserstatsDatabase.columnVisits} DESC',
      limit: 10,
    );
    return maps.map((map) => DiscussionVisitModel.fromMap(map).toEntity()).toList();
  }

  @override
  Future<DiscussionVisit?> getDiscussionVisit(int year, int discussionId) async {
    final db = await _database.database;
    final maps = await db.query(
      UserstatsDatabase.tableDiscussionVisits,
      where: '${UserstatsDatabase.columnYear} = ? AND ${UserstatsDatabase.columnDiscussionId} = ?',
      whereArgs: [year, discussionId],
    );
    if (maps.isEmpty) return null;
    return DiscussionVisitModel.fromMap(maps.first).toEntity();
  }

  @override
  Future<void> trackDiscussionVisit(int year, int discussionId, String discussionName) async {
    final db = await _database.database;
    await db.rawInsert('''
      INSERT INTO ${UserstatsDatabase.tableDiscussionVisits}
        (${UserstatsDatabase.columnYear}, ${UserstatsDatabase.columnDiscussionId}, ${UserstatsDatabase.columnDiscussionName}, ${UserstatsDatabase.columnVisits})
      VALUES (?, ?, ?, 1)
      ON CONFLICT(${UserstatsDatabase.columnYear}, ${UserstatsDatabase.columnDiscussionId})
      DO UPDATE SET
        ${UserstatsDatabase.columnVisits} = ${UserstatsDatabase.columnVisits} + 1,
        ${UserstatsDatabase.columnDiscussionName} = excluded.${UserstatsDatabase.columnDiscussionName}
    ''', [year, discussionId, discussionName]);
  }

  @override
  Future<void> clearAllDiscussionVisits() async {
    final db = await _database.database;
    await db.delete(UserstatsDatabase.tableDiscussionVisits);
  }
}