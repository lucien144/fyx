import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:fyx/features/userstats/data/datasources/userstats_database.dart';
import 'package:fyx/features/userstats/domain/entities/hourly_usage.dart';

part 'hourly_usage_model.freezed.dart';

/// Data model for HourlyUsage with database serialization support
@freezed
class HourlyUsageModel with _$HourlyUsageModel {
  const HourlyUsageModel._();

  const factory HourlyUsageModel({
    required int year,
    required int hour,
    required int count,
  }) = _HourlyUsageModel;

  /// Create model from database map
  factory HourlyUsageModel.fromMap(Map<String, dynamic> map) {
    return HourlyUsageModel(
      year: map[UserstatsDatabase.columnYear] as int,
      hour: map[UserstatsDatabase.columnHour] as int,
      count: map[UserstatsDatabase.columnCount] as int,
    );
  }

  /// Create model from domain entity
  factory HourlyUsageModel.fromEntity(HourlyUsage entity) {
    return HourlyUsageModel(
      year: entity.year,
      hour: entity.hour,
      count: entity.count,
    );
  }

  /// Convert to database map
  Map<String, dynamic> toMap() {
    return {
      UserstatsDatabase.columnYear: year,
      UserstatsDatabase.columnHour: hour,
      UserstatsDatabase.columnCount: count,
    };
  }

  /// Convert to domain entity
  HourlyUsage toEntity() {
    return HourlyUsage(year: year, hour: hour, count: count);
  }
}
