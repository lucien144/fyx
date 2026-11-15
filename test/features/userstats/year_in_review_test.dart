import 'package:flutter_test/flutter_test.dart';
import 'package:fyx/features/userstats/domain/entities/daily_usage.dart';
import 'package:fyx/features/userstats/domain/entities/discussion_visit.dart';
import 'package:fyx/features/userstats/domain/entities/global_stat.dart';
import 'package:fyx/features/userstats/domain/entities/hourly_usage.dart';
import 'package:fyx/features/userstats/domain/entities/year_in_review.dart';
import 'package:fyx/features/userstats/domain/entities/year_in_review_slide.dart';
import 'package:fyx/features/userstats/domain/entities/year_in_review_window.dart';
import 'package:fyx/features/userstats/domain/enums/global_stat_type.dart';
import 'package:fyx/features/userstats/domain/enums/scroll_landmark.dart';
import 'package:fyx/features/userstats/domain/enums/writing_volume.dart';
import 'package:fyx/features/userstats/domain/enums/year_in_review_character.dart';
import 'package:fyx/features/userstats/domain/enums/year_in_review_rhythm.dart';

const _year = 2026;

/// Pixels that convert to exactly [meters] at a device pixel ratio of 3.
int _pixels(double meters) => (meters * 100 * 160 * 3 / 2.54).round();

List<GlobalStat> _stats(Map<GlobalStatType, int> values) {
  return [for (final entry in values.entries) GlobalStat(year: _year, statType: entry.key.value, number: entry.value)];
}

/// [count] consecutive days starting at [from].
List<DailyUsage> _days(DateTime from, int count) {
  return [for (var i = 0; i < count; i++) DailyUsage(year: from.year, date: DateTime(from.year, from.month, from.day + i))];
}

YearInReview _review({
  Map<GlobalStatType, int> stats = const {},
  List<DiscussionVisit> visits = const [],
  List<DailyUsage>? days,
  List<HourlyUsage> hours = const [],
  DateTime? now,
}) {
  return YearInReview.fromStatistics(
    year: _year,
    now: now ?? DateTime(2027, 1, 5),
    globalStats: _stats(stats),
    discussionVisits: visits,
    dailyUsage: days ?? _days(DateTime(_year, 1, 1), 30),
    hourlyUsage: hours,
    devicePixelRatio: 3,
  );
}

T _slide<T extends YearInReviewSlide>(YearInReview review) => review.slides.whereType<T>().single;

