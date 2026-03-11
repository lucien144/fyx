import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:fyx/features/userstats/data/datasources/userstats_database.dart';
import 'package:fyx/features/userstats/domain/entities/global_stat.dart';

part 'global_stat_model.freezed.dart';

/// Data model for GlobalStat with database serialization support
@freezed
class GlobalStatModel with _$GlobalStatModel {
  const GlobalStatModel._();

  const factory GlobalStatModel({
    required int year,
    required String statType,
    required int number,
  }) = _GlobalStatModel;

  /// Create model from database map
  factory GlobalStatModel.fromMap(Map<String, dynamic> map) {
    return GlobalStatModel(
      year: map[UserstatsDatabase.columnYear] as int,
      statType: map[UserstatsDatabase.columnStatType] as String,
      number: map[UserstatsDatabase.columnNumber] as int,
    );
  }

  /// Create model from domain entity
  factory GlobalStatModel.fromEntity(GlobalStat entity) {
    return GlobalStatModel(
      year: entity.year,
      statType: entity.statType,
      number: entity.number,
    );
  }

  /// Convert to database map
  Map<String, dynamic> toMap() {
    return {
      UserstatsDatabase.columnYear: year,
      UserstatsDatabase.columnStatType: statType,
      UserstatsDatabase.columnNumber: number,
    };
  }

  /// Convert to domain entity
  GlobalStat toEntity() {
    return GlobalStat(
      year: year,
      statType: statType,
      number: number,
    );
  }
}
