import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:fyx/features/userstats/data/datasources/userstats_database.dart';
import 'package:fyx/features/userstats/domain/entities/daily_usage.dart';

part 'daily_usage_model.freezed.dart';

/// Data model for DailyUsage with database serialization support
@freezed
class DailyUsageModel with _$DailyUsageModel {
  const DailyUsageModel._();

  const factory DailyUsageModel({
    required int year,
    required DateTime date,
  }) = _DailyUsageModel;

  /// Create model from database map
  factory DailyUsageModel.fromMap(Map<String, dynamic> map) {
    return DailyUsageModel(
      year: map[UserstatsDatabase.columnYear] as int,
      date: DateTime.parse(map[UserstatsDatabase.columnDate] as String),
    );
  }

  /// Create model from domain entity
  factory DailyUsageModel.fromEntity(DailyUsage entity) {
    return DailyUsageModel(
      year: entity.year,
      date: entity.date,
    );
  }

  /// Convert to database map (date as YYYY-MM-DD)
  Map<String, dynamic> toMap() {
    return {
      UserstatsDatabase.columnYear: year,
      UserstatsDatabase.columnDate: _formatDate(date),
    };
  }

  /// Convert to domain entity
  DailyUsage toEntity() {
    return DailyUsage(year: year, date: date);
  }

  /// Format date as YYYY-MM-DD
  static String _formatDate(DateTime date) {
    return '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  /// Get formatted date string for today
  static String todayFormatted() {
    return _formatDate(DateTime.now());
  }
}