void main() {
  group('YearInReviewRhythm', () {
    test('maps every hour to its label', () {
      final expected = {
        for (final hour in [5, 6, 7, 8, 9]) hour: YearInReviewRhythm.earlyBird,
        for (var hour = 10; hour <= 19; hour++) hour: YearInReviewRhythm.craftsman,
        for (final hour in [20, 21, 22, 23, 0]) hour: YearInReviewRhythm.barfly,
        for (final hour in [1, 2, 3, 4]) hour: YearInReviewRhythm.nightBird,
      };
      expect(expected.length, 24);
      expected.forEach((hour, rhythm) => expect(YearInReviewRhythm.fromHour(hour), rhythm, reason: 'hour $hour'));
    });
  });

  group('YearInReviewCharacter', () {
    YearInReviewCharacter of(int likes, int dislikes) => YearInReviewCharacter.fromRatings(likes: likes, dislikes: dislikes);

    test('boundaries follow the share of likes', () {
      expect(of(0, 0), YearInReviewCharacter.silentBob);
      expect(of(206, 2), YearInReviewCharacter.forrestGump);
      expect(of(95, 5), YearInReviewCharacter.forrestGump);
      expect(of(94, 6), YearInReviewCharacter.gandalf);
      expect(of(75, 25), YearInReviewCharacter.gandalf);
      expect(of(74, 26), YearInReviewCharacter.shrek);
      expect(of(40, 60), YearInReviewCharacter.shrek);
      expect(of(39, 61), YearInReviewCharacter.darthVader);
      expect(of(0, 7), YearInReviewCharacter.darthVader);
    });
  });

  group('ScrollLandmark', () {
    test('picks the landmark by distance', () {
      expect(ScrollLandmark.fromMeters(653), ScrollLandmark.petrin);
      expect(ScrollLandmark.fromMeters(1999), ScrollLandmark.petrin);
      expect(ScrollLandmark.fromMeters(2000), ScrollLandmark.zizkov);
      expect(ScrollLandmark.fromMeters(19999), ScrollLandmark.zizkov);
      expect(ScrollLandmark.fromMeters(20000), ScrollLandmark.everest);
    });

    test('counts whole landmarks only', () {
      expect(ScrollLandmark.petrin.countIn(653), 10);
      expect(ScrollLandmark.petrin.countIn(60), 0);
      expect(ScrollLandmark.everest.countIn(20000), 2);
    });
  });

  group('WritingVolume', () {
    test('tiers by standard pages', () {
      expect(WritingVolume.fromCharacters(0), WritingVolume.none);
      expect(WritingVolume.fromCharacters(1799), WritingVolume.none);
      expect(WritingVolume.fromCharacters(8635), WritingVolume.shortStory);
      expect(WritingVolume.fromCharacters(20 * 1800), WritingVolume.novella);
      expect(WritingVolume.fromCharacters(100 * 1800), WritingVolume.novel);
      expect(WritingVolume.pagesOf(8635), 5);
    });
  });

  group('DailyUsage streaks', () {
    test('longest streak survives the spring DST change', () {
      // Clocks move forward on 2026-03-29 in Europe; local midnights are then 23 hours apart.
      expect(_days(DateTime(2026, 3, 27), 5).longestStreak, 5);
    });

    test('duplicate days count once', () {
      final days = [..._days(DateTime(2026, 5, 1), 3), ..._days(DateTime(2026, 5, 2), 1)];
      expect(days.activeDays, 3);
      expect(days.longestStreak, 3);
    });

    test('current streak ends when yesterday was missed', () {
      final days = _days(DateTime(2026, 6, 1), 4); // June 1–4
      expect(days.currentStreakAt(DateTime(2026, 6, 4, 22)), 4);
      expect(days.currentStreakAt(DateTime(2026, 6, 5, 8)), 4);
      expect(days.currentStreakAt(DateTime(2026, 6, 6, 8)), 0);
    });
  });

  group('YearInReview.fromStatistics', () {
    test('builds all nine slides from a full year', () {
      final review = _review(
        stats: {
          GlobalStatType.sessionDurationSeconds: 34 * 3600 + 53 * 60,
          GlobalStatType.appLaunches: 1220,
          GlobalStatType.galleryOpens: 1331,
          GlobalStatType.totalScrollPx: _pixels(653),
          GlobalStatType.likes: 206,
          GlobalStatType.dislikes: 2,
          GlobalStatType.postsCreated: 60,
          GlobalStatType.postReplies: 46,
          GlobalStatType.postAttachments: 40,
          GlobalStatType.mailAttachments: 11,
          GlobalStatType.mailsCreated: 30,
          GlobalStatType.postsLength: 8000,
          GlobalStatType.mailsLength: 635,
        },
        visits: [
          for (var i = 0; i < 7; i++) DiscussionVisit(year: _year, discussionId: i, discussionName: 'Klub $i', visits: 600 - i),
        ],
        days: _days(DateTime(_year, 1, 1), 239),
        hours: const [
          HourlyUsage(year: _year, hour: 7, count: 10),
          HourlyUsage(year: _year, hour: 20, count: 4),
        ],
      );

      expect(review.slides.map((slide) => slide.runtimeType.toString().replaceAll(RegExp(r'[_$]|Impl'), '')), [
        'IntroSlide', 'TimeSlide', 'DoomscrollSlide', 'WritingSlide', 'RatingsSlide', //
        'StreakSlide', 'RhythmSlide', 'TopDiscussionsSlide', 'SummarySlide',
      ]);
      expect(review.countedFrom, isNull);
      expect(review.activeDays, 239);

      final time = _slide<TimeSlide>(review);
      expect(time.films, 23);
      expect(time.days, closeTo(1.45, 0.01));

      final doom = _slide<DoomscrollSlide>(review);
      expect(doom.meters, closeTo(653, 0.01));
      expect(doom.landmark, ScrollLandmark.petrin);
      expect(doom.landmarkCount, 10);
      expect(doom.healthPercent, 100 - (239 * 100 / 365).round());

      final writing = _slide<WritingSlide>(review);
      expect(writing.characters, 8635);
      expect(writing.attachments, 51);
      expect(writing.volume, WritingVolume.shortStory);

      final ratings = _slide<RatingsSlide>(review);
      expect(ratings.positivePercent, 99);
      expect(ratings.character, YearInReviewCharacter.forrestGump);

      final streak = _slide<StreakSlide>(review);
      expect(streak.longest, 239);
      expect(streak.current, isNull, reason: 'a closed year has no running streak');
      expect(streak.litDots, 39);

      final rhythm = _slide<RhythmSlide>(review);
      expect(rhythm.rhythm, YearInReviewRhythm.earlyBird);
      expect(rhythm.hourCounts, hasLength(24));
      expect(rhythm.hourCounts[7], 10);

      expect(_slide<TopDiscussionsSlide>(review).discussions, hasLength(5));

      final summary = _slide<SummarySlide>(review);
      expect(summary.topDiscussionName, 'Klub 0');
      expect(summary.rhythm, YearInReviewRhythm.earlyBird);
    });

    test('leaves out slides without data', () {
      final review = _review();

      expect(review.slides.whereType<TimeSlide>(), isEmpty);
      expect(review.slides.whereType<DoomscrollSlide>(), isEmpty);
      expect(review.slides.whereType<RhythmSlide>(), isEmpty);
      expect(review.slides.whereType<TopDiscussionsSlide>(), isEmpty);
      expect(review.slides, hasLength(5));

      expect(_slide<WritingSlide>(review).volume, WritingVolume.none);
      expect(_slide<RatingsSlide>(review).character, YearInReviewCharacter.silentBob);

      final summary = _slide<SummarySlide>(review);
      expect(summary.seconds, isNull);
      expect(summary.meters, isNull);
      expect(summary.rhythm, isNull);
      expect(summary.topDiscussionName, isNull);
    });

    test('reports the first active day unless it is January 1st', () {
      expect(_review(days: _days(DateTime(_year, 3, 14), 20)).countedFrom, DateTime(_year, 3, 14));
      expect(_review(days: _days(DateTime(_year, 1, 1), 20)).countedFrom, isNull);
    });

    test('health never drops below one percent', () {
      final review = _review(stats: {GlobalStatType.totalScrollPx: _pixels(10)}, days: _days(DateTime(_year, 1, 1), 365));
      expect(_slide<DoomscrollSlide>(review).healthPercent, 1);
    });

    test('a running year shows the current streak and days left to the record', () {
      final now = DateTime(_year, 6, 30, 12);
      // 20 days in January, then a 10-day streak ending today.
      final days = [..._days(DateTime(_year, 1, 1), 20), ..._days(DateTime(_year, 6, 21), 10)];
      final streak = _slide<StreakSlide>(_review(days: days, now: now));

      expect(streak.longest, 20);
      expect(streak.current, 10);
      expect(streak.isRecordRunning, false);
      expect(streak.daysToRecord, 11);
      // 20 of the 181 days elapsed so far.
      expect(streak.litDots, (20 * 60 / 181).round());
    });

    test('a running streak that is the longest one is a record in progress', () {
      final now = DateTime(_year, 2, 10, 12);
      final streak = _slide<StreakSlide>(_review(days: _days(DateTime(_year, 2, 1), 10), now: now));

      expect(streak.current, 10);
      expect(streak.isRecordRunning, true);
    });

    test('a broken streak hides the current streak', () {
      final now = DateTime(_year, 6, 30, 12);
      expect(_slide<StreakSlide>(_review(days: _days(DateTime(_year, 6, 1), 5), now: now)).current, isNull);
    });

    test('a single active day still lights one dot', () {
      expect(_slide<StreakSlide>(_review(days: _days(DateTime(_year, 4, 4), 1))).litDots, 1);
    });
  });

  group('YearInReviewWindow', () {
    test('is open for the first 14 days of January only', () {
      expect(YearInReviewWindow.isOpen(DateTime(2027, 1, 1)), true);
      expect(YearInReviewWindow.isOpen(DateTime(2027, 1, 14, 23, 59)), true);
      expect(YearInReviewWindow.isOpen(DateTime(2027, 1, 15)), false);
      expect(YearInReviewWindow.isOpen(DateTime(2026, 12, 31)), false);
      expect(YearInReviewWindow.yearFor(DateTime(2027, 1, 3)), 2026);
    });

    test('is offered to premium users with at least 7 active days', () {
      final now = DateTime(2027, 1, 3);
      expect(YearInReviewWindow.isOffered(now: now, isPremium: true, activeDays: 7), true);
      expect(YearInReviewWindow.isOffered(now: now, isPremium: true, activeDays: 6), false);
      expect(YearInReviewWindow.isOffered(now: now, isPremium: false, activeDays: 200), false);
      expect(YearInReviewWindow.isOffered(now: DateTime(2027, 2, 1), isPremium: true, activeDays: 200), false);
    });

    test('opens on its own once per reviewed year', () {
      bool auto(int? last) => YearInReviewWindow.shouldAutoOpen(
          now: DateTime(2027, 1, 3), isPremium: true, activeDays: 50, lastAutoOpenedYear: last);

      expect(auto(null), true);
      expect(auto(2025), true);
      expect(auto(2026), false);
    });
  });
}
