import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_it/flutter_it.dart';
import 'package:fyx/shared/services/analytics/analytics_service.dart';
import 'package:fyx/controllers/log_service.dart';
import 'package:fyx/features/userstats/domain/entities/year_in_review.dart';
import 'package:fyx/features/userstats/domain/entities/year_in_review_slide.dart';
import 'package:fyx/features/userstats/presentation/viewmodel/year_in_review_state.dart';
import 'package:fyx/features/userstats/presentation/viewmodel/year_in_review_viewmodel.dart';
import 'package:fyx/features/userstats/presentation/widgets/year_in_review/slide_parts.dart';
import 'package:fyx/features/userstats/presentation/widgets/year_in_review/slides/doomscroll_slide_view.dart';
import 'package:fyx/features/userstats/presentation/widgets/year_in_review/slides/intro_slide_view.dart';
import 'package:fyx/features/userstats/presentation/widgets/year_in_review/slides/ratings_slide_view.dart';
import 'package:fyx/features/userstats/presentation/widgets/year_in_review/slides/rhythm_slide_view.dart';
import 'package:fyx/features/userstats/presentation/widgets/year_in_review/slides/streak_slide_view.dart';
import 'package:fyx/features/userstats/presentation/widgets/year_in_review/slides/summary_slide_view.dart';
import 'package:fyx/features/userstats/presentation/widgets/year_in_review/slides/time_slide_view.dart';
import 'package:fyx/features/userstats/presentation/widgets/year_in_review/slides/top_discussions_slide_view.dart';
import 'package:fyx/features/userstats/presentation/widgets/year_in_review/slides/writing_slide_view.dart';
import 'package:fyx/features/userstats/presentation/widgets/year_in_review/year_in_review_palette.dart';
import 'package:fyx/features/userstats/presentation/widgets/year_in_review/year_in_review_share.dart';
import 'package:fyx/features/userstats/presentation/widgets/year_in_review/year_in_review_texts.dart';
import 'package:fyx/model/MainRepository.dart';
import 'package:fyx/shared/services/service_locator.dart';
import 'package:fyx/theme/T.dart';
import 'package:fyx/theme/skin/Skin.dart';
import 'package:fyx/theme/skin/SkinColors.dart';
import 'package:lucide_icons/lucide_icons.dart';

/// Where the Year in Review was opened from (reported to analytics).
enum YearInReviewSource { auto, menu, statistics }

/// Full-screen, story-style Year in Review ("Rok s Fyxem").
///
/// Slides advance on their own; a tap on the left third goes back, a tap on
/// the rest goes forward, and holding a finger down pauses the timer.
class YearInReviewScreen extends StatefulWidget with WatchItStatefulWidgetMixin {
  const YearInReviewScreen({super.key, required this.year});

  final int year;

  static Future<void> open(BuildContext context, {required int year, required YearInReviewSource source}) {
    getIt<AnalyticsService>().logEvent('yearInReviewOpen', parameters: {'source': source.name});
    return Navigator.of(context, rootNavigator: true).push(
      CupertinoPageRoute(fullscreenDialog: true, builder: (_) => YearInReviewScreen(year: year)),
    );
  }

  @override
  State<YearInReviewScreen> createState() => _YearInReviewScreenState();
}

