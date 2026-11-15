import 'dart:math';

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:fyx/features/userstats/domain/entities/daily_usage.dart';
import 'package:fyx/features/userstats/domain/entities/discussion_visit.dart';
import 'package:fyx/features/userstats/domain/entities/global_stat.dart';
import 'package:fyx/features/userstats/domain/entities/hourly_usage.dart';
import 'package:fyx/features/userstats/domain/entities/year_in_review_slide.dart';
import 'package:fyx/features/userstats/domain/enums/global_stat_type.dart';
import 'package:fyx/features/userstats/domain/enums/scroll_landmark.dart';
import 'package:fyx/features/userstats/domain/enums/writing_volume.dart';
import 'package:fyx/features/userstats/domain/enums/year_in_review_character.dart';
import 'package:fyx/features/userstats/domain/enums/year_in_review_rhythm.dart';

part 'year_in_review.freezed.dart';

/// A story-style walkthrough of one year's Statistics ("Rok s Fyxem").
@freezed
class YearInReview with _$YearInReview {
  const factory YearInReview({
    required int year,

    /// First active day, unless the data covers the year from January 1st.
    DateTime? countedFrom,
    required int activeDays,
    required List<YearInReviewSlide> slides,
  }) = _YearInReview;

  static const topDiscussionsCount = 5;

  /// Builds the review from raw Statistics. Slides without data are left out.
  factory YearInReview.fromStatistics({
    required int year,
    required DateTime now,
    required List<GlobalStat> globalStats,
    required List<DiscussionVisit> discussionVisits,
    required List<DailyUsage> dailyUsage,
    required List<HourlyUsage> hourlyUsage,
    required double devicePixelRatio,
  }) {
    final isRunningYear = year == now.year;
    // A running year is measured against the days elapsed so far.
    final periodDays = isRunningYear ? _dayOfYear(now) : _dayOfYear(DateTime(year, 12, 31));
    final activeDays = dailyUsage.activeDays;

    final seconds = globalStats.valueOf(GlobalStatType.sessionDurationSeconds);
    final appLaunches = globalStats.valueOf(GlobalStatType.appLaunches);
    final galleryOpens = globalStats.valueOf(GlobalStatType.galleryOpens);
    final meters = globalStats.scrollMeters(devicePixelRatio);
    final likes = globalStats.valueOf(GlobalStatType.likes);
    final dislikes = globalStats.valueOf(GlobalStatType.dislikes);
    final characters = globalStats.valueOf(GlobalStatType.postsLength) + globalStats.valueOf(GlobalStatType.mailsLength);

    final longestStreak = dailyUsage.longestStreak;
    final currentStreak = isRunningYear ? dailyUsage.currentStreakAt(now) : 0;
    final peakHour = hourlyUsage.peakHour;
    final rhythm = peakHour >= 0 ? YearInReviewRhythm.fromHour(peakHour) : null;
    final character = YearInReviewCharacter.fromRatings(likes: likes, dislikes: dislikes);
    final topDiscussions = discussionVisits.take(topDiscussionsCount).toList();
    final landmark = ScrollLandmark.fromMeters(meters);
    final hourMap = hourlyUsage.toHourMap();

    final firstDay = dailyUsage.firstDay;
    final countsFromNewYear = firstDay == null || (firstDay.month == DateTime.january && firstDay.day == 1);

    return YearInReview(
      year: year,
      countedFrom: countsFromNewYear ? null : firstDay,
      activeDays: activeDays,
      slides: [
        const YearInReviewSlide.intro(),
        if (seconds > 0) YearInReviewSlide.time(seconds: seconds, appLaunches: appLaunches, galleryOpens: galleryOpens),
        if (meters > 0)
          YearInReviewSlide.doomscroll(
            meters: meters,
            landmark: landmark,
            landmarkCount: landmark.countIn(meters),
            healthPercent: max(1, 100 - (activeDays * 100 / periodDays).round()),
            appLaunches: appLaunches,
            galleryOpens: galleryOpens,
          ),
        YearInReviewSlide.writing(
          characters: characters,
          volume: WritingVolume.fromCharacters(characters),
          posts: globalStats.valueOf(GlobalStatType.postsCreated),
          replies: globalStats.valueOf(GlobalStatType.postReplies),
          attachments:
              globalStats.valueOf(GlobalStatType.postAttachments) + globalStats.valueOf(GlobalStatType.mailAttachments),
          mails: globalStats.valueOf(GlobalStatType.mailsCreated),
        ),
        YearInReviewSlide.ratings(likes: likes, dislikes: dislikes, character: character),
        YearInReviewSlide.streak(
          longest: longestStreak,
          current: currentStreak > 0 ? currentStreak : null,
          litDots: longestStreak == 0
              ? 0
              : (longestStreak * StreakSlideExtension.totalDots / periodDays)
                  .round()
                  .clamp(1, StreakSlideExtension.totalDots),
        ),
        if (rhythm != null)
          YearInReviewSlide.rhythm(
            rhythm: rhythm,
            peakHour: peakHour,
            hourCounts: [for (var hour = 0; hour < 24; hour++) hourMap[hour] ?? 0],
            peakWeekday: dailyUsage.peakWeekday,
            peakMonth: dailyUsage.peakMonth,
          ),
        if (topDiscussions.isNotEmpty) YearInReviewSlide.topDiscussions(discussions: topDiscussions),
        YearInReviewSlide.summary(
          seconds: seconds > 0 ? seconds : null,
          meters: meters > 0 ? meters : null,
          likes: likes,
          longestStreak: longestStreak,
          rhythm: rhythm,
          character: character,
          topDiscussionName: topDiscussions.firstOrNull?.discussionName,
        ),
      ],
    );
  }

  static int _dayOfYear(DateTime date) {
    return DateTime.utc(date.year, date.month, date.day).difference(DateTime.utc(date.year)).inDays + 1;
  }
}
