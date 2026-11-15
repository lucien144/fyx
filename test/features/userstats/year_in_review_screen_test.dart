import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fyx/features/userstats/domain/entities/daily_usage.dart';
import 'package:fyx/features/userstats/domain/entities/discussion_visit.dart';
import 'package:fyx/features/userstats/domain/entities/global_stat.dart';
import 'package:fyx/features/userstats/domain/entities/hourly_usage.dart';
import 'package:fyx/features/userstats/domain/enums/global_stat_type.dart';
import 'package:fyx/features/userstats/domain/repositories/userstats_repository.dart';
import 'package:fyx/features/userstats/presentation/viewmodel/year_in_review_viewmodel.dart';
import 'package:fyx/features/userstats/presentation/year_in_review_screen.dart';
import 'package:fyx/model/enums/SkinEnum.dart';
import 'package:fyx/shared/services/service_locator.dart';
import 'package:fyx/theme/skin/Skin.dart';
import 'package:fyx/theme/skin/skins/FyxSkin.dart';
import 'package:fyx/theme/skin/skins/dark_skin.dart';
import 'package:google_fonts/google_fonts.dart';

const _year = 2026;

/// A heavy user: every slide is present and the figures are long.
class _FakeRepository implements UserstatsRepository {
  @override
  Future<List<GlobalStat>> getGlobalStatsByYear(int year) async {
    const values = {
      GlobalStatType.sessionDurationSeconds: 1234 * 3600 + 53 * 60,
      GlobalStatType.appLaunches: 12220,
      GlobalStatType.galleryOpens: 13331,
      GlobalStatType.totalScrollPx: 2147483647,
      GlobalStatType.likes: 12206,
      GlobalStatType.dislikes: 11802,
      GlobalStatType.postsCreated: 6000,
      GlobalStatType.postReplies: 4600,
      GlobalStatType.postAttachments: 5100,
      GlobalStatType.mailsCreated: 3000,
      GlobalStatType.postsLength: 1863512,
    };
    return [for (final entry in values.entries) GlobalStat(year: year, statType: entry.key.value, number: entry.value)];
  }

  @override
  Future<List<DiscussionVisit>> getDiscussionVisitsByYear(int year) async {
    return [
      for (var i = 0; i < 5; i++)
        DiscussionVisit(
          year: year,
          discussionId: i,
          discussionName: 'ISM || I Shot Myself aneb selfie, selfacek a jine dlouhe nazvy klubu $i',
          visits: 15990 - i * 1000,
        ),
    ];
  }

  @override
  Future<List<DailyUsage>> getDailyUsageByYear(int year) async {
    return [for (var i = 0; i < 300; i++) DailyUsage(year: year, date: DateTime(year, 3, 14 + i))];
  }

  @override
  Future<List<HourlyUsage>> getHourlyUsageByYear(int year) async {
    return [for (var hour = 0; hour < 24; hour++) HourlyUsage(year: year, hour: hour, count: hour == 22 ? 90 : hour)];
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  // Real fonts, so that text is measured the way it is on a device.
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    GoogleFonts.config.allowRuntimeFetching = false;
    await GoogleFonts.pendingFonts([
      for (final weight in const [FontWeight.w400, FontWeight.w600, FontWeight.w700, FontWeight.w800, FontWeight.w900])
        GoogleFonts.inter(fontWeight: weight),
      GoogleFonts.pressStart2p(),
    ]);
    final icons = FontLoader('packages/lucide_icons/Lucide')
      ..addFont(rootBundle.load('packages/lucide_icons/assets/lucide.ttf'));
    await icons.load();
  });

  setUp(() {
    // December of the running year, so the current-streak card is shown too.
    getIt.registerSingleton<YearInReviewViewModel>(YearInReviewViewModel(
      _FakeRepository(),
      clock: () => DateTime(_year, 12, 20, 12),
      getLastAutoOpenedYear: () => 0,
      setLastAutoOpenedYear: (_) {},
      logError: (error, stack) => throw error,
    ));
  });

  tearDown(() => getIt.reset());

  Widget app() {
    return CupertinoApp(
      home: Skin(
        skin: SkinEnum.fyx,
        skins: [FyxSkin.create(fontSize: 16), DarkSkin.create(fontSize: 16)],
        brightness: Brightness.light,
        child: const YearInReviewScreen(year: _year),
      ),
    );
  }

  for (final size in const [Size(320, 568), Size(360, 640), Size(390, 844), Size(430, 932), Size(820, 1180), Size(800, 400)]) {
    testWidgets('every slide fits a ${size.width.round()}×${size.height.round()} screen', (tester) async {
      tester.view.physicalSize = size * 3;
      tester.view.devicePixelRatio = 3;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(app());
      await tester.pump();

      final viewModel = getIt<YearInReviewViewModel>();
      expect(viewModel.state.slides, hasLength(9));

      for (var i = 0; i < viewModel.state.slides.length; i++) {
        expect(viewModel.state.index, i);
        await tester.pump(const Duration(milliseconds: 500));
        expect(tester.takeException(), isNull, reason: 'slide ${viewModel.state.slide.runtimeType}');
        viewModel.next();
        await tester.pump();
      }

      await tester.pumpWidget(const SizedBox());
    });
  }

  testWidgets('slides advance on their own and stop on the last one', (tester) async {
    await tester.pumpWidget(app());
    await tester.pump();
    final viewModel = getIt<YearInReviewViewModel>();

    await tester.pump(const Duration(seconds: 5));
    expect(viewModel.state.index, 0);
    await tester.pump(const Duration(seconds: 2));
    expect(viewModel.state.index, 1);

    for (var i = 0; i < 20; i++) await tester.pump(const Duration(seconds: 7));
    expect(viewModel.state.isLast, true);

    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('tapping right goes forward, left goes back, holding pauses', (tester) async {
    await tester.pumpWidget(app());
    await tester.pump();
    final viewModel = getIt<YearInReviewViewModel>();
    final size = tester.view.physicalSize / tester.view.devicePixelRatio;
    final right = Offset(size.width * 0.8, size.height / 2);
    final left = Offset(size.width * 0.1, size.height / 2);

    await tester.tapAt(right);
    await tester.pump();
    expect(viewModel.state.index, 1);

    await tester.tapAt(left);
    await tester.pump();
    expect(viewModel.state.index, 0);

    final hold = await tester.startGesture(right);
    await tester.pump(const Duration(seconds: 20));
    expect(viewModel.state.index, 0, reason: 'the timer is paused while a finger is down');
    await hold.up();
    await tester.pump();
    expect(viewModel.state.index, 0, reason: 'releasing a long press is not a tap');

    await tester.pump(const Duration(seconds: 7));
    expect(viewModel.state.index, 1);

    await tester.pumpWidget(const SizedBox());
  });
}
