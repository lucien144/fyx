import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:fyx/features/userstats/domain/entities/discussion_visit.dart';
import 'package:fyx/features/userstats/domain/enums/scroll_landmark.dart';
import 'package:fyx/features/userstats/domain/enums/writing_volume.dart';
import 'package:fyx/features/userstats/domain/enums/year_in_review_character.dart';
import 'package:fyx/features/userstats/domain/enums/year_in_review_rhythm.dart';

part 'year_in_review_slide.freezed.dart';

/// One page of a Year in Review. Carries numbers and decisions only — wording
/// and colours belong to the presentation layer.
@freezed
sealed class YearInReviewSlide with _$YearInReviewSlide {
  const factory YearInReviewSlide.intro() = IntroSlide;

  const factory YearInReviewSlide.time({
    required int seconds,
    required int appLaunches,
    required int galleryOpens,
  }) = TimeSlide;

  const factory YearInReviewSlide.doomscroll({
    required double meters,
    required ScrollLandmark landmark,
    required int landmarkCount,
    required int healthPercent,
    required int appLaunches,
    required int galleryOpens,
  }) = DoomscrollSlide;

  const factory YearInReviewSlide.writing({
    required int characters,
    required WritingVolume volume,
    required int posts,
    required int replies,
    required int attachments,
    required int mails,
  }) = WritingSlide;

  const factory YearInReviewSlide.ratings({
    required int likes,
    required int dislikes,
    required YearInReviewCharacter character,
  }) = RatingsSlide;

  const factory YearInReviewSlide.streak({
    required int longest,

    /// Null for a closed year or when there is no running streak.
    int? current,
    required int litDots,
  }) = StreakSlide;

  const factory YearInReviewSlide.rhythm({
    required YearInReviewRhythm rhythm,
    required int peakHour,

    /// 24 items, index = hour of day.
    required List<int> hourCounts,
    required int peakWeekday,
    required int peakMonth,
  }) = RhythmSlide;

  const factory YearInReviewSlide.topDiscussions({
    required List<DiscussionVisit> discussions,
  }) = TopDiscussionsSlide;

  /// Missing figures are null and get left out of the card.
  const factory YearInReviewSlide.summary({
    int? seconds,
    double? meters,
    required int likes,
    required int longestStreak,
    YearInReviewRhythm? rhythm,
    required YearInReviewCharacter character,
    String? topDiscussionName,
  }) = SummarySlide;
}

extension TimeSlideExtension on TimeSlide {
  static const secondsPerFilm = 90 * 60;

  int get films => seconds ~/ secondsPerFilm;

  double get days => seconds / Duration.secondsPerDay;
}

extension RatingsSlideExtension on RatingsSlide {
  int? get positivePercent => YearInReviewCharacter.positivePercent(likes: likes, dislikes: dislikes);
}

extension StreakSlideExtension on StreakSlide {
  static const totalDots = 60;

  bool get isRecordRunning => current != null && current! >= longest;

  /// Days left until the running streak beats the longest one.
  int get daysToRecord => longest - (current ?? 0) + 1;
}