class _YearInReviewScreenState extends State<YearInReviewScreen> with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  static const _slideDuration = Duration(seconds: 6);

  /// Width the slides are designed for; they are scaled to the real screen.
  static const _designWidth = 370.0;
  static const _maxWidth = 430.0;
  static const _dismissDistance = 80.0;

  final _viewModel = getIt<YearInReviewViewModel>();
  final _cardKey = GlobalKey();
  late final AnimationController _timer;

  bool _loadRequested = false;
  bool _isHeld = false;
  bool _isInBackground = false;
  int? _shownIndex;
  int _furthestIndex = 0;
  final _openedAt = DateTime.now();
  double _dragDistance = 0;

  @override
  void initState() {
    super.initState();
    _timer = AnimationController(vsync: this, duration: _slideDuration)
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed && !_viewModel.state.isLast) _viewModel.next();
      });
    _viewModel.addListener(_syncTimer);
    WidgetsBinding.instance.addObserver(this);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);
    getIt<AnalyticsService>().setScreen('YearInReview', 'YearInReviewScreen');
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_loadRequested) return;
    _loadRequested = true;
    _viewModel.load(widget.year, devicePixelRatio: MediaQuery.devicePixelRatioOf(context));
  }

  @override
  void dispose() {
    _logClose();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: SystemUiOverlay.values);
    WidgetsBinding.instance.removeObserver(this);
    _viewModel.removeListener(_syncTimer);
    _timer.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _isInBackground = state != AppLifecycleState.resumed;
    _isInBackground ? _timer.stop() : _resume();
  }

  /// Restarts the timer whenever a different slide comes on screen.
  void _syncTimer() {
    final state = _viewModel.state;
    if (state.status != YearInReviewStatus.ready) return;
    if (_shownIndex == state.index) return;
    _shownIndex = state.index;
    if (state.index > _furthestIndex) _furthestIndex = state.index;
    if (state.isLast) {
      _timer.value = 1;
    } else {
      _timer.value = 0;
      _resume();
    }
  }

  /// How far the story got; slide numbers are 1-based. Skipped when nothing loaded.
  void _logClose() {
    final state = _viewModel.state;
    if (state.status != YearInReviewStatus.ready || state.slides.isEmpty) return;
    getIt<AnalyticsService>().logEvent('yearInReviewClose', parameters: {
      'slide': state.index + 1,
      'furthest': _furthestIndex + 1,
      'slides': state.slides.length,
      'completed': _furthestIndex >= state.slides.length - 1 ? 1 : 0,
      'seconds': DateTime.now().difference(_openedAt).inSeconds,
    });
  }

  void _resume() {
    final state = _viewModel.state;
    if (_isHeld || _isInBackground || state.status != YearInReviewStatus.ready || state.isLast) return;
    _timer.forward();
  }

  void _hold() {
    _isHeld = true;
    _timer.stop();
  }

  void _release() {
    _isHeld = false;
    _resume();
  }

  void _close() => Navigator.of(context).maybePop();

  Future<void> _share(Color background) async {
    try {
      getIt<AnalyticsService>().logEvent('yearInReviewShare');
      await YearInReviewShare.shareCard(_cardKey, background: background, year: widget.year);
    } catch (error, stack) {
      LogService.captureError(error, stack: stack);
      T.error('Kartu se nepodařilo sdílet.');
    }
  }

  static YearInReviewTone _toneOf(YearInReviewSlide? slide) {
    return switch (slide) {
      null || IntroSlide() || StreakSlide() => YearInReviewTone.primary,
      TimeSlide() || WritingSlide() || RhythmSlide() || SummarySlide() => YearInReviewTone.light,
      RatingsSlide() => YearInReviewTone.plain,
      TopDiscussionsSlide() => YearInReviewTone.deep,
      DoomscrollSlide() => YearInReviewTone.doom,
    };
  }

  @override
  Widget build(BuildContext context) {
    final state = watchIt<YearInReviewViewModel>().state;
    final SkinColors colors = Skin.of(context).theme.colors;
    final palette = YearInReviewPalette.of(colors, _toneOf(state.slide));
    final media = MediaQuery.of(context);

    return MediaQuery(
      // Sizes are fixed by the design, so system text scaling is switched off.
      data: media.copyWith(textScaler: TextScaler.noScaling),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 400),
        color: palette.background,
        child: DefaultTextStyle(
          style: inter(16, color: palette.foreground),
          child: Stack(
            fit: StackFit.expand,
            children: [
              _zones(),
              Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: _maxWidth),
                  child: LayoutBuilder(builder: (context, constraints) {
                    final scale = constraints.maxWidth / _designWidth;
                    return FittedBox(
                      child: SizedBox(
                        width: _designWidth,
                        height: constraints.maxHeight / scale,
                        child: _canvas(state, palette, top: media.viewPadding.top / scale, bottom: media.viewPadding.bottom / scale),
                      ),
                    );
                  }),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Touch layer under the slides: left 35 % goes back, right 65 % forward.
  Widget _zones() {
    Widget zone(int flex, VoidCallback onTap) {
      return Expanded(
        flex: flex,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: onTap,
          // Claims long presses so that releasing a held finger is not a tap.
          onLongPress: () {},
          onVerticalDragStart: (_) => _dragDistance = 0,
          onVerticalDragUpdate: (details) => _dragDistance += details.delta.dy,
          onVerticalDragEnd: (details) {
            if (_dragDistance > _dismissDistance || (details.primaryVelocity ?? 0) > 700) _close();
          },
        ),
      );
    }

    return Listener(
      onPointerDown: (_) => _hold(),
      onPointerUp: (_) => _release(),
      onPointerCancel: (_) => _release(),
      child: Row(children: [zone(35, _viewModel.previous), zone(65, _viewModel.next)]),
    );
  }

  Widget _canvas(YearInReviewState state, YearInReviewPalette palette, {required double top, required double bottom}) {
    final review = state.review;
    final slide = state.slide;

    return Stack(
      children: [
        if (review != null && slide != null)
          Positioned.fill(
            // The doomscroll slide bleeds to the edges and pads itself.
            child: Padding(
              padding: slide is DoomscrollSlide
                  ? EdgeInsets.only(top: top + 64)
                  : EdgeInsets.fromLTRB(28, top + 64, 28, bottom + 32),
              child: IgnorePointer(
                ignoring: slide is! SummarySlide,
                child: KeyedSubtree(key: ValueKey(state.index), child: _slideView(review, slide, palette, bottom)),
              ),
            ),
          )
        else
          Positioned.fill(
            child: IgnorePointer(
              child: Center(
                child: state.status == YearInReviewStatus.failed
                    ? Text('Statistiky se nepodařilo načíst.', style: inter(16))
                    : CupertinoActivityIndicator(color: palette.foreground),
              ),
            ),
          ),
        Positioned(
          left: 16,
          right: 16,
          top: top + 10,
          child: IgnorePointer(child: _progress(state, palette)),
        ),
        Positioned(
          left: 16,
          right: 4,
          top: top + 14,
          child: Row(
            children: [
              Expanded(
                child: IgnorePointer(
                  child: Text(
                    YearInReviewTexts.header(widget.year),
                    style: inter(13, weight: FontWeight.w700, letterSpacing: 0.26),
                  ),
                ),
              ),
              if (state.slides.isNotEmpty)
                IgnorePointer(
                  child: Opacity(
                    opacity: 0.7,
                    child: Text('${state.index + 1}/${state.slides.length}', style: inter(13, weight: FontWeight.w700)),
                  ),
                ),
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: _close,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Icon(LucideIcons.x, size: 20, color: palette.foreground),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _progress(YearInReviewState state, YearInReviewPalette palette) {
    return AnimatedBuilder(
      animation: _timer,
      builder: (context, _) => Row(
        children: [
          for (var i = 0; i < state.slides.length; i++) ...[
            if (i > 0) const SizedBox(width: 4),
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(2),
                child: Container(
                  height: 3,
                  color: palette.track,
                  alignment: Alignment.centerLeft,
                  child: FractionallySizedBox(
                    widthFactor: i < state.index ? 1 : (i > state.index ? 0 : _timer.value),
                    child: Container(color: palette.foreground),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _slideView(YearInReview review, YearInReviewSlide slide, YearInReviewPalette palette, double bottomInset) {
    final nickname = (MainRepository().credentials?.nickname ?? '').toUpperCase();

    return switch (slide) {
      IntroSlide() => IntroSlideView(palette: palette, nickname: nickname, countedFrom: review.countedFrom),
      TimeSlide() => TimeSlideView(slide: slide, palette: palette),
      DoomscrollSlide() => DoomscrollSlideView(slide: slide, bottomInset: bottomInset),
      WritingSlide() => WritingSlideView(slide: slide, palette: palette),
      RatingsSlide() => RatingsSlideView(slide: slide, palette: palette),
      StreakSlide() => StreakSlideView(slide: slide, palette: palette),
      RhythmSlide() => RhythmSlideView(slide: slide, palette: palette),
      TopDiscussionsSlide() => TopDiscussionsSlideView(slide: slide, palette: palette),
      SummarySlide() => SummarySlideView(
          slide: slide,
          palette: palette,
          year: review.year,
          nickname: nickname,
          countedFrom: review.countedFrom,
          cardKey: _cardKey,
          onShare: () => _share(palette.background),
          onRestart: _viewModel.restart,
        ),
    };
  }
}
