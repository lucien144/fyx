import 'package:fyx/features/userstats/domain/entities/daily_usage.dart';
import 'package:fyx/features/userstats/domain/entities/discussion_visit.dart';
import 'package:fyx/features/userstats/domain/entities/global_stat.dart';
import 'package:fyx/features/userstats/domain/entities/hourly_usage.dart';

/// Abstract repository interface for user statistics
abstract class UserstatsRepository {
  // ==================== Global Stats ====================

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

  // ==================== Discussion Visits ====================

  /// Get all discussion visits
  Future<List<DiscussionVisit>> getAllDiscussionVisits();

  /// Get discussion visits by year
  Future<List<DiscussionVisit>> getDiscussionVisitsByYear(int year);

  /// Get discussion visit by year and discussion ID
  Future<DiscussionVisit?> getDiscussionVisit(int year, int discussionId);

  /// Increment visit count for a discussion (creates if not exists)
  Future<void> trackDiscussionVisit(int year, int discussionId, String discussionName);

  /// Clear all discussion visits
  Future<void> clearAllDiscussionVisits();

  // ==================== Daily Usage ====================

  /// Get all daily usage records
  Future<List<DailyUsage>> getAllDailyUsage();

  /// Get daily usage records by year
  Future<List<DailyUsage>> getDailyUsageByYear(int year);

  /// Track usage for today (idempotent - safe to call multiple times per day)
  Future<void> trackDailyUsage();

  /// Clear all daily usage records
  Future<void> clearAllDailyUsage();

  // ==================== Hourly Usage ====================

  /// Get hourly usage records by year
  Future<List<HourlyUsage>> getHourlyUsageByYear(int year);

  /// Track usage for the current hour (increments count)
  Future<void> trackHourlyUsage();

  /// Clear all hourly usage records
  Future<void> clearAllHourlyUsage();
}