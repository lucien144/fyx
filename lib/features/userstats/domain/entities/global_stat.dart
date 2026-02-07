import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:fyx/features/userstats/domain/enums/global_stat_type.dart';

part 'global_stat.freezed.dart';

/// Domain entity representing a global statistic record
@freezed
class GlobalStat with _$GlobalStat {
  const factory GlobalStat({
    required int year,
    required String statType,
    required int number,
  }) = _GlobalStat;
}

/// Extension for easy access to stats by GlobalStatType
extension GlobalStatListExtension on List<GlobalStat> {
  /// Get stat value by GlobalStatType, returns 0 if not found
  int valueOf(GlobalStatType type) {
    return where((s) => s.statType == type.value).firstOrNull?.number ?? 0;
  }

  /// Get GlobalStat by GlobalStatType, returns null if not found
  GlobalStat? statOf(GlobalStatType type) {
    return where((s) => s.statType == type.value).firstOrNull;
  }

  /// Convert list to Map<GlobalStatType, int>
  Map<GlobalStatType, int> toStatMap() {
    final map = <GlobalStatType, int>{};
    for (final stat in this) {
      final type = GlobalStatType.fromValue(stat.statType);
      if (type != null) {
        map[type] = stat.number;
      }
    }
    return map;
  }
}
