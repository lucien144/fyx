import 'package:freezed_annotation/freezed_annotation.dart';

part 'discussion_visit.freezed.dart';

/// Domain entity representing a discussion visit record
@freezed
class DiscussionVisit with _$DiscussionVisit {
  const factory DiscussionVisit({
    required int year,
    required int discussionId,
    required String discussionName,
    required int visits,
  }) = _DiscussionVisit;
}
