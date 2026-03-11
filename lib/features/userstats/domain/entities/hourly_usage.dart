import 'package:freezed_annotation/freezed_annotation.dart';

part 'hourly_usage.freezed.dart';

/// Domain entity representing an hourly usage record
@freezed
class HourlyUsage with _$HourlyUsage {
  const factory HourlyUsage({
    required int year,
    required int hour,
    required int count,
  }) = _HourlyUsage;
}

/// Extension for analyzing hourly usage patterns
extension HourlyUsageListExtension on List<HourlyUsage> {
  /// Get the most active hour (0-23), returns -1 if empty
  int get peakHour {
    if (isEmpty) return -1;
    return reduce((a, b) => a.count >= b.count ? a : b).hour;
  }

  /// Convert to a map of hour (0-23) → count, with default 0 for missing hours
  Map<int, int> toHourMap() {
    final map = {for (var i = 0; i < 24; i++) i: 0};
    for (final usage in this) {
      map[usage.hour] = usage.count;
    }
    return map;
  }
}
