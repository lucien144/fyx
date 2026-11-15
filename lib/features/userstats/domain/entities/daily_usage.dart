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
  /// Distinct calendar days, ascending. UTC midnights, so that a day is always
  /// exactly 24 hours apart from the next one regardless of DST.
  List<DateTime> get _days {
    return map((e) => DateTime.utc(e.date.year, e.date.month, e.date.day)).toSet().toList()..sort();
  }

  /// Number of distinct days the app was opened on
  int get activeDays => _days.length;

  /// The earliest recorded day, null if empty
  DateTime? get firstDay {
    final days = _days;
    return days.isEmpty ? null : DateTime(days.first.year, days.first.month, days.first.day);
  }

  /// Calculate the longest streak of consecutive days within the year
  int get longestStreak {
    final days = _days;
    if (days.isEmpty) return 0;

    int longest = 1;
    int current = 1;

    for (int i = 1; i < days.length; i++) {
      if (days[i].difference(days[i - 1]).inDays == 1) {
        current++;
        longest = max(longest, current);
      } else {
        current = 1;
      }
    }

    return longest;
  }

  /// Calculate current streak within the year
  /// For current year: consecutive days ending today or yesterday
  /// For past years: streak ending at the most recent recorded day
  int get currentStreak => currentStreakAt(DateTime.now());

  /// [currentStreak] evaluated against an explicit clock
  int currentStreakAt(DateTime now) {
    final days = _days.reversed.toList();
    if (days.isEmpty) return 0;

    // For current year, streak is broken if last activity was more than 1 day ago
    if (first.year == now.year) {
      final today = DateTime.utc(now.year, now.month, now.day);
      if (today.difference(days.first).inDays > 1) return 0;
    }

    int streak = 1;
    for (int i = 1; i < days.length; i++) {
      if (days[i - 1].difference(days[i]).inDays != 1) break;
      streak++;
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
