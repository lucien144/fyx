import 'package:flutter_test/flutter_test.dart';
import 'package:fyx/features/userstats/domain/entities/daily_usage.dart';
import 'package:fyx/features/userstats/domain/entities/discussion_visit.dart';
import 'package:fyx/features/userstats/domain/entities/global_stat.dart';
import 'package:fyx/features/userstats/domain/entities/hourly_usage.dart';
import 'package:fyx/features/userstats/domain/repositories/userstats_repository.dart';
import 'package:fyx/features/userstats/presentation/viewmodel/year_in_review_state.dart';
import 'package:fyx/features/userstats/presentation/viewmodel/year_in_review_viewmodel.dart';

class _FakeRepository implements UserstatsRepository {
  /// Active days per year.
  Map<int, int> activeDays = {};
  bool throwOnRead = false;

  @override
  Future<List<DailyUsage>> getDailyUsageByYear(int year) async {
    if (throwOnRead) throw Exception('database is gone');
    return [for (var i = 0; i < (activeDays[year] ?? 0); i++) DailyUsage(year: year, date: DateTime(year, 1, 1 + i))];
  }

  @override
  Future<List<GlobalStat>> getGlobalStatsByYear(int year) async => [];

  @override
  Future<List<DiscussionVisit>> getDiscussionVisitsByYear(int year) async => [];

  @override
  Future<List<HourlyUsage>> getHourlyUsageByYear(int year) async => [];

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  late _FakeRepository repo;
  late DateTime now;
  late int lastAutoOpened;

  YearInReviewViewModel vm() => YearInReviewViewModel(
        repo,
        clock: () => now,
        getLastAutoOpenedYear: () => lastAutoOpened,
        setLastAutoOpenedYear: (year) => lastAutoOpened = year,
        logError: (_, __) {},
      );

  setUp(() {
    repo = _FakeRepository()..activeDays = {2026: 40};
    now = DateTime(2027, 1, 5, 10);
    lastAutoOpened = 0;
  });

  test('load builds the review and starts on the first slide', () async {
    final viewModel = vm();
    var notifications = 0;
    viewModel.addListener(() => notifications++);

    final loading = viewModel.load(2026, devicePixelRatio: 3);
    expect(notifications, 0, reason: 'must not notify before the first await');
    await loading;

    expect(viewModel.state.status, YearInReviewStatus.ready);
    expect(viewModel.state.review!.year, 2026);
    expect(viewModel.state.index, 0);
    expect(notifications, 1);
  });

  test('a failing repository ends in the failed state', () async {
    repo.throwOnRead = true;
    final viewModel = vm();
    await viewModel.load(2026, devicePixelRatio: 3);

    expect(viewModel.state.status, YearInReviewStatus.failed);
    expect(viewModel.state.review, isNull);
  });

  test('navigation stays within the slides', () async {
    final viewModel = vm();
    await viewModel.load(2026, devicePixelRatio: 3);
    final last = viewModel.state.slides.length - 1;

    viewModel.previous();
    expect(viewModel.state.index, 0);

    for (var i = 0; i < 20; i++) viewModel.next();
    expect(viewModel.state.index, last);
    expect(viewModel.state.isLast, true);

    viewModel.restart();
    expect(viewModel.state.index, 0);
  });

  test('the window offers last year to premium users with enough active days', () async {
    final viewModel = vm();
    await viewModel.refreshWindow();

    expect(viewModel.state.windowYear, 2026);
    expect(viewModel.isOfferedTo(isPremium: true), true);
    expect(viewModel.isOfferedTo(isPremium: false), false);
  });

  test('too few active days are not offered', () async {
    repo.activeDays = {2026: 6};
    final viewModel = vm();
    await viewModel.refreshWindow();

    expect(viewModel.isOfferedTo(isPremium: true), false);
  });

  test('the offer disappears once the window closes', () async {
    final viewModel = vm();
    await viewModel.refreshWindow();
    now = DateTime(2027, 1, 15);
    await viewModel.refreshWindow();

    expect(viewModel.state.windowYear, isNull);
    expect(viewModel.isOfferedTo(isPremium: true), false);
  });

  test('opens on its own only once per year', () async {
    final viewModel = vm();

    final year = await viewModel.yearToAutoOpen(isPremium: true);
    expect(year, 2026);

    viewModel.markAutoOpened(year!);
    expect(lastAutoOpened, 2026);
    expect(await viewModel.yearToAutoOpen(isPremium: true), isNull);
    expect(viewModel.isOfferedTo(isPremium: true), true, reason: 'the menu entry stays available');
  });

  test('a user who becomes premium later in the window still gets it', () async {
    final viewModel = vm();
    expect(await viewModel.yearToAutoOpen(isPremium: false), isNull);
    expect(lastAutoOpened, 0);

    now = DateTime(2027, 1, 10);
    expect(await viewModel.yearToAutoOpen(isPremium: true), 2026);
  });
}
