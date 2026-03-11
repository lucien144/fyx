import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:fyx/features/userstats/data/datasources/userstats_database.dart';
import 'package:fyx/features/userstats/domain/entities/discussion_visit.dart';

part 'discussion_visit_model.freezed.dart';

/// Data model for DiscussionVisit with database serialization support
@freezed
class DiscussionVisitModel with _$DiscussionVisitModel {
  const DiscussionVisitModel._();

  const factory DiscussionVisitModel({
    required int year,
    required int discussionId,
    required String discussionName,
    required int visits,
  }) = _DiscussionVisitModel;

  /// Create model from database map
  factory DiscussionVisitModel.fromMap(Map<String, dynamic> map) {
    return DiscussionVisitModel(
      year: map[UserstatsDatabase.columnYear] as int,
      discussionId: map[UserstatsDatabase.columnDiscussionId] as int,
      discussionName: map[UserstatsDatabase.columnDiscussionName] as String,
      visits: map[UserstatsDatabase.columnVisits] as int,
    );
  }

  /// Create model from domain entity
  factory DiscussionVisitModel.fromEntity(DiscussionVisit entity) {
    return DiscussionVisitModel(
      year: entity.year,
      discussionId: entity.discussionId,
      discussionName: entity.discussionName,
      visits: entity.visits,
    );
  }

  /// Convert to database map
  Map<String, dynamic> toMap() {
    return {
      UserstatsDatabase.columnYear: year,
      UserstatsDatabase.columnDiscussionId: discussionId,
      UserstatsDatabase.columnDiscussionName: discussionName,
      UserstatsDatabase.columnVisits: visits,
    };
  }

  /// Convert to domain entity
  DiscussionVisit toEntity() {
    return DiscussionVisit(
      year: year,
      discussionId: discussionId,
      discussionName: discussionName,
      visits: visits,
    );
  }
}
