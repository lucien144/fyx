import 'package:flutter/foundation.dart';
import 'package:fyx/controllers/SettingsProvider.dart';
import 'package:fyx/controllers/log_service.dart';
import 'package:fyx/features/userstats/domain/entities/daily_usage.dart';
import 'package:fyx/features/userstats/domain/entities/year_in_review.dart';
import 'package:fyx/features/userstats/domain/entities/year_in_review_window.dart';
import 'package:fyx/features/userstats/domain/repositories/userstats_repository.dart';
import 'package:fyx/features/userstats/presentation/viewmodel/year_in_review_state.dart';

/// Drives the Year in Review screen and decides when the January Window
/// offers it. Statistics are read straight from the repository.
class YearInReviewViewModel extends ChangeNotifier {
  final UserstatsRepository _repository;
  final DateTime Function() _clock;
  final int Function() _getLastAutoOpenedYear;
  final void Function(int year) _setLastAutoOpenedYear;
  final void Function(Object error, StackTrace stack) _logError;

  YearInReviewViewModel(
    this._repository, {
    DateTime Function()? clock,
    int Function()? getLastAutoOpenedYear,
    void Function(int year)? setLastAutoOpenedYear,
    void Function(Object error, StackTrace stack)? logError,
  })  : _clock = clock ?? DateTime.now,
        _getLastAutoOpenedYear = getLastAutoOpenedYear ?? _settingsLastAutoOpenedYear,
        _setLastAutoOpenedYear = setLastAutoOpenedYear ?? _settingsSetLastAutoOpenedYear,
        _logError = logError ?? _captureError;

  static int _settingsLastAutoOpenedYear() => SettingsProvider().yearInReviewAutoOpened;

  static void _settingsSetLastAutoOpenedYear(int year) => SettingsProvider().yearInReviewAutoOpened = year;

  static void _captureError(Object error, StackTrace stack) => LogService.captureError(error, stack: stack);

  YearInReviewState _state = const YearInReviewState();

  YearInReviewState get state => _state;

  /// Loads the review of [year]. Safe to call from initState: it does not
  /// notify before the first await.
  Future<void> load(int year, {required double devicePixelRatio}) async {
    _state = _state.copyWith(status: YearInReviewStatus.loading, clearReview: true, index: 0);
    try {
      final (globalStats, discussionVisits, dailyUsage, hourlyUsage) = await (
        _repository.getGlobalStatsByYear(year),
        _repository.getDiscussionVisitsByYear(year),
        _repository.getDailyUsageByYear(year),
        _repository.getHourlyUsageByYear(year),
      ).wait;
      final review = YearInReview.fromStatistics(
        year: year,
        now: _clock(),
        globalStats: globalStats,
        discussionVisits: discussionVisits,
        dailyUsage: dailyUsage,
        hourlyUsage: hourlyUsage,
        devicePixelRatio: devicePixelRatio,
      );
      _state = _state.copyWith(status: YearInReviewStatus.ready, review: review, index: 0);
    } catch (error, stack) {
      _logError(error, stack);
      _state = _state.copyWith(status: YearInReviewStatus.failed, clearReview: true);
    }
    notifyListeners();
  }

  void next() => _goTo(_state.index + 1);

  void previous() => _goTo(_state.index - 1);

  void restart() => _goTo(0, force: true);

  void _goTo(int index, {bool force = false}) {
    if (_state.slides.isEmpty) return;
    final clamped = index.clamp(0, _state.slides.length - 1);
    if (clamped == _state.index && !force) return;
    _state = _state.copyWith(index: clamped);
    notifyListeners();
  }

  /// Re-evaluates what the January Window offers right now.
  Future<void> refreshWindow() async {
    final now = _clock();
    if (!YearInReviewWindow.isOpen(now)) {
      if (_state.windowYear == null) return;
      _state = _state.copyWith(clearWindowYear: true, windowActiveDays: 0);
      notifyListeners();
      return;
    }
    final year = YearInReviewWindow.yearFor(now);
    try {
      final activeDays = (await _repository.getDailyUsageByYear(year)).activeDays;
      if (_state.windowYear == year && _state.windowActiveDays == activeDays) return;
      _state = _state.copyWith(windowYear: year, windowActiveDays: activeDays);
      notifyListeners();
    } catch (error, stack) {
      _logError(error, stack);
    }
  }

  /// Whether the menu entry is visible for a user with the given premium.
  bool isOfferedTo({required bool isPremium}) {
    return _state.windowYear != null &&
        YearInReviewWindow.isOffered(now: _clock(), isPremium: isPremium, activeDays: _state.windowActiveDays);
  }

  /// The year to open on its own, or null when nothing should open.
  Future<int?> yearToAutoOpen({required bool isPremium}) async {
    await refreshWindow();
    final shouldOpen = _state.windowYear != null &&
        YearInReviewWindow.shouldAutoOpen(
          now: _clock(),
          isPremium: isPremium,
          activeDays: _state.windowActiveDays,
          lastAutoOpenedYear: _getLastAutoOpenedYear(),
        );
    return shouldOpen ? _state.windowYear : null;
  }

  /// Remembers that [year] has opened on its own, so it never does again.
  void markAutoOpened(int year) => _setLastAutoOpenedYear(year);
}
