import 'dart:math';

import 'package:freezed_annotation/freezed_annotation.dart';

part 'daily_usage.freezed.dart';

/// Domain entity representing a daily usage record
@freezed
class DailyUsage with _$DailyUsage {
  const factory DailyUsage({
    required int year,
    required DateTime date,
  }) = _DailyUsage;
}

/// Extension for calculating streaks from daily usage list
extension DailyUsageListExtension on List<DailyUsage> {
  /// Calculate the longest streak of consecutive days within the year
  int get longestStreak {
    if (isEmpty) return 0;

    final dates = map((e) => DateTime(e.date.year, e.date.month, e.date.day)).toList()..sort();

    int longest = 1;
    int current = 1;

    for (int i = 1; i < dates.length; i++) {
      final diff = dates[i].difference(dates[i - 1]).inDays;
      if (diff == 1) {
        current++;
        longest = max(longest, current);
      } else if (diff > 1) {
        current = 1;
      }
      // diff == 0 means duplicate day, skip
    }

    return longest;
  }

  /// Calculate current streak within the year
  /// For current year: consecutive days ending today or yesterday
  /// For past years: streak ending at the most recent recorded day
  int get currentStreak {
    if (isEmpty) return 0;

    final year = first.year;
    final now = DateTime.now();
    final isCurrentYear = year == now.year;

    // Removing duplicate days
    final dates = map((e) => DateTime(e.date.year, e.date.month, e.date.day)).toSet().toList()..sort((a, b) => b.compareTo(a));

    final mostRecent = dates.first;

    // For current year, streak is broken if last activity was more than 1 day ago
    if (isCurrentYear) {
      final todayNormalized = DateTime(now.year, now.month, now.day);
      final daysSinceMostRecent = todayNormalized.difference(mostRecent).inDays;
      if (daysSinceMostRecent > 1) return 0;
    }
    // For past years, just return the streak ending at the most recent recorded day

    int streak = 1;
    for (int i = 1; i < dates.length; i++) {
      final diff = dates[i - 1].difference(dates[i]).inDays;
      if (diff == 1) {
        streak++;
      } else {
        break;
      }
    }

    return streak;
  }

  /// Total number of active days
  int get totalDays => length;

  /// Convert to a map of weekday (1=Monday, 7=Sunday) → number of active days
  Map<int, int> toWeekdayMap() {
    final map = {for (var i = 1; i <= 7; i++) i: 0};
    for (final usage in this) {
      final weekday = usage.date.weekday;
      map[weekday] = map[weekday]! + 1;
    }
    return map;
  }

  /// Get the most active weekday (1=Monday, 7=Sunday), returns -1 if empty
  int get peakWeekday {
    if (isEmpty) return -1;
    final weekdayMap = toWeekdayMap();
    return weekdayMap.entries.reduce((a, b) => a.value >= b.value ? a : b).key;
  }

  /// Convert to a map of month (1-12) → number of active days
  Map<int, int> toMonthMap() {
    final map = {for (var i = 1; i <= 12; i++) i: 0};
    for (final usage in this) {
      final month = usage.date.month;
      map[month] = map[month]! + 1;
    }
    return map;
  }

  /// Get the most active month (1-12), returns -1 if empty
  int get peakMonth {
    if (isEmpty) return -1;
    final monthMap = toMonthMap();
    return monthMap.entries.reduce((a, b) => a.value >= b.value ? a : b).key;
  }
}
