import 'package:fyx/features/userstats/domain/entities/global_stat.dart';

/// Abstract repository interface for user statistics
abstract class UserstatsRepository {
  /// Get all global stats
  Future<List<GlobalStat>> getAllGlobalStats();

  /// Get global stats by year
  Future<List<GlobalStat>> getGlobalStatsByYear(int year);

  /// Get global stat by year and type
  Future<GlobalStat?> getGlobalStat(int year, String statType);

  /// Insert or update a global stat
  Future<void> upsertGlobalStat(GlobalStat stat);

  /// Delete a global stat
  Future<void> deleteGlobalStat(int year, String statType);

  /// Clear all global stats
  Future<void> clearAllGlobalStats();
}